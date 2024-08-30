// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../src/LendingManager.sol";

contract LendingManagerTest is Test {
    LendingManager lendingManager;

    IERC20 token;
    IMToken ktoken;
    uint256 amount;
    uint256 tropykusInterestRate;
    uint256 tropykusExchangeRate;

    // Mainnet fork configuration
    uint256 private constant DAY_IN_SECONDS = 86400;
    uint256 private constant FIVE_DAYS_IN_SECONDS = 5 * DAY_IN_SECONDS;

    address LENDING_POOL_TROPYKUS = vm.envAddress("KDOC_ADDRESS");
    address DOC_ADDRESS = vm.envAddress("DOC_ADDRESS");
    address USER = vm.envAddress("USER");
    uint256 private constant TOLERANCE = 1e15;

    function setUp() public {
        // Deploy the contract
        lendingManager = new LendingManager();

        // setting up underlying token
        token = IERC20(DOC_ADDRESS);

        // setting up ktoken of underlying token
        ktoken = IMToken(LENDING_POOL_TROPYKUS);

        tropykusInterestRate = lendingManager.getInterestRateOfTropykus(
            LENDING_POOL_TROPYKUS
        );
        tropykusExchangeRate = lendingManager.exchangeRateOfTropykus(
            LENDING_POOL_TROPYKUS
        );
        console.log("Tropykus INTEREST RATE", tropykusInterestRate);
        console.log("INIT Tropykus exchange RATE", tropykusExchangeRate);

        // setting up supply/withdraw amount
        amount = 100000 * (10 ** 18); // 100 doc
    }

    function testDepositWithdrawl() public {
        vm.startPrank(USER);

        deal(DOC_ADDRESS, USER, amount);

        uint256 initialBalance = token.balanceOf(USER);
        token.approve(address(lendingManager), amount);

        console.log(
            "exchange rate before deposit",
            lendingManager.exchangeRateOfTropykus(LENDING_POOL_TROPYKUS)
        );
        console.log(
            "DOC balance before deposit : USER",
            IERC20(DOC_ADDRESS).balanceOf(address(USER))
        );

        lendingManager.depositToTropykus(amount, LENDING_POOL_TROPYKUS);

        vm.stopPrank();

        console.log(
            "exchange rate after deposit",
            lendingManager.exchangeRateOfTropykus(LENDING_POOL_TROPYKUS)
        );
        console.log(
            "KDOC balance after deposit : contract",
            ktoken.balanceOf(address(lendingManager))
        );

        uint256 expectedMTokens = (amount * 1e18) / tropykusExchangeRate;

        assertApproxEqRel(
            ktoken.balanceOf(address(lendingManager)),
            expectedMTokens,
            TOLERANCE,
            "Incorrect mToken balance after deposit"
        );
        assertEq(
            token.balanceOf(USER),
            initialBalance - amount,
            "Incorrect USDC balance after deposit"
        );

        // Simulate interest accrual
        vm.warp(block.timestamp + DAY_IN_SECONDS);

        vm.prank(USER);
        console.log(
            "exchange rate after days",
            lendingManager.exchangeRateOfTropykus(LENDING_POOL_TROPYKUS)
        );
        console.log("ktoken", ktoken.balanceOf(address(lendingManager)));
        // console.log(
        //     "USDC balance after a day",
        //     (
        //         (IERC20(LENDING_POOL_TROPYKUS).balanceOf(
        //             address(lendingManager)
        //         ) *
        //             lendingManager.exchangeRateOfTropykus(
        //                 LENDING_POOL_TROPYKUS
        //             ))
        //     ) / 10 ** 18
        // );
        // Withdraw half
        uint256 halfBalance = ktoken.balanceOf(address(lendingManager));
        lendingManager.withdrawFromTropykus(halfBalance, LENDING_POOL_TROPYKUS);
        console.log(
            "USDC balance after withdraw",
            token.balanceOf(address(lendingManager))
        );
        console.log(
            "exchange rate after withdraw",
            lendingManager.exchangeRateOfTropykus(LENDING_POOL_TROPYKUS)
        );
        // assertGe(
        //     token.balanceOf(address(lendingManager)),
        //     AMOUNT / 2,
        //     "Contract should have more than half USDC"
        // );
        // assertApproxEqRel(
        //     mtoken.balanceOf(address(lendingManager)),
        //     halfBalance,
        //     TOLERANCE,
        //     "Incorrect mToken balance after partial withdrawal"
        // );

        // Simulate more interest accrual
        // vm.warp(block.timestamp + FIVE_DAYS_IN_SECONDS);
        // uint256 remainingBalance = mtoken.balanceOf(address(lendingManager));

        // // Withdraw remaining balance
        // vm.prank(USER);
        // lendingManager.withdrawFromMoonWell(
        //     remainingBalance,
        //     LENDING_POOL_MOONWELL
        // );

        // assertEq(
        //     mtoken.balanceOf(address(lendingManager)),
        //     0,
        //     "mToken balance should be zero after full withdrawal"
        // );
        // assertGt(
        //     token.balanceOf(address(lendingManager)),
        //     AMOUNT,
        //     "Contract should have earned interest"
        // );

        // console.log("checking for rewards...");
        // console.log(
        //     "WELL rewards before claim",
        //     IERC20(0xA88594D404727625A9437C3f886C7643872296AE).balanceOf(
        //         address(lendingManager)
        //     )
        // );
        // lendingManager.claimRewardFromMoonwell();
        // console.log(
        //     "WELL rewards after claim",
        //     IERC20(0xA88594D404727625A9437C3f886C7643872296AE).balanceOf(
        //         address(lendingManager)
        //     )
        // );
        // assertGe(
        //     IERC20(0xA88594D404727625A9437C3f886C7643872296AE).balanceOf(
        //         address(lendingManager)
        //     ),
        //     0,
        //     "WELL rewards can be greater than or equals zero"
        // );
    }

    // function testDepositTropykus() public {
    //     vm.startPrank(USER);
    //     deal(DOC_ADDRESS, USER, 200 * (10 ** 18));
    //     // Check user's TOKEN balance
    //     assertGt(
    //         token.balanceOf(USER),
    //         0,
    //         "USER does not hold the underlying token"
    //     );

    //     // Approve and supply TOKEN
    //     token.approve(address(lendingManager), amount);
    //     assertGe(
    //         token.allowance(USER, address(lendingManager)),
    //         amount,
    //         "Allowance should be equal to the approved amount"
    //     );

    //     console.log(
    //         "token balance of user before deposit... ",
    //         token.balanceOf(USER)
    //     );
    //     console.log(
    //         "ktoken balance of contract before deposit... ",
    //         ktoken.balanceOf(address(lendingManager))
    //     );

    //     // supply amount to Tropykus
    //     lendingManager.depositToTropykus(amount, LENDING_POOL_TROPYKUS);

    //     console.log(
    //         "token balance of user after deposit... ",
    //         token.balanceOf(USER)
    //     );
    //     console.log(
    //         "ktoken balance of contract after deposit... ",
    //         ktoken.balanceOf(address(lendingManager))
    //     );

    //     assertGe(
    //         ktoken.balanceOf(address(lendingManager)),
    //         amount,
    //         "ktoken balance error"
    //     );
    //     vm.stopPrank();
    // }

    // function testWithdrawHalfTropykus() public {
    //     testDepositTropykus();
    //     vm.startPrank(USER);
    //     uint256 DOCBalanceContract = token.balanceOf(address(lendingManager));
    //     uint256 amountToWithdraw = 50000000000000000000;

    //     tropykusExchangeRate = lendingManager.exchangeRateOfTropykus(
    //         LENDING_POOL_TROPYKUS
    //     );
    //     console.log("after deposit tropykusExchangeRate", tropykusExchangeRate);
    //     console.log(
    //         "ktoken balance of contract before withdraw... ",
    //         ktoken.balanceOf(address(lendingManager))
    //     );
    //     uint256 atokenAmount = (amountToWithdraw * (10 ** 18)) /
    //         tropykusExchangeRate;
    //     lendingManager.withdrawFromTropykus(
    //         atokenAmount,
    //         LENDING_POOL_TROPYKUS
    //     );

    //     console.log(
    //         "ktoken amount from underlying token amount and it should be half of total ktoken balance",
    //         atokenAmount
    //     );
    //     console.log(
    //         "ktoken balance of lending manager after withdraw",
    //         ktoken.balanceOf(address(lendingManager))
    //     );
    //     //check token balance of lending manager using formula to get underlying balance from atoken.
    //     assertApproxEqRel(
    //         token.balanceOf(address(lendingManager)),
    //         DOCBalanceContract +
    //             (atokenAmount * tropykusExchangeRate) /
    //             (10 ** 18),
    //         TOLERANCE,
    //         "DOC balance error 1: withdraw"
    //     );

    //     //after withdraw check underlying token balance for lendingManager and it should be equal to withdraw amount.
    //     assertApproxEqRel(
    //         token.balanceOf(address(lendingManager)),
    //         amountToWithdraw,
    //         TOLERANCE,
    //         "DOC balance error 2: withdraw"
    //     );

    //     //ktoken balance should decrease after withdraw underlying balance.
    //     assertGe(
    //         atokenAmount,
    //         ktoken.balanceOf(address(lendingManager)),
    //         "ktoken balance error: withdraw"
    //     );
    //     console.log(
    //         "ktoken balance of contract before one day... ",
    //         ktoken.balanceOf(address(lendingManager))
    //     );

    //     vm.warp(block.timestamp + DAY_IN_SECONDS);

    //     tropykusExchangeRate = lendingManager.exchangeRateOfTropykus(
    //         LENDING_POOL_TROPYKUS
    //     );

    //     console.log("after one day tropykusExchangeRate", tropykusExchangeRate);

    //     console.log(
    //         "ktoken balance of contract after one day... ",
    //         ktoken.balanceOf(address(lendingManager))
    //     );

    //     vm.stopPrank();
    // }

    // function testWithdrawFullTropykus() public {
    //     testDepositTropykus();
    //     vm.startPrank(USER);
    //     uint256 DOCBalanceContract = token.balanceOf(address(lendingManager));
    //     uint256 ktokenBalanceContract = ktoken.balanceOf(
    //         address(lendingManager)
    //     );
    //     uint256 amountToWithdraw = ktokenBalanceContract;
    //     console.log("before withdraw contract balance is ", DOCBalanceContract);

    //     console.log(
    //         "ktoken balance of contract before pass days... ",
    //         ktoken.balanceOf(address(lendingManager))
    //     );

    //     vm.warp(block.timestamp + DAY_IN_SECONDS * 5);

    //     console.log(
    //         "ktoken balance of contract after pass some days... ",
    //         ktoken.balanceOf(address(lendingManager))
    //     );

    //     lendingManager.withdrawFromTropykus(
    //         amountToWithdraw,
    //         LENDING_POOL_TROPYKUS
    //     );
    //     console.log(
    //         "after withdraw contract balance is ",
    //         token.balanceOf(address(lendingManager))
    //     );
    //     console.log(
    //         "after withdraw contract ktoken balance is ",
    //         ktoken.balanceOf(address(lendingManager))
    //     );
    //     assertGe(
    //         token.balanceOf(address(lendingManager)),
    //         DOCBalanceContract +
    //             (amountToWithdraw * tropykusExchangeRate) /
    //             (10 ** 18),
    //         "DOC balance error : withdraw"
    //     );

    //     assertEq(
    //         ktoken.balanceOf(address(lendingManager)),
    //         0,
    //         "ktoken balance error : withdraw"
    //     );
    //     vm.stopPrank();
    // }
}
