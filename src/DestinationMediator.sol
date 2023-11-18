// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./abstract/DestinationSender.sol";

contract DestinationMediator is DestinationSender {
    bytes32 domainSeparator;

    constructor (address mailboxAddress) DestinationSender(mailboxAddress) {
        setMailboxAddress(mailboxAddress);
    }

    function broadcast(bytes32 jsonHash) public override {}

    function depositFunds(bytes memory json, bytes memory signature) external override {}
}
