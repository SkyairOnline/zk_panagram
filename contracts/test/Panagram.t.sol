// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Panagram} from "../src/Panagram.sol";
import {HonkVerifier} from "../src/Verifier.sol";

contract PanagramTest is Test {
    HonkVerifier public honkVerifier;
    Panagram public panagram;
    address user = makeAddr("user");
    uint256 constant FIELD_MODULUS =
        21888242871839275222246405745257275088548364400416034343698204186575808495617; // Prime field order
    bytes32 ANSWER = bytes32(uint256(keccak256("triangles")) % FIELD_MODULUS);

    // make a guess

    function setUp() public {
        // deploy the verifier
        honkVerifier = new HonkVerifier();
        // deploy the panagram contract
        panagram = new Panagram(honkVerifier);

        // start the round
        panagram.newRound(ANSWER);
    }

    function _getProof(bytes32 guess, bytes32 correctAnswer, address sender) internal returns (bytes memory _proof) {
        uint256 NUM_ARGS = 6;
        string[] memory inputs = new string[](NUM_ARGS);
        inputs[0] = "npx";
        inputs[1] = "tsx";
        inputs[2] = "js-scripts/generateProof.ts";
        inputs[3] = vm.toString(guess);
        inputs[4] = vm.toString(correctAnswer);
        inputs[5] = vm.toString(sender);

        bytes memory encodedProof = vm.ffi(inputs);
        _proof = abi.decode(encodedProof, (bytes));
        console.logBytes(_proof);
    }

    // 1. Test someone receive NFT 0 if they guess correctly first
    function testCorrectGuessPasses() public {
        vm.prank(user);
        bytes memory proof = _getProof(ANSWER, ANSWER, user);
        panagram.makeGuess(proof);
        vm.assertEq(panagram.balanceOf(user, 0), 1);
        vm.assertEq(panagram.balanceOf(user, 1), 0);

        vm.prank(user);
        vm.expectRevert();
        panagram.makeGuess(proof); // Should revert since already guessed correctly
    }

    // 2. Test someone receive NFT 1 if they guess correctly but not first
    function testSecondGuessPasses() public {
        vm.prank(user);
        bytes memory proof = _getProof(ANSWER, ANSWER, user);
        panagram.makeGuess(proof);
        vm.assertEq(panagram.balanceOf(user, 0), 1);
        vm.assertEq(panagram.balanceOf(user, 1), 0);

        address user2 = makeAddr("user2");
        bytes memory proof2 = _getProof(ANSWER, ANSWER, user2);
        vm.prank(user2);
        panagram.makeGuess(proof2);
        vm.assertEq(panagram.balanceOf(user2, 0), 0);
        vm.assertEq(panagram.balanceOf(user2, 1), 1);
    }

    // 3. Test we can start a new round
    function testStartSecondRound() public {
        vm.prank(user);
        bytes memory proof = _getProof(ANSWER, ANSWER, user);
        panagram.makeGuess(proof);
        vm.assertEq(panagram.balanceOf(user, 0), 1);
        vm.assertEq(panagram.balanceOf(user, 1), 0);

        vm.warp(panagram.MIN_DURATION() + 1);
        bytes32 NEW_ANSWER = bytes32(uint256(keccak256("outnumber")) % FIELD_MODULUS);
        panagram.newRound(NEW_ANSWER);

        vm.assertEq(panagram.s_currentRound(), 2);
        vm.assertEq(panagram.s_currentRoundWinner(), address(0));
        vm.assertEq(panagram.s_answer(), NEW_ANSWER);
    }

    function testIncorrectGuessFails() public {
        bytes memory incorrectProof = _getProof(
            bytes32(uint256(keccak256("outnumber")) % FIELD_MODULUS),
            bytes32(uint256(keccak256("outnumber")) % FIELD_MODULUS),
            user
        );
        vm.prank(user);
        vm.expectRevert();
        panagram.makeGuess(incorrectProof); // Should revert since guess is incorrect
    }
}
