// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script, console} from "forge-std/Script.sol";
import "../src/Vault.sol";
import "../src/StrategyPassiveManagerSushi.sol";
import "../src/StratManager.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        Vault vault = new Vault("CLM Token", "CLM");
        console.log("vault contract address", address(vault));
        // Define the common addresses
        StratManager.CommonAddresses memory commonAddresses = StratManager
            .CommonAddresses({
                vault: address(vault),
                unirouter: 0x1400feFD6F9b897970f00Df6237Ff2B8b27Dc82C
            });

        StrategyPassiveManagerSushi strategyPassiveManagerSushi = new StrategyPassiveManagerSushi(
                0xC0B92Ac272D427633c36fd03dc104a2042B3a425,
                0xe43ca1Dee3F0fc1e2df73A0745674545F11A59F5,
                60,
                commonAddresses
            );

        console.log(
            "strategyPassiveManagerSushi contract address",
            address(strategyPassiveManagerSushi)
        );
        vault.setStrategyAddress(address(strategyPassiveManagerSushi));
        console.log("SET");
        vm.stopBroadcast();
    }
}
