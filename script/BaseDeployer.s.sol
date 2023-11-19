// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import "src/EscrowSource.sol";
import "src/DestinationMediator.sol";
import "lib/forge-std/src/console.sol";

contract BaseDeployer is Script {
    uint256 DEPLOYER_KEY = vm.envUint("DEPLOYER_KEY");
    mapping(uint256 => string) chainIdToRPC;
    mapping(uint256 => address) chainIdToMailbox;
    mapping(uint256 => EscrowSource) chainIdToEscrow;
    mapping(uint256 => DestinationMediator) chainIdToMediator;
    mapping(uint256 => uint256) chainIdToFork;
    uint256[] chainIds = [5, 10200, 421613, 420, 280, 84531, 80001, 1442, 59140, 44787, 534351];

    modifier broadcast(uint256 pk) {
        vm.startBroadcast(pk);

        _;

        vm.stopBroadcast();
    }

    constructor() {
        setupFillData();
    }

    function setupFillData() public {
        chainIdToRPC[5] = "https://ethereum-goerli.publicnode.com";
        chainIdToMailbox[5] = 0x49cfd6Ef774AcAb14814D699e3F7eE36Fdfba932;
        chainIdToRPC[10200] = "https://gnosis-chiado.publicnode.com";
        //chainIdToMailbox[10200] = //TODO: not available
        chainIdToRPC[421613] = "https://arbitrum-goerli.publicnode.com";
        chainIdToMailbox[421613] = 0x13dABc0351407d5aAa0A50003a166A73b4febfDc;
        chainIdToRPC[420] = "https://optimism-goerli.publicnode.com";
        chainIdToMailbox[420] = 0xB5f021728Ea6223E3948Db2da61d612307945eA2;
        chainIdToRPC[280] = "https://testnet.era.zksync.dev";
        //chainIdToMailbox[280] =  //TODO: not available
        chainIdToRPC[84531] = "https://base-goerli.publicnode.com";
        chainIdToMailbox[84531] = 0x58483b754Abb1E8947BE63d6b95DF75b8249543A;
        chainIdToRPC[80001] = "https://polygon-mumbai-bor.publicnode.com";
        chainIdToMailbox[80001] = 0x2d1889fe5B092CD988972261434F7E5f26041115;
        chainIdToRPC[1442] = "https://rpc.public.zkevm-test.net";
        chainIdToMailbox[1442] = 0x598facE78a4302f11E3de0bee1894Da0b2Cb71F8;
        chainIdToRPC[59140] = "https://rpc.goerli.linea.build";
        //chainIdToMailbox[59140] = ;
        chainIdToRPC[44787] = "https://alfajores-forno.celo-testnet.org";
        //chainIdToMailbox[44787] = ;
        chainIdToRPC[245022926] = "https://devnet.neonevm.org";
        //chainIdToMailbox[245022926] = ;
        chainIdToRPC[534351] = "https://sepolia-rpc.scroll.io";
        chainIdToMailbox[534351] = 0x3C5154a193D6e2955650f9305c8d80c18C814A68;
        
        
    }

    function deploy() public {
        //deploy every contract
        for (uint i; i<chainIds.length; ++i){
            uint256 chainId = chainIds[i];
            chainIdToFork[chainId] = vm.createSelectFork(chainIdToRPC[chainId]);
            console.log("start broadcasting");
            vm.startBroadcast(DEPLOYER_KEY);
            console.log("deploying");
            oneChainDeploy(chainId);
            //address mailboxAddress = chainIdToMailbox[chainId];
            console.log(address(chainIdToEscrow[chainId]));
            vm.stopBroadcast();
        }
        //fill the contracts mappings
        for (uint i; i<chainIds.length; ++i){
            uint256 mainChainId = chainIds[i];
            address escrowAddress = address(chainIdToEscrow[mainChainId]);
            address mediatorAddress = address(chainIdToMediator[mainChainId]);
            for (uint j; j<chainIds.length; ++j){
                uint256 subChainId = chainIds[j];
                vm.selectFork(chainIdToFork[subChainId]);
                console.log("starting broadcast in the double loop");
                vm.startBroadcast(DEPLOYER_KEY);
                chainIdToEscrow[subChainId].setSenderForChainId(subChainId, mediatorAddress);
                chainIdToMediator[subChainId].setReceiverForChainId(subChainId, escrowAddress);
                vm.stopBroadcast();
            }
        }
    }

    function checkBalance() public {
        vm.prank(0x17e12400f50592e060cfD2d80c9614a36375df61, 0x17e12400f50592e060cfD2d80c9614a36375df61);
        for (uint i; i<chainIds.length; ++i){
            uint256 chainId = chainIds[i];
            console.log("checking balance on : ");
            console.log(chainId);
            console.log("RPC URL is ", chainIdToRPC[chainId]);
            vm.createSelectFork(chainIdToRPC[chainId]);
            console.log(block.chainid);
            uint256 balance = address(0x17e12400f50592e060cfD2d80c9614a36375df61).balance;
            console.log(balance);
        }
    }

    function oneChainDeploy(uint256 chainId) public {
            //vm.createSelectFork(chainIdToRPC[chainId]);
            address mailboxAddress = chainIdToMailbox[chainId];
            chainIdToEscrow[chainId] = new EscrowSource("cowsschain", "69.420", mailboxAddress);
            console.log("deployed escrow on :");
            console.log(chainId);
            console.log(" with address: ");
            console.log(address(chainIdToEscrow[chainId]));
            chainIdToMediator[chainId] = new DestinationMediator("cowsschain", "69.420", mailboxAddress);
            console.log("deployed mediator on :");
            console.log(chainId);
            console.log(" with address: ");
            console.log(address(chainIdToMediator[chainId]));
    }

    function run() public {
        setupFillData();
        //checkBalance();
        //oneChainDeploy();
        deploy();
    }
}