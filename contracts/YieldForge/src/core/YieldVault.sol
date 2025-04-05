// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AutomationCompatibleInterface} from "chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";
import {YieldStrategyRegistry} from "../registry/YieldStrategyRegistry.sol";
import {ISwapAdapter} from "../interfaces/ISwapAdapter.sol";

interface IStrategy {
    function invest(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function totalAssets() external view returns (uint256);
    function harvest() external;
}

contract Vault is ERC20, AutomationCompatibleInterface {
    address public immutable asset;
    address public strategy;
    address public admin;
    address public strategyRegistry;
    address public adapter;

    constructor(
        address _asset,
        address _strategyRegistry,
        address _adapter
    ) ERC20("YieldForge Vault Share", "YFVS") {
        asset = _asset;
        admin = msg.sender;
        strategyRegistry = _strategyRegistry;
        adapter = _adapter;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    function setStrategy(address _strategy) external onlyAdmin {
        require(strategy == address(0), "Already set");
        require(
            YieldStrategyRegistry(strategyRegistry).isWhitelisted(_strategy),
            "Not whitelisted"
        );

        strategy = _strategy;
    }

    function deposit(uint256 amount) external {
        require(
            IERC20(asset).transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        uint256 sharesToMint = (totalSupply() == 0)
            ? amount
            : (amount * totalSupply()) / totalAssets();

        _mint(msg.sender, sharesToMint);
        IERC20(asset).transfer(strategy, amount);
        IStrategy(strategy).invest(amount);
    }

    function depositWithSwap(
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMin
    ) external {
        require(tokenIn != asset, "Use deposit for this token!");
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(address(adapter), amountIn);

        uint256 amountOut = ISwapAdapter(adapter).swap(
            tokenIn,
            asset,
            amountIn,
            amountOutMin,
            address(this)
        );

        // proceed with minting shares based on amountOut
        uint256 sharesToMint = (totalSupply() == 0 || totalAssets() == 0)
            ? amountOut
            : (amountOut * totalSupply()) / totalAssets();

        _mint(msg.sender, sharesToMint);
    }

    function previewDepositWithSwap(
        address tokenIn,
        uint256 amountIn
    ) external view returns (uint256 expectedShares) {
        require(tokenIn != asset, "Use previewDeposit for this token!");

        uint256 amountOut = ISwapAdapter(adapter).previewSwap(
            tokenIn,
            asset,
            amountIn
        );

        expectedShares = (totalSupply() == 0 || totalAssets() == 0)
            ? amountOut
            : (amountOut * totalSupply()) / totalAssets();
    }

    function withdraw(uint256 shares) external {
        require(balanceOf(msg.sender) >= shares, "Insufficient shares");

        uint256 amountToWithdraw = (shares * totalAssets()) / totalSupply();
        _burn(msg.sender, shares);
        IStrategy(strategy).withdraw(amountToWithdraw);
        require(
            IERC20(asset).transfer(msg.sender, amountToWithdraw),
            "Withdraw transfer failed"
        );
    }

    function totalAssets() public view returns (uint256) {
        return
            IStrategy(strategy).totalAssets() +
            IERC20(asset).balanceOf(address(this));
    }

    function previewWithdraw(
        uint256 shares
    ) external view returns (uint256 amountToWithdraw) {
        require(shares <= totalSupply(), "Insufficient total supply");

        if (totalSupply() == 0) return 0;
        amountToWithdraw = (shares * totalAssets()) / totalSupply();
    }

    // Chainlink Automation Interface
    function checkUpkeep(
        bytes calldata
    ) external pure override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = isRebalanceNeeded();
        return (upkeepNeeded, "");
    }

    function isRebalanceNeeded() public pure returns (bool) {
        // TODO: Implement yield delta check or idle capital check
        return false;
    }

    function rebalance(address newStrategy, uint256 amount) public onlyAdmin {
        require(
            YieldStrategyRegistry(strategyRegistry).isWhitelisted(newStrategy),
            "Not whitelisted"
        );

        IStrategy(strategy).withdraw(amount);
        IERC20(asset).approve(newStrategy, amount);
        IStrategy(newStrategy).invest(amount);

        strategy = newStrategy;
    }

    function performUpkeep(bytes calldata) external override {
        require(isRebalanceNeeded(), "No rebalance needed");
        rebalance(address(0), totalAssets());
    }
}
