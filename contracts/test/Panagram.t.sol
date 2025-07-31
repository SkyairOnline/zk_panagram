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

    function _getProof(bytes32 guess, bytes32 correctAnswer) internal returns (bytes memory _proof) {
        uint256 NUM_ARGS = 5;
        string[] memory inputs = new string[](NUM_ARGS);
        inputs[0] = "npx";
        inputs[1] = "tsx";
        inputs[2] = "js-scripts/generateProof.ts";
        inputs[3] = vm.toString(guess);
        inputs[4] = vm.toString(correctAnswer);

        bytes memory encodedProof = vm.ffi(inputs);
        _proof = abi.decode(encodedProof, (bytes));
        console.logBytes(_proof);
    }

    // 1. Test someone receive NFT 0 if they guess correctly first
    function testCorrectGuessPasses() public {
        vm.prank(user);
        bytes memory proof = _getProof(ANSWER, ANSWER);
        panagram.makeGuess(proof);
        vm.assertEq(panagram.balanceOf(user, 0), 1);
        vm.assertEq(panagram.balanceOf(user, 1), 0);

        vm.prank(user);
        vm.expectRevert();
        panagram.makeGuess(proof); // Should revert since already guessed correctly
    }

    // 2. Test someone receive NFT 1 if they guess correctly but not first

    // 3. Test we can start a new round
}
