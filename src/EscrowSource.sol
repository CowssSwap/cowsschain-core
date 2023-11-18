// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./interface/IEscrowSource.sol";
import "./interface/IVerifierContract.sol";
import "./utils/OrderData.sol";
import "solmate/tokens/ERC20.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract EscrowSource is IEscrowSource, IVerifierContract, EIP712 {
    uint256 chainId;
    bytes32 domainSeparator;
    bytes32 emptyOrderHash;

    mapping(bytes32 => OrderData.Order) jsonHashToOrder;

    string constant fullOrderType =
        "FullOrder(uint32 sourceChainId,uint32 destinationChainId,bytes32 jsonHash,uint256 nonce,uint256 amountSourceToken,uint256 minDestinationTokenAmount,uint256 expirationTimestamp,uint256 stakeAmount,address sourceAddress,address destinationAddress,address sourceTokenAddress,address destinationTokenAddress)";

    constructor(
        string memory _name,
        string memory _version,
        uint256 _chainId,
        bytes32 _domainSeparator
    ) EIP712(_name, _version) {
        chainId = _chainId;
        domainSeparator = _domainSeparator;

        OrderData.Order memory emptyOrder = OrderData.Order({
            jsonHash: bytes32(0),
            expirationTimestamp: 0,
            solverData: OrderData.SolverData({
                solverAddress: address(0),
                stakeAmount: 0
            })
        });
        emptyOrderHash = keccak256(abi.encode(emptyOrder));
    }

    
    function verifySignature(
        bytes memory _json,
        bytes memory _signature
    ) external view override returns (address) {

        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    keccak256(abi.encode(fullOrderType)),
                    keccak256(_json)
                )
            )
        );

        address signer = ECDSA.recover(digest, _signature);
        return signer;
    }

    function escrowFunds(
        bytes memory _json,
        bytes memory _signature
    ) external payable override {
        // TODO : verify the signature

        OrderData.FullOrder memory json = abi.decode(
            _json,
            (OrderData.FullOrder)
        );

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

        ERC20(json.sourceTokenAddress).transferFrom(
            json.sourceAddress,
            address(this),
            json.amountSourceToken
        );

        // Write the data into the state of the Escrow Constract

        jsonHashToOrder[json.jsonHash] = OrderData.Order({
            jsonHash: json.jsonHash,
            expirationTimestamp: json.expirationTimestamp,
            solverData: OrderData.SolverData({
                solverAddress: msg.sender,
                stakeAmount: json.stakeAmount
            })
        });

        emit FundsEscrowed(json.expirationTimestamp, json.jsonHash);
    }

    function restituateFunds(bytes32 jsonHash) external override {}

    function completeOrder(bytes32 jsonHash) external override {
        // Remove the order from the mapping
        delete jsonHashToOrder[jsonHash];
    }

    // INTERNAL METHODS:

    /**
    @dev Function that verifies if the order was saved in the mapping 
    @param _jsonHash : hash of the json signed by the user
    @return true if the order is already saved in the state
     */
    function isOrderSaved(bytes32 _jsonHash) private view returns (bool) {
        return (_jsonHash != emptyOrderHash);
    }
}
