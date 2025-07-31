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

    // 1. Test someone receive NFT 0 if they guess correctly first
    function testCorrectGuessPasses() public {
        vm.prank(user);
        panagram.makeGuess(proof)
    }

    // 2. Test someone receive NFT 1 if they guess correctly but not first

    // 3. Test we can start a new round
}
