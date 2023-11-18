// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IVerifierContract {
    function verifySignature(
        bytes memory _json,
        bytes memory _signature
    ) external view returns (address);
}
