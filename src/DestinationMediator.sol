// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./interface/IDestinationMediator.sol";

contract DestinationMediator is IDestinationMediator {
    mapping(uint256 => bool) isOrderBroadcasted;


    function broadcast(bytes32 jsonHash) external payable override {}

    function depositFunds(bytes memory json, bytes memory signature) external override {}
}
