// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

abstract contract BaseVerifierContract is EIP712{

    string constant fullOrderType =
        "FullOrder(uint32 sourceChainId,uint32 destinationChainId,bytes32 jsonHash,uint256 nonce,uint256 amountSourceToken,uint256 minDestinationTokenAmount,uint256 expirationTimestamp,uint256 stakeAmount,address sourceAddress,address destinationAddress,address sourceTokenAddress,address destinationTokenAddress)";
    constructor(
        string memory _name,
        string memory _version 
    ) EIP712(_name, _version) {}

    function verifySignature(
        bytes memory _json,
        bytes memory _signature
    ) external view returns (address) {
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
}