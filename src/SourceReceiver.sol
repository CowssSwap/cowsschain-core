// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/interface/IEscrowSource.sol";
import "lib/solmate/src/auth/Owned.sol";

abstract contract SourceReceiver is IEscrowSource, Owned {
    address MAILBOX;
    mapping(uint256 => address) chainIdToMediator;

    error incorrectSender();

    modifier onlyMailbox() {
        require(msg.sender == MAILBOX);
        _;
    }

    constructor(address mailboxAddress) Owned(msg.sender) {
        MAILBOX = mailboxAddress;
    }

    function handle(
        uint32 origin,
        bytes32 sender,
        bytes calldata data
    ) external payable onlyMailbox {
        address senderAddress = address(uint160(uint256(sender)));
        if (!isCorrectSender(origin, senderAddress)) {
            revert incorrectSender();
        }
        bytes32 jsonHash = abi.decode(data, (bytes32));
        completeOrder(jsonHash);
    }

    function completeOrder(bytes32 _jsonHash) internal virtual {}

    function isCorrectSender(
        uint256 chainId,
        address sender
    ) internal view returns (bool) {
        return (chainIdToMediator[chainId] == sender);
    }

    function setMailboxAddress(address mailboxAddress) public onlyOwner {
        MAILBOX = mailboxAddress;
    }

    function setSenderForChainId(
        uint256 chainId,
        address sender
    ) external onlyOwner {
        chainIdToMediator[chainId] = sender;
    }
}
