// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVault {
    function asset() external view returns (address);
}

abstract contract BaseYieldStrategy {
    address public immutable vault;
    address public immutable asset;
    address public strategist;

    modifier onlyVault() {
        require(msg.sender == vault, "Not authorized: Vault only");
        _;
    }

    modifier onlyStrategist() {
        require(msg.sender == strategist, "Not strategist");
        _;
    }

    constructor(address _vault, address _strategist) {
        vault = _vault;
        strategist = _strategist;
        asset = IVault(_vault).asset();
    }

    function invest(uint256 amount) external virtual;

    function withdraw(uint256 amount) external virtual;

    function totalAssets() external view virtual returns (uint256);

    function harvest() external virtual;

    // Optional override: for reward claiming or reinvesting
    function setStrategist(address newStrategist) external onlyStrategist {
        strategist = newStrategist;
    }
}
