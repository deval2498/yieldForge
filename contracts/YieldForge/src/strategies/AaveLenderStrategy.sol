// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseYieldStrategy} from "../interfaces/BaseYieldStrategy.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IAaveLendingPool {
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);

    function getUserAccountData(
        address user
    )
        external
        view
        returns (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );
}

contract AaveStrategy is BaseYieldStrategy {
    IAaveLendingPool public lendingPool;

    constructor(
        address _vault,
        address _strategist,
        address _aaveLendingPool
    ) BaseYieldStrategy(_vault, _strategist) {
        lendingPool = IAaveLendingPool(_aaveLendingPool);
        IERC20(asset).approve(address(lendingPool), type(uint256).max);
    }

    function invest(uint256 amount) external override onlyVault {
        lendingPool.deposit(asset, amount, address(this), 0);
    }

    function withdraw(uint256 amount) external override onlyVault {
        lendingPool.withdraw(asset, amount, vault);
    }

    function totalAssets() external view override returns (uint256) {
        // Optional: Call to Aave protocol to get actual balance. Placeholder for now.
        return IERC20(asset).balanceOf(address(this));
    }

    function harvest() external override onlyVault {
        // Aave doesn't have claimable yield by default in V3
        // This can be extended if rewards controller is integrated
    }
}
