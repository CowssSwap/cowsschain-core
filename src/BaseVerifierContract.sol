// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

abstract contract BaseVerifierContract is EIP712 {
    error JsonAuthentificationError(address _signer, address _sourceAddress);
    event SignatureVerified();

    string constant fullOrderType =
        "FullOrder(uint256 sourceChainId,uint256 destinationChainId,uint256 nonce,uint256 amountSourceToken,uint256 minDestinationTokenAmount,uint256 expirationTimestamp,uint256 stakeAmount,uint256 orderIndex,address sourceAddress,address destinationAddress,address sourceTokenAddress,address destinationTokenAddress,bytes data)";

    constructor(
        string memory _name,
        string memory _version
    ) EIP712(_name, _version) {}

    /**
    Function that verifies the signature according to the EIP-712 proposal. 
    @param _json : encoded json file 
    @param _signature : signature of the source address
    @return the address of the signer as well as the hash of the struct
     */

    function verifySignature(
        bytes memory _json,
        bytes memory _signature
    ) external view returns (address, bytes32) {
        OrderData.FullOrder order = abi.decode(_json, (OrderData.FullOrder));
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                // static types should be id. Dynamics types should be encoded static.
                abi.encode(
                    keccak256(abi.encode(fullOrderType)),
                    order.sourceChainId,
                    order.destinationChainId,
                    order.nonce,
                    order.amountSourceToken,
                    order.minDestinationTokenAmount,
                    order.expirationTimestamp,
                    order.stakeAmount,
                    order.orderIndex,
                    order.sourceAddress,
                    order.destinationAddress,
                    order.sourceTokenAddress,
                    order.destinationTokenAddress,
                    keccak256(abi.encode(data))
                )
            )
        );

        address signer = ECDSA.recover(digest, _signature);
        return (signer, digest);
    }
}
