// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IDestinationMediator {

    error BroadcasNotAllowed();
    error JsonAuthentificationError();

    /**
    Function verifies the validity of the json. Then, the function retrieves the funds from the solver

     */
    function depositFunds(
        bytes memory json,
        bytes memory signature
    ) external;

    /**
    Broadcast the message to the bridge if it has not been broadcasted
     */
    function broadcast(
        uint256 jsonHash
    ) external;

}
