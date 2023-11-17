// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

library OrderData { 
    struct Order {
        uint256 jsonHash;
        uint256 expirationTimestamp; 
        SolverData solverData;
    }

    struct SolverData { 
        uint256 stakeAmount; 
        
        
    }
}