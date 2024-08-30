// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";
import {IUniswapV3Pool} from "./interfaces/sushiswap/IUniswapV3Pool.sol";

// add LiquidityAmounts
import {TickMath} from "./utils/TickMath.sol"; // it is copied from sushiswap
// add UniV3Utils
// add TickUtils, FullMath // FullMath is copied from sushiswap
import {IVaultConcLiq} from "./interfaces/vault/IVaultConcLiq.sol";

// add IStrategyFactory
// add IStrategyConcLiq
// add IStrategyUniswapV3
// add IBeefySwapper
import {IQuoter} from "./interfaces/sushiswap/IQuoter.sol";

contract StrategyPassiveManagerSushi {
    using SafeERC20 for IERC20Metadata;
    using TickMath for int24;

    /// @notice The precision for pricing.
    uint256 private constant PRECISION = 1e36;
    uint256 private constant SQRT_PRECISION = 1e18;

    /// @notice The max and min ticks sudhiv3 allows.
    int56 private constant MIN_TICK = -887272;
    int56 private constant MAX_TICK = 887272;

    /// @notice The address of the sushiswap V3 pool.
    address public pool;
    /// @notice The address of the quoter.
    address public quoter;
    /// @notice The address of the first token in the liquidity pool.
    address public lpToken0;
    /// @notice The address of the second token in the liquidity pool.
    address public lpToken1;

    /// @notice The fees that are collected in the strategy but have not yet completed the harvest process.
    uint256 public fees0;
    uint256 public fees1;

    /// @notice The path to swap the first token to the native token for fee harvesting.
    bytes public lpToken0ToNativePath;
    /// @notice The path to swap the second token to the native token for fee harvesting.
    bytes public lpToken1ToNativePath;

    /// @notice The struct to store our tick positioning.
    struct Position {
        int24 tickLower;
        int24 tickUpper;
    }

    /// @notice The main position of the strategy.
    /// @dev this will always be a 50/50 position that will be equal to position width * tickSpacing on each side.
    Position public positionMain;

    /// @notice The alternative position of the strategy.
    /// @dev this will always be a single sided (limit order) position that will start closest to current tick and continue to width * tickSpacing.
    /// This will always be in the token that has the most value after we fill our main position.
    Position public positionAlt;

    /// @notice The width of the position, thats a multiplier for tick spacing to find our range.
    int24 public positionWidth;

    /// @notice the max tick deviations we will allow for deposits/harvests.
    int56 public maxTickDeviation;

    /// @notice The twap interval seconds we use for the twap check.
    uint32 public twapInterval;

    /// @notice Bool switch to prevent reentrancy on the mint callback.
    bool private minting;

    /// @notice Initializes the ticks on first deposit.
    bool private initTicks;

    // Errors
    error NotAuthorized();
    error NotPool();
    error InvalidEntry();
    error NotVault();
    error InvalidInput();
    error InvalidOutput();
    error NotCalm();
    error TooMuchSlippage();

    // Events
    event TVL(uint256 bal0, uint256 bal1);
    event Harvest(uint256 fee0, uint256 fee1);
    event SetPositionWidth(int24 oldWidth, int24 width);
    event SetDeviation(int56 maxTickDeviation);
    event SetTwapInterval(uint32 oldInterval, uint32 interval);
    event SetLpToken0ToNativePath(bytes path);
    event SetLpToken1ToNativePath(bytes path);
    event SetQuoter(address quoter);
    event ChargedFees(
        uint256 callFeeAmount,
        uint256 beefyFeeAmount,
        uint256 strategistFeeAmount
    );
    event ClaimedFees(
        uint256 feeMain0,
        uint256 feeMain1,
        uint256 feeAlt0,
        uint256 feeAlt1
    );
}
