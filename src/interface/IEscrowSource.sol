// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IEscrowSource {
    // Errors
    error JsonAuthentificationError();
    error InvalidSourceChainError(uint32 _chainId);
    error OrderAlreadySubmittedError(bytes32 _jsonHash);
    error OrderExpired(uint256 _blockTimestamp);
    error StakeInsufficientError(uint256 _stakeAmount);

    // Events

    event FundsEscrowed(uint256 expirationTimestamp, bytes32 jsonHash);
    event FundReleased(address solverAddress, bytes32 jsonHash);

    /**
     * The function shall verify the json's autheticity, that the order was not already submitted.
     * Then, check the validity of the source chain id and escrow the user's tokens.
     */
    function escrowFunds(bytes memory _json, bytes memory _signature) external payable;

    /**
     * The function shall return the locked funds of the solver to the owner address
     */
    function restituateFunds(bytes32 _jsonHash) external;

    /**
     * The stake should be repaid.
     */
    function completeOrder(bytes32 _jsonHash) external;
}
