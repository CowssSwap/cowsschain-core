// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IDestinationMediator {
    error BroadcasNotAllowed();
    error JsonAuthentificationError();

    /**
     * Function verifies the validity of the json. Then, the function retrieves the funds from the solver
     * and store the source chainId into the orderCompleted mapping.
     */
    function depositFunds(bytes memory _json, bytes memory _signature) external;

    /**
     * Broadcast the message to the bridge if it has not been broadcasted
     */
    function broadcast(bytes32 _jsonHash) external;
}
