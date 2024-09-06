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

    uint256 wethAmount = 1 * 10 ** 18;
    uint256 usdcAmount = 100 * 10 ** 6;

    uint256 wrbtcAmount = 10 * 10 ** 18;
    uint256 usdtAmount = 5 * 10 ** 18;
    IERC20 weth;
    IERC20 usdc;

    address WETH = vm.envAddress("WETH");
    address USDC = vm.envAddress("USDC");
    address WRBTC = vm.envAddress("WRBTC");
    address RUSDT = vm.envAddress("RUSDT");
    address USER = vm.envAddress("USER");
    address USER1 = vm.envAddress("USER2");
    address USER2 = vm.envAddress("USER3");

    function setUp() public {
        vault = new Vault("CLM token", "CLM");
        // console.log("vault contract address", address(vault));

        // Define the common addresses
        weth = IERC20(WETH);
        usdc = IERC20(USDC);

        StratManager.CommonAddresses memory commonAddresses = StratManager
            .CommonAddresses({
                vault: address(vault),
                unirouter: 0x8A21F6768C1f8075791D08546Dadf6daA0bE820c //for ARB Mainnet
                // unirouter: 0xE592427A0AEce92De3Edee1F18E0157C05861564  //for ETH mainnet
                // unirouter: 0x1400feFD6F9b897970f00Df6237Ff2B8b27Dc82C //for rootstock mainnet
            });

        strategyPassiveManagerSushi = new StrategyPassiveManagerSushi(
            //for arb mainnet
            0xf3Eb87C1F6020982173C908E7eB31aA66c1f0296,
            0x0524E833cCD057e4d7A296e3aaAb9f7675964Ce1,
            //for Eth-mainnet
            // 0x35644Fb61aFBc458bf92B15AdD6ABc1996Be5014, //WETH-USDC pool
            // 0x64e8802FE490fa7cc61d3463958199161Bb608A7, //quoterV2

            //For Rootstock
            // 0xC0B92Ac272D427633c36fd03dc104a2042B3a425, //WRBTC-RUSDCT pool
            // 0xe43ca1Dee3F0fc1e2df73A0745674545F11A59F5, //quoterV2
            60,
            commonAddresses
        );
        // console.log(
        //     "strategyPassiveManagerSushi contract address",
        //     address(strategyPassiveManagerSushi)
        // );
        // console.log("test contract address", address(this));
        vault.setStrategyAddress(address(strategyPassiveManagerSushi));
        strategyPassiveManagerSushi.setDeviation(5);
        strategyPassiveManagerSushi.setTwapInterval(120);
        console.log("at time of setup.......");
        console.log(
            "after deposit pool balance of weth",
            weth.balanceOf(0xf3Eb87C1F6020982173C908E7eB31aA66c1f0296)
        );
        console.log(
            "after deposit pool balance of USDC",
            usdc.balanceOf(0xf3Eb87C1F6020982173C908E7eB31aA66c1f0296)
        );
    }

    function performDeposit(
        address user,
        address token0,
        address token1,
        uint256 tokenAmount0,
        uint256 tokenAmount1
    ) internal {
        vm.startPrank(user);
        deal(token0, user, tokenAmount0 * 2);
        deal(token1, user, tokenAmount1 * 2);
        vm.stopPrank();

        console.log("****************************************");

        (uint256 amount0Bal, uint256 amount1Bal) = strategyPassiveManagerSushi
            .balances();

        console.log(
            "total balance from strategy for token0 and token1:",
            amount0Bal,
            amount1Bal
        );
        
        // (uint256 amount0BalInStrat, uint256 amount1BalInStrat) = strategyPassiveManagerSushi.balancesOfThis();

        // console.log(
        //     "total balance in strategy for token0 and token1:",
        //     amount0BalInStrat,
        //     amount1BalInStrat
        // );

        console.log("****************************************");
        console.log("user", user);
        console.log(
            "User WRBTC balance before deposit:",
            IERC20(token0).balanceOf(user)
        );
        console.log(
            "User RUSDT balance before deposit:",
            IERC20(token1).balanceOf(user)
        );

        (
            uint256 shares,
            uint256 amount0,
            uint256 amount1,
            uint256 fee0,
            uint256 fee1
        ) = vault.previewDeposit(tokenAmount0, tokenAmount1);

        console.log("Preview shares:", shares);
        console.log("Preview amount0:", amount0);
        console.log("Preview amount1:", amount1);
        console.log("Preview fee0:", fee0);
        console.log("Preview fee1:", fee1);

        vm.startPrank(user);
        IERC20(token0).approve(address(vault), tokenAmount0);
        IERC20(token1).approve(address(vault), tokenAmount1);

        vault.deposit(amount0, amount1, shares - (shares * 1) / 1000);

        vm.stopPrank();

        console.log(
            "User WRBTC balance after deposit:",
            IERC20(token0).balanceOf(user)
        );
        console.log(
            "User RUSDT balance after deposit:",
            IERC20(token1).balanceOf(user)
        );
        console.log("User shares after deposit:", vault.balanceOf(user));

        (amount0Bal, amount1Bal) = strategyPassiveManagerSushi.balances();
        console.log(
            "total balance from strategy for token0 and token1:",
            amount0Bal,
            amount1Bal
        );
        console.log(
            "after deposit pool balance of weth",
            weth.balanceOf(0xf3Eb87C1F6020982173C908E7eB31aA66c1f0296)
        );
        console.log(
            "after deposit pool balance of USDC",
            usdc.balanceOf(0xf3Eb87C1F6020982173C908E7eB31aA66c1f0296)
        );
        console.log("****************************************");
    }

    function performWithdraw(
        address user,
        address token0,
        address token1
    ) internal {
        uint256 shares = vault.balanceOf(user);
        console.log("****************************************");

        console.log("user", user);
        console.log("User shares before withdraw:", shares);

        (uint256 amount0, uint256 amount1) = vault.previewWithdraw(shares);

        console.log("Preview amount0 for withdraw:", amount0);
        console.log("Preview amount1 for withdraw:", amount1);

        vm.startPrank(user);
        vault.withdraw(shares, amount0, amount1);
        vm.stopPrank();

        console.log("User shares after withdraw:", vault.balanceOf(user));
        console.log(
            "User WRBTC balance after withdraw:",
            IERC20(token0).balanceOf(user)
        );
        console.log(
            "User RUSDT balance after withdraw:",
            IERC20(token1).balanceOf(user)
        );
        console.log("****************************************");
    }

    // function testDeposit() public {
    //     address token0 = WETH;
    //     address token1 = USDC;
    //     // performDeposit(user,token0, token1, wrbtcAmount, usdtAmount);
    //     // performDeposit(user1,token0, token1, wrbtcAmount / 2, usdtAmount / 2);

    //     performDeposit(USER, token0, token1, wethAmount, usdcAmount);
    //     performDeposit(USER1, token0, token1, wethAmount, usdcAmount);
    //     performDeposit(USER2, token0, token1, wethAmount, usdcAmount);
    // }

    function testWithdraw() public {
        address token0 = WETH;
        address token1 = USDC;

       
        performDeposit(USER, token0, token1, wethAmount, usdcAmount);

        console.log(
            "totalSupply of share tokens after first deposit",
            vault.totalSupply()
        );

        performDeposit(USER1, token0, token1, wethAmount, usdcAmount);
        performDeposit(USER2, token0, token1, wethAmount, usdcAmount);

        console.log(
            "share token balance of valut before withfraw: ",
            vault.balanceOf(address(vault))
        );
        console.log("totalSupply", vault.totalSupply());
        performWithdraw(USER, token0, token1);

        // (uint256 amount0, uint256 amount1) = vault.previewWithdraw(1000);
        // console.log("amount0 and amount1", amount0, amount1);
        performWithdraw(USER1, token0, token1);
        performWithdraw(USER2, token0, token1);

        console.log(
            "share token balance of valut after withfraw: ",
            vault.balanceOf(address(vault))
        );

        console.log("totalSupply", vault.totalSupply());
    }
}
