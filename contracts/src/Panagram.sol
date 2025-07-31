// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVerifier} from "./Verifier.sol";

contract Panagram is ERC1155, Ownable {
    IVerifier public verifier;

    // Event
    event Panagram__VerifierUpdated(IVerifier verifier);

    constructor(
        IVerifier _verifier
    )
        ERC1155(
            "ipfs://bafybeicqfc4ipkle34tgqv3gh7gccwhmr22qdg7p6k6oxon255mnwb6csi/{id}.json"
        )
        Ownable(msg.sender)
    {
        verifier = _verifier;
    }

    // function to create a new round

    // function to allow users to submit a guess

    // set a new verifier
    function setVerifier(IVerifier _verifier) external onlyOwner {
        verifier = _verifier;
        emit Panagram__VerifierUpdated(_verifier);
    }
}
