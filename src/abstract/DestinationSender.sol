pragma solidity >=0.8.0;

import "src/interface/IMailbox.sol";
import "src/interface/IDestinationMediator.sol";
import "lib/solmate/src/auth/Owned.sol";

abstract contract DestinationSender is IDestinationMediator, Owned {
    IMailbox mailbox;
    mapping(uint256 => address) internal chainIdToEscrow;

    mapping(bytes32 => uint256) public orderCompleted;

    constructor (address mailboxAddress) Owned(msg.sender) {
        setMailboxAddress(mailboxAddress);
    }

    //TODO: ask for msg value
    function broadcast(bytes32 _jsonHash) public {
        if (isCompleted(_jsonHash)) {
            revert BroadcasNotAllowed();
        }
        //encoding the jsonHash
        bytes memory jsonHashBytes = abi.encode(_jsonHash);
        uint256 sourceChainId = getSourceChainId(_jsonHash);
        bytes32 recipientAddress = bytes32(uint256(uint160(chainIdToEscrow[sourceChainId])));
        bytes32 returned = mailbox.dispatch(uint32(sourceChainId), recipientAddress, jsonHashBytes);
        //TODO: check how to use returned
    }

    function isCompleted(bytes32 _jsonHash) public view returns(bool){
        return (orderCompleted[_jsonHash] != block.chainid);
    }

    // function used in depositFunds
    function setCompleted(bytes32 _jsonHash, uint256 sourceChainID) internal {
        orderCompleted[_jsonHash] = sourceChainID;
    }

    function getSourceChainId(bytes32 _jsonHash) internal view returns(uint256){
        return orderCompleted[_jsonHash];
    }

    function setMailboxAddress(address mailboxAddress) public onlyOwner {
        mailbox = IMailbox(mailboxAddress);
    }

    function setReceiverForChainId(uint256 chainId, address receiver) external onlyOwner {
        chainIdToEscrow[chainId] = receiver;
    }
}