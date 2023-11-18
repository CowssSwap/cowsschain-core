// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import "src/EscrowSource.sol";
import "src/DestinationMediator.sol";

contract BaseDeployer is Script {
    address deployerKey = vm.envUint("DEPLOYER_KEY");
    mapping(uint256 => string) chainIdToRPC;
    mapping(uint256 => address) chainIdToMailbox;
    mapping(uint256 => EscrowSource) chainIdToEscrow;
    mapping(uint256 => DestinationMediator) chainIdToMediator;
    uint256[] chainIds = [5, 10200, 421613, 420, 280, 84531, 80001 ];

    //const rpc={5:"https://ethereum-goerli.publicnode.com",10200:"https://1rpc.io/gnosis ",421613:"https://endpoints.omniatech.io/v1/arbitrum/goerli/public",420:"https://endpoints.omniatech.io/v1/op/goerli/public",280:"https://testnet.era.zksync.dev",84531:"https://endpoints.omniatech.io/v1/base/goerli/public ",80001:"https://endpoints.omniatech.io/v1/matic/mumbai/public"

    modifier setupBroadcaster() {
        vm.startBroadcast(DEPLOYER_KEY);
        _;
    }

    constructor() {
        setupFillData();
    }

    function setupFillData() {
        chainIdToRPC[5] = "https://ethereum-goerli.publicnode.com";
        chainIdToMailbox[5] = 0x49cfd6Ef774AcAb14814D699e3F7eE36Fdfba932;
        chainIdToRPC[10200] = "https://1rpc.io/gnosis";
        //chainIdToMailbox[10200] = //TODO: not available
        chainIdToRPC[421613] = "https://endpoints.omniatech.io/v1/arbitrum/goerli/public";
        chainIdToMailbox[421613] = 0x13dABc0351407d5aAa0A50003a166A73b4febfDc;
        chainIdToRPC[420] = "https://endpoints.omniatech.io/v1/op/goerli/public";
        chainIdToMailbox[420] = 0xB5f021728Ea6223E3948Db2da61d612307945eA2;
        chainIdToRPC[280] = "https://testnet.era.zksync.dev";
        //chainIdToMailbox[280] =  //TODO: not available
        chainIdToRPC[84531] = "https://endpoints.omniatech.io/v1/base/goerli/public";
        chainIdToMailbox[84531] = 0x58483b754Abb1E8947BE63d6b95DF75b8249543A;
        chainIdToRPC[80001] = "https://endpoints.omniatech.io/v1/matic/mumbai/public";
        chainIdToMailbox[80001] = 0x2d1889fe5B092CD988972261434F7E5f26041115;
        //chainIdToRPC[280] = "https://ethereum-goerli.publicnode.com";
        //chainIdToRPC[280] = "https://ethereum-goerli.publicnode.com";
        //TODO: add Neon EVM
        
    }

    function deploy() setupBroadcaster {
        //deploy every contract
        for (uint i; i<chainIds.length; ++i){
            uint256 chainId = chainIds[i];
            vm.createSelectFork(chainIdToRPC[chainId]);
            address mailboxAddress = chainIdToMailbox[chainId];
            chainIdToEscrow[chainId] = new EscrowSource("cowsswap", "69.420", mailboxAddress);
            chainIdToMediator[chainId] = new DestinationMediator("cowsswap", "69.420", mailboxAddress);
        }
        //fill the contracts mappings
        for (uint i; i<chainIds.length; ++i){
            uint256 mainChainId = chainIds[i];
            address escrowAddress = address(chainIdToEscrow[mainChainId]);
            address mediatorAddress = address(chainIdToMediator[mainChainId]);
            for (uint j; j<chainIds.length; ++j){
                address subChainId = chainIds[j];
                vm.createSelectFork(chainIdToRPC[subChainId]);
                chainIdToEscrow[subChainId].setSenderForChainId(subChainId, mediatorAddress);
                chainIdToMediator[subChainId].setReceiverForChainId(subChainId, escrowAddress);
            }
        }
    }
}