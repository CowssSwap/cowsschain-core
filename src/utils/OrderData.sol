// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

library OrderData { 

    struct FullOrder {
        uint32 sourceChainId;
        uint32 destinationChainId;
        uint256 jsonHash;
        uint256 nonce;
        uint256 amountSourceToken;
        uint256 minDestinationTokenAmount;
        uint256 expirationTimestamp;
        address sourceAddress;
        address destinationAddress;
        address sourceTokenAddress;
        address destinationTokenAddress;
    }

    struct Order {
        uint256 jsonHash;
        uint256 expirationTimestamp; 
        SolverData solverData;
    }

    struct SolverData { 
        uint256 stakeAmount; 
    }
}