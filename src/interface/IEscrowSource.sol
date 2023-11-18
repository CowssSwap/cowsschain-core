// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IEscrowSource {
    // Errors
    error InvalidSourceChainError(uint256 _chainId);
    error DestinationChainSameAsSourceError();
    error OrderAlreadySubmittedError(bytes32 _jsonHash);
    error OrderExpired(uint256 _blockTimestamp);
    error StakeInsufficientError(uint256 _stakeAmount);
    error CompleteOrderOnInexistentOrderError(bytes32 _jsonHash);
    error RestituateOrderOnInexistentOrderError(bytes32 _jsonHash);
    error RestituateOrderOnNonExpiredOrderError(bytes32 _jsonHash);

    // Events
    event FundsEscrowed(uint256 _expirationTimestamp, bytes32 _jsonHash);
    event FundReleased(address _solverAddress, bytes32 _jsonHash);
    event FundsRestituated(
        address _sourceAddress,
        address _sourceTokenAddress,
        uint256 _amountSourceToken,
        bytes32 _jsonHash
    );

    /**
     * The function shall verify the json's autheticity, that the order was not already submitted.
     * Then, check the validity of the source chain id and escrow the user's tokens.
     */
    function escrowFunds(
        bytes memory _json,
        bytes memory _signature
    ) external payable;

    /**
     * The function shall return the locked funds of the solver to the owner address
     */
    function restituateFunds(bytes32 _jsonHash) external;
}
