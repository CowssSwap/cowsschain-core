pragma solidity >=0.8.0;

import "lib/hyperlane-monorepo.git/solidity/contracts/interfaces/IMailbox.sol";
import "src/interface/IDestinationMediator.sol";
import "lib/solmate/src/auth/Owned.sol";

abstract contract DestinationSender is IDestinationMediator, Owned {
    IMailbox mailbox;
    mapping(uint256 => address) internal chainIdToEscrow;

    mapping(bytes32 => uint256) public orderCompleted;

    constructor(address mailboxAddress) Owned(msg.sender) {
        setMailboxAddress(mailboxAddress);
    }

    function broadcast(bytes32 _jsonHash) public payable virtual {
        if (isCompleted(_jsonHash)) {
            revert BroadcasNotAllowed();
        }
        //encoding the jsonHash
        bytes memory jsonHashBytes = abi.encode(_jsonHash);
        uint256 sourceChainId = getSourceChainId(_jsonHash);
        bytes32 recipientAddress = bytes32(
            uint256(uint160(chainIdToEscrow[sourceChainId]))
        );

        //TODO: use quote dispatch to know how much we should pay
        uint256 fee = mailbox.quoteDispatch(uint32(sourceChainId), recipientAddress, jsonHashBytes);
        mailbox.dispatch{value: fee}(uint32(sourceChainId), recipientAddress, jsonHashBytes);
    }

    function isCompleted(bytes32 _jsonHash) public view returns (bool) {
        return (orderCompleted[_jsonHash] != block.chainid);
    }

    // function used in depositFunds
    function setCompleted(bytes32 _jsonHash, uint256 sourceChainID) internal {
        orderCompleted[_jsonHash] = sourceChainID;
    }

    function getSourceChainId(
        bytes32 _jsonHash
    ) internal view returns (uint256) {
        return orderCompleted[_jsonHash];
    }

    function setMailboxAddress(address mailboxAddress) public onlyOwner {
        mailbox = IMailbox(mailboxAddress);
    }

    function setReceiverForChainId(
        uint256 chainId,
        address receiver
    ) external onlyOwner {
        chainIdToEscrow[chainId] = receiver;
    }
}
