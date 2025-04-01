// contracts/strategies/MockStrategy.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IYieldStrategy} from "../interfaces/IYieldStrategy.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract MockStrategy is IYieldStrategy {
    using SafeERC20 for IERC20;

    IERC20 public immutable assetToken;
    string private constant _name = "MockStrategy";

    uint256 public totalBalance;

    constructor(address _asset) {
        assetToken = IERC20(_asset);
    }

    function deposit(address token, uint256 amount) external override {
        require(token == address(assetToken), "Wrong token");
        assetToken.safeTransferFrom(msg.sender, address(this), amount);
        totalBalance += amount;
    }

    function withdraw(address token, uint256 amount) external override {
        require(token == address(assetToken), "Wrong token");
        require(amount <= totalBalance, "Too much");
        assetToken.safeTransfer(msg.sender, amount);
        totalBalance -= amount;
    }

    function balance() external view override returns (uint256) {
        return totalBalance;
    }

    function asset() external view override returns (address) {
        return address(assetToken);
    }

    function name() external pure override returns (string memory) {
        return _name;
    }
}
