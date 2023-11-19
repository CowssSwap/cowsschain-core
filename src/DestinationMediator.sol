// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./BaseVerifierContract.sol";
import "./utils/OrderData.sol";
import "./DestinationSender.sol";

import "solmate/tokens/ERC20.sol";

contract DestinationMediator is BaseVerifierContract, DestinationSender {
    
    mapping(uint256 => bool) isOrderBroadcasted;

    /**
     * @dev Init the contract
     * @param _name : name of the authentification contract
     * @param _version : version of the authentifier
     */
    constructor(
        string memory _name,
        string memory _version,
        address _mailboxAddress
    )
        BaseVerifierContract(_name, _version)
        DestinationSender(_mailboxAddress)
    {}

    function depositFunds(
        bytes memory _json,
        bytes memory _signature
    ) external override {
        OrderData.FullOrder memory order = abi.decode(
            _json,
            (OrderData.FullOrder)
        );

        // Signature verification
        (address signer, bytes32 digest) = BaseVerifierContract(address(this))
            .verifySignature(_json, _signature);

        address sourceAddress = order.sourceAddress;
        if (signer != sourceAddress) {
            revert JsonAuthentificationError(signer, sourceAddress);
        }

        emit SignatureVerified();

        // Retrieve the funds from the solver and transfer to the destination address
        ERC20(order.destinationTokenAddress).transferFrom(
            msg.sender, // address of the solver
            order.destinationAddress,
            order.minDestinationTokenAmount
        );

        broadcast(digest);
    }
}
