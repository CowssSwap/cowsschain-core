// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

library OrderData {
    struct FullOrder {
        uint256 sourceChainId;
        uint256 destinationChainId;
        uint256 nonce;
        uint256 amountSourceToken;
        uint256 minDestinationTokenAmount;
        uint256 expirationTimestamp;
        uint256 stakeAmount;
        uint256 orderIndex;
        address sourceAddress;
        address destinationAddress;
        address sourceTokenAddress;
        address destinationTokenAddress;
        bytes data;
    }

    struct Order {
        bytes32 jsonHash;
        uint256 expirationTimestamp;
        address sourceAddress;
        address sourceTokenAddress;
        uint256 amountSourceToken;
        SolverData solverData;
    }

    struct SolverData {
        address solverAddress;
        uint256 stakeAmount;
    }
}
