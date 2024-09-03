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

    uint256 wethAmount = 10 * 10 ** 18;
    uint256 usdcAmount = 100000 * 10 ** 6;

    address WETH = vm.envAddress("WETH");
    address USDC = vm.envAddress("USDC");
    address USER = vm.envAddress("USER");

    function setUp() public {
        vault = new Vault("CLM token", "CLM");
        console.log("vault contract address", address(vault));

        // Define the common addresses
        StratManager.CommonAddresses memory commonAddresses = StratManager
            .CommonAddresses({
                vault: address(vault),
                unirouter: 0x8A21F6768C1f8075791D08546Dadf6daA0bE820c
            });

        strategyPassiveManagerSushi = new StrategyPassiveManagerSushi(
            0xf3Eb87C1F6020982173C908E7eB31aA66c1f0296,
            0x0524E833cCD057e4d7A296e3aaAb9f7675964Ce1,
            60,
            commonAddresses
        );
        console.log(
            "strategyPassiveManagerSushi contract address",
            address(strategyPassiveManagerSushi)
        );
        console.log("test contract address", address(this));
        vault.setStrategyAddress(address(strategyPassiveManagerSushi));
    }

    function testDeposit() public {
        vm.startPrank(USER);
        deal(WETH, USER, wethAmount);
        deal(USDC, USER, usdcAmount);
        vm.stopPrank();

        console.log("WETH amount of USER", IERC20(WETH).balanceOf(USER));
        console.log("USDC amount of USER", IERC20(USDC).balanceOf(USER));
        console.log("Let's preview the deposit");
        (
            uint256 shares,
            uint256 amount0,
            uint256 amount1,
            uint256 fee0,
            uint256 fee1
        ) = vault.previewDeposit(wethAmount, usdcAmount);

        console.log("shares", shares);
        console.log("amount0", amount0);
        console.log("amount1", amount1);
        console.log("fee0", fee0);
        console.log("fee1", fee1);

        console.log("before deposit USER shares", vault.balanceOf(USER));
        // strategyPassiveManagerSushi.setDeviation(5);
        // strategyPassiveManagerSushi.setTwapInterval(120);
        vm.startPrank(USER);

        IERC20(WETH).approve(address(vault), wethAmount);
        IERC20(USDC).approve(address(vault), usdcAmount);

        vault.deposit(1 * 10 ** 18, 100 * 10 ** 6, (shares * 3) / 1000);

        vm.stopPrank();

        console.log("after deposit USER shares", vault.balanceOf(USER));
        console.log(
            "after deposit WETH amount of USER",
            IERC20(WETH).balanceOf(USER)
        );
        console.log(
            "after deposit USDC amount of USER",
            IERC20(USDC).balanceOf(USER)
        );
    }
}
