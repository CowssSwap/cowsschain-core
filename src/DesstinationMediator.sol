// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./interface/IDestinationMediator.sol";

contract DestinationMediator is IDestinationMediator {
    mapping(uint256 => bool) isOrderBroadcasted;
    bytes32 domainSeparator;

    function broadcast(bytes32 jsonHash) external override {}

    function depositFunds(bytes memory json, bytes memory signature) external override {}
}
