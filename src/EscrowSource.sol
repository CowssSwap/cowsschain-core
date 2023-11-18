// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./interface/IEscrowSource.sol";
import "./utils/OrderData.sol";
import "solmate/tokens/ERC20.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";

contract EscrowSource is IEscrowSource, EIP712 {
    uint32 chainId;
    bytes32 domainSeparator;
    bytes32 emptyOrderHash;

    mapping(bytes32 => OrderData.Order) jsonHashToOrder;

    constructor(string memory _name, string memory _version, uint32 _chainId, bytes32 _domainSeparator)
        EIP712(_name, _version)
    {
        chainId = _chainId;
        domainSeparator = _domainSeparator;

        OrderData.Order memory emptyOrder = OrderData.Order({
            jsonHash: bytes32(0),
            expirationTimestamp: 0,
            solverData: OrderData.SolverData({solverAddress: address(0), stakeAmount: 0})
        });
        emptyOrderHash = keccak256(abi.encode(emptyOrder));
    }

    function escrowFunds(bytes memory _json, bytes memory _signature) external payable override {
        // TODO : verify the signature

        OrderData.FullOrder memory json = abi.decode(_json, (OrderData.FullOrder));

        if (chainId != json.sourceChainId) {
            revert InvalidSourceChainError(json.sourceChainId);
        }

        if (json.expirationTimestamp < block.timestamp) {
            revert OrderExpired(block.timestamp);
        }

        if (isOrderSaved(json.jsonHash)) {
            revert OrderAlreadySubmittedError(json.jsonHash);
        }

        if (msg.value < json.stakeAmount) {
            revert StakeInsufficientError(json.stakeAmount);
        }

        // Transfer the source tokens from the user's wallet to escrow

        ERC20(json.sourceTokenAddress).transferFrom(json.sourceAddress, address(this), json.amountSourceToken);

        // Write the data into the state of the Escrow Constract

        jsonHashToOrder[json.jsonHash] = OrderData.Order({
            jsonHash: json.jsonHash,
            expirationTimestamp: json.expirationTimestamp,
            solverData: OrderData.SolverData({solverAddress: msg.sender, stakeAmount: json.stakeAmount})
        });

        emit FundsEscrowed(json.expirationTimestamp, json.jsonHash);
    }

    function restituateFunds(bytes32 jsonHash) external override {}

    function completeOrder(bytes32 jsonHash) external override {
        // Remove the order from the mapping
        delete jsonHashToOrder[jsonHash];
    }

    // INTERNAL METHODS:

    function isOrderSaved(bytes32 _jsonHash) private view returns (bool) {
        return (_jsonHash != emptyOrderHash);
    }
}
