// contracts/vaults/YieldVault.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IYieldStrategy} from "../interfaces/IYieldStrategy.sol";

contract YieldVault is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable asset;
    IYieldStrategy public strategy;

    uint256 public totalShares;
    mapping(address => uint256) public shares;

    constructor(address _asset, address _strategy) Ownable(msg.sender) {
        require(_asset != address(0) && _strategy != address(0), "Invalid input");

        asset = IERC20(_asset);
        strategy = IYieldStrategy(_strategy);

        require(strategy.asset() == _asset, "Strategy/token mismatch");
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Amount = 0");

        asset.safeTransferFrom(msg.sender, address(this), amount);

        // Send funds to strategy
        asset.approve(address(strategy), amount);
        strategy.deposit(address(asset), amount);

        uint256 vaultBalance = strategy.balance();
        uint256 sharesToMint = totalShares == 0 ? amount : (amount * totalShares) / vaultBalance;

        shares[msg.sender] += sharesToMint;
        totalShares += sharesToMint;
    }

    function withdraw(uint256 shareAmount) external {
        require(shareAmount > 0, "Share = 0");
        require(shares[msg.sender] >= shareAmount, "Insufficient shares");

        uint256 vaultBalance = strategy.balance();
        uint256 amountToWithdraw = (shareAmount * vaultBalance) / totalShares;

        shares[msg.sender] -= shareAmount;
        totalShares -= shareAmount;

        strategy.withdraw(address(asset), amountToWithdraw);
        asset.safeTransfer(msg.sender, amountToWithdraw);
    }

    function previewWithdraw(address user) external view returns (uint256) {
        return (shares[user] * strategy.balance()) / totalShares;
    }
}
