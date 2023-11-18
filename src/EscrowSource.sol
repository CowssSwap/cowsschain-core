// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./SourceReceiver.sol";
import "./utils/OrderData.sol";
import "solmate/tokens/ERC20.sol";
import "./BaseVerifierContract.sol";

contract EscrowSource is BaseVerifierContract, SourceReceiver {
    bytes32 emptyOrderHash;
    mapping(bytes32 => OrderData.Order) jsonHashToOrder;

    /**
     * @dev Init the contract
     * @param _name : name of the authentification contract
     * @param _version : version of the authentifier
     */
    constructor(
        string memory _name,
        string memory _version,
        address mailboxAddress
    ) BaseVerifierContract(_name, _version) SourceReceiver(mailboxAddress) {

        OrderData.Order memory emptyOrder = OrderData.Order({
            jsonHash: bytes32(0),
            expirationTimestamp: 0,
            sourceTokenAddress: address(0),
            sourceAddress: address(0),
            amountSourceToken: 0,
            solverData: OrderData.SolverData({
                solverAddress: address(0),
                stakeAmount: 0
            })
        });
        emptyOrderHash = keccak256(abi.encode(emptyOrder));
    }

    /**
     * @inheritdoc SourceReceiver
     */
    function escrowFunds(
        bytes memory _json,
        bytes memory _signature
    ) external payable override {
        OrderData.FullOrder memory json = abi.decode(
            _json,
            (OrderData.FullOrder)
        );

        address signatureAddress = BaseVerifierContract(address(this))
            .verifySignature(_json, _signature);

        if (signatureAddress != json.sourceAddress) {
            revert JsonAuthentificationError(
                signatureAddress,
                json.sourceAddress
            );
        }

        if (block.chainid != json.sourceChainId) {
            revert InvalidSourceChainError(json.sourceChainId);
        }
        
        if (json.sourceChainId == json.sourceChainId){
            revert DestinationChainSameAsSourceError();
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
            sourceTokenAddress: json.sourceTokenAddress,
            sourceAddress: json.sourceAddress,
            amountSourceToken: json.amountSourceToken,
            solverData: OrderData.SolverData({
                solverAddress: msg.sender,
                stakeAmount: json.stakeAmount
            })
        });

        emit FundsEscrowed(json.expirationTimestamp, json.jsonHash);
    }

    /**
     * @inheritdoc SourceReceiver
     */
    function restituateFunds(bytes32 _jsonHash) external override {
        if (!isOrderSaved(_jsonHash)) {
            revert RestituateOrderOnInexistentOrderError(_jsonHash);
        }

        OrderData.Order memory order = jsonHashToOrder[_jsonHash];
        if (block.timestamp <= order.expirationTimestamp) {
            revert RestituateOrderOnNonExpiredOrderError(_jsonHash);
        }

        address sourceAddress = order.sourceAddress;
        address sourceTokenAddress = order.sourceTokenAddress;
        uint256 amountSourceToken = order.amountSourceToken;
        ERC20(sourceTokenAddress).transferFrom(
            address(this),
            sourceAddress,
            amountSourceToken
        );

        emit FundsRestituated(
            sourceAddress,
            sourceTokenAddress,
            amountSourceToken,
            _jsonHash
        );
    }

    // INTERNAL METHODS:

    /**
     * @dev Function that verifies if the order was saved in the mapping
     * @param _jsonHash : hash of the json signed by the user
     * @return true if the order is already saved in the state
     */
    function isOrderSaved(bytes32 _jsonHash) private view returns (bool) {
        return (_jsonHash != emptyOrderHash);
    }

    /**
     * @dev Call the function internally to complete the order
     * @param _jsonHash : hash of the json struct containing the order information
     */
    function completeOrder(bytes32 _jsonHash) internal override {
        if (!isOrderSaved(_jsonHash)) {
            revert CompleteOrderOnInexistentOrderError(_jsonHash);
        }
        // Remove the order from the mapping

        OrderData.Order memory order = jsonHashToOrder[_jsonHash];
        address payable solverAddress = payable(order.solverData.solverAddress);
        solverAddress.transfer(order.solverData.stakeAmount);

        // unlock the funds from the escrow and transfer them to the solver

        ERC20(order.sourceTokenAddress).transferFrom(
            address(this),
            solverAddress,
            order.amountSourceToken
        );

        // remove order from state

        delete jsonHashToOrder[_jsonHash];

        emit FundReleased(solverAddress, _jsonHash);
    }
}
