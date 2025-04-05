// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/core/YieldVault.sol";
import "../src/registry/YieldStrategyRegistry.sol";
import "../src/adapters/UniswapV2Router.sol";
import "../src/mocks/MockERC20.sol";
import "../src/mocks/MockStrategy.sol";

contract VaultTest is Test {
    Vault public vault;
    YieldStrategyRegistry public strategyRegistry;
    UniswapV2Adapter public adapter;
    MockERC20 public usdc;
    MockStrategy public strategy;

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public admin = makeAddr("admin");

    function setUp() public {
        vm.startPrank(admin);
        usdc = new MockERC20("USD Coin", "USDC", 1_000_000e6, address(this));
        strategyRegistry = new YieldStrategyRegistry();
        adapter = new UniswapV2Adapter(address(0));
        vault = new Vault(
            address(usdc),
            address(strategyRegistry),
            address(adapter)
        );
        vm.stopPrank();

        // Give Alice and Bob some USDC
        usdc.transfer(alice, 1_000e6);
        usdc.transfer(bob, 1_000e6);
    }

    function testDeposit() public {
        vm.startPrank(alice);
        usdc.approve(address(vault), 500e6);
        vault.deposit(500e6);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), 500e6);
        assertEq(usdc.balanceOf(address(vault)), 500e6);
    }

    function testWithdraw() public {
        vm.startPrank(alice);
        usdc.approve(address(vault), 500e6);
        vault.deposit(500e6);
        vault.withdraw(500e6);
        vm.stopPrank();

        assertEq(usdc.balanceOf(alice), 1_000e6);
        assertEq(vault.balanceOf(alice), 0);
    }

    function testMultipleDeposits() public {
        vm.startPrank(alice);
        usdc.approve(address(vault), 500e6);
        vault.deposit(500e6);
        vm.stopPrank();

        vm.startPrank(bob);
        usdc.approve(address(vault), 1_000e6);
        vault.deposit(1_000e6);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), 500e6);
        assertEq(vault.balanceOf(bob), 1_000e6);
        assertEq(usdc.balanceOf(address(vault)), 1_500e6);
    }

    function testPreviewWithdraw() public {
        // Test preview with no deposits
        uint256 previewEmpty = vault.previewWithdraw(100e6);
        assertEq(previewEmpty, 0);

        // Test preview after deposit
        vm.startPrank(alice);
        usdc.approve(address(vault), 100e6);
        vault.deposit(100e6);
        vm.stopPrank();

        uint256 preview = vault.previewWithdraw(100e6);
        assertEq(preview, 100e6);

        // Test preview with partial withdrawal
        uint256 previewPartial = vault.previewWithdraw(50e6);
        assertEq(previewPartial, 50e6);
    }

    function testSetStrategy() public {
        strategy = new MockStrategy(address(usdc));
        strategyRegistry.whitelist(address(strategy));

        vm.prank(admin);
        vault.setStrategy(address(strategy));

        assertEq(vault.strategy(), address(strategy));
    }

    function testSetStrategy_NotWhitelisted() public {
        strategy = new MockStrategy(address(usdc));

        vm.expectRevert("Not whitelisted");
        vm.prank(admin);
        vault.setStrategy(address(strategy));
    }

    function testDepositWithSwap() public {
        MockERC20 tokenIn = new MockERC20(
            "Token In",
            "TIN",
            1_000_000e18,
            address(this)
        );
        tokenIn.transfer(alice, 1_000e18);

        vm.startPrank(alice);
        tokenIn.approve(address(vault), 500e18);
        vault.depositWithSwap(address(tokenIn), 500e18, 0);
        vm.stopPrank();
    }

    function testPreviewDepositWithSwap() public {
        MockERC20 tokenIn = new MockERC20(
            "Token In",
            "TIN",
            1_000_000e18,
            address(this)
        );

        uint256 expectedShares = vault.previewDepositWithSwap(
            address(tokenIn),
            500e18
        );
        assertEq(expectedShares, 500e18); // Since we're using a mock adapter that returns 1:1

        // Test with existing deposits
        vm.startPrank(alice);
        usdc.approve(address(vault), 1000e6);
        vault.deposit(1000e6);
        vm.stopPrank();

        expectedShares = vault.previewDepositWithSwap(address(tokenIn), 500e18);
        assertEq(expectedShares, 500e18); // Still 1:1 due to mock adapter
    }

    function testRebalance() public {
        strategy = new MockStrategy(address(usdc));
        MockStrategy newStrategy = new MockStrategy(address(usdc));

        strategyRegistry.whitelist(address(strategy));
        strategyRegistry.whitelist(address(newStrategy));

        vm.prank(admin);
        vault.setStrategy(address(strategy));

        vm.startPrank(alice);
        usdc.approve(address(vault), 500e6);
        vault.deposit(500e6);
        vm.stopPrank();

        vm.prank(admin);
        vault.rebalance(address(newStrategy), 500e6);

        assertEq(vault.strategy(), address(newStrategy));
    }

    function testCheckUpkeep() public {
        (bool upkeepNeeded, bytes memory performData) = vault.checkUpkeep("");
        assertFalse(upkeepNeeded);
        assertEq(performData.length, 0);
    }

    function testPerformUpkeep() public {
        strategy = new MockStrategy(address(usdc));
        strategyRegistry.whitelist(address(strategy));

        vm.prank(admin);
        vault.setStrategy(address(strategy));

        vm.startPrank(alice);
        usdc.approve(address(vault), 500e6);
        vault.deposit(500e6);
        vm.stopPrank();

        vm.expectRevert("No rebalance needed");
        vault.performUpkeep("");
    }
}
