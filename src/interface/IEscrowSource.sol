// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IEscrowSource {

    error JsonAuthentificationError();

    /**
    The function shall verify the json's autheticity, that the order was not already submitted.
    Then, check the validity of the source chain id and escrow the user's tokens. 
     */
    function escrowFunds(bytes memory json, bytes memory signature) external; 
    /**
    The function shall return the locked funds of the solver to the owner address
     */
    function restituateFunds(uint256 jsonHash) external; 
    /**
    The stake should be repaid. 
     */
    function completeOrder(uint256 jsonHash) external;

}