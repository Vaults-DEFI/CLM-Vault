// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";
import {StratManager} from "../src/StratManager.sol";
import {StrategyPassiveManagerSushi} from "../src/StrategyPassiveManagerSushi.sol";
import {console} from "forge-std/Test.sol";

contract DeployContracts is Script {
    Vault public vault;
    StrategyPassiveManagerSushi public strategyPassiveManagerSushi;
    StratManager public stratManager;

    function run() external {
        // Load environment variables

        vm.startBroadcast();

        // Deploy Vault contract
        vault = new Vault("CLM token", "CLM");

        // Define common addresses
        StratManager.CommonAddresses memory commonAddresses = StratManager
            .CommonAddresses({
                vault: address(vault),
                unirouter: 0x1400feFD6F9b897970f00Df6237Ff2B8b27Dc82C
            });

        // Deploy StrategyPassiveManagerSushi contract
        strategyPassiveManagerSushi = new StrategyPassiveManagerSushi(
            0xC0B92Ac272D427633c36fd03dc104a2042B3a425, // want address
            0xe43ca1Dee3F0fc1e2df73A0745674545F11A59F5, // fee recipient
            60, // interval
            commonAddresses
        );

        // Set strategy in Vault contract
        vault.setStrategyAddress(address(strategyPassiveManagerSushi));

        vm.stopBroadcast();
        console.log(
            "addresses of vault and strategyPassiveManagerSushi : ",
            address(vault),
            address(strategyPassiveManagerSushi)
        );
    }
}
