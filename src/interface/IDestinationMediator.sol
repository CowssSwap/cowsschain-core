// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IDestinationMediator {
    error BroadcasNotAllowed();
    error CorruptedSolverInput();

    function depositFunds(
        bytes memory json,
        bytes memory signature
    ) external;

    function broadcast(
        uint256 jsonHash
    ) external;
}
