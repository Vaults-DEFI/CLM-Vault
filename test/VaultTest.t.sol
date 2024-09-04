// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../src/Vault.sol";
import "../src/StratManager.sol";
import "../src/StrategyPassiveManagerSushi.sol";

contract VaultTest is Test {
    using SafeERC20 for IERC20;

    Vault public vault;
    StrategyPassiveManagerSushi public strategyPassiveManagerSushi;
    StratManager public stratManager;

    uint256 rbtcAmount = 10 * 10 ** 18;
    uint256 rusdtAmount = 100000 * 10 ** 6;

    address RBTC = vm.envAddress("RBTC");
    address RUSDT = vm.envAddress("RUSDT");
    address USER = vm.envAddress("USER");
    address USER2 = vm.envAddress("USER2");

    function setUp() public {
        vault = new Vault("CLM token", "CLM");
        console.log("vault contract address", address(vault));

        // Define the common addresses
        StratManager.CommonAddresses memory commonAddresses = StratManager
            .CommonAddresses({
                vault: address(vault),
                unirouter: 0x1400feFD6F9b897970f00Df6237Ff2B8b27Dc82C
            });

        strategyPassiveManagerSushi = new StrategyPassiveManagerSushi(
            0xC0B92Ac272D427633c36fd03dc104a2042B3a425,
            0xe43ca1Dee3F0fc1e2df73A0745674545F11A59F5,
            60,
            commonAddresses
        );
        console.log(
            "strategyPassiveManagerSushi contract address",
            address(strategyPassiveManagerSushi)
        );
        console.log("test contract address", address(this));
        vault.setStrategyAddress(address(strategyPassiveManagerSushi));
        strategyPassiveManagerSushi.setDeviation(5);
    }

    function testDeposit() public {
        vm.startPrank(USER);
        deal(RBTC, USER, rbtcAmount);
        deal(RUSDT, USER, rusdtAmount);
        vm.stopPrank();

        console.log("RBTC amount of USER", IERC20(RBTC).balanceOf(USER));
        console.log("RUSDT amount of USER", IERC20(RUSDT).balanceOf(USER));
        console.log("Let's preview the deposit");
        (
            uint256 shares,
            uint256 amount0,
            uint256 amount1,
            uint256 fee0,
            uint256 fee1
        ) = vault.previewDeposit(rbtcAmount, rusdtAmount);

        console.log("shares", shares);
        console.log("amount0", amount0);
        console.log("amount1", amount1);
        console.log("fee0", fee0);
        console.log("fee1", fee1);

        console.log("before deposit USER shares", vault.balanceOf(USER));
        // strategyPassiveManagerSushi.setDeviation(5);
        // strategyPassiveManagerSushi.setTwapInterval(120);
        vm.startPrank(USER);

        IERC20(RBTC).approve(address(vault), rbtcAmount);
        IERC20(RUSDT).approve(address(vault), rusdtAmount);
        console.log("..", strategyPassiveManagerSushi.twap());
        vault.deposit(rbtcAmount, rusdtAmount, shares);

        vm.stopPrank();

        console.log("after deposit USER shares", vault.balanceOf(USER));
        console.log(
            "after deposit RBTC amount of USER",
            IERC20(RBTC).balanceOf(USER)
        );
        console.log(
            "after deposit RUSDT amount of USER",
            IERC20(RUSDT).balanceOf(USER)
        );

        // console.log("user2 deposits.................");
        // vm.startPrank(USER2);
        // deal(RBTC, USER2, rbtcAmount);
        // deal(RUSDT, USER2, rusdtAmount);
        // vm.stopPrank();

        // console.log("RBTC amount of USER2", IERC20(RBTC).balanceOf(USER2));
        // console.log("RUSDT amount of USER2", IERC20(RUSDT).balanceOf(USER2));
        // console.log("Let's preview the deposit");
        // (shares, amount0, amount1, fee0, fee1) = vault.previewDeposit(
        //     rbtcAmount,
        //     rusdtAmount
        // );

        // console.log("shares", shares);
        // console.log("amount0", amount0);
        // console.log("amount1", amount1);
        // console.log("fee0", fee0);
        // console.log("fee1", fee1);

        // console.log("before deposit USER2 shares", vault.balanceOf(USER2));
        // // strategyPassiveManagerSushi.setDeviation(5);
        // // strategyPassiveManagerSushi.setTwapInterval(120);
        // vm.startPrank(USER2);

        // IERC20(RBTC).approve(address(vault), rbtcAmount);
        // IERC20(RUSDT).approve(address(vault), rusdtAmount);

        // vault.deposit(rbtcAmount, rusdtAmount, shares);

        // vm.stopPrank();

        // console.log("after deposit USER2 shares", vault.balanceOf(USER2));
        // console.log("after deposit USER shares", vault.balanceOf(USER));
        // console.log(
        //     "after deposit RBTC amount of USER2",
        //     IERC20(RBTC).balanceOf(USER2)
        // );
        // console.log(
        //     "after deposit RUSDT amount of USER2",
        //     IERC20(RUSDT).balanceOf(USER2)
        // );
        console.log("..", strategyPassiveManagerSushi.twap());
    }
}
