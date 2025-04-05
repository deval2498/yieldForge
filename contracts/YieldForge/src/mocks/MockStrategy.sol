// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/BaseYieldStrategy.sol";

contract MockStrategy is BaseYieldStrategy {
    uint256 public balance;

    constructor(address _vault) BaseYieldStrategy(_vault, address(0)) {}

    function invest(uint256 amount) external override onlyVault {
        balance += amount;
    }

    function withdraw(uint256 amount) external override onlyVault {
        balance -= amount;
    }

    function totalAssets() external view override returns (uint256) {
        return balance;
    }

    function harvest() external override onlyVault {}
}
