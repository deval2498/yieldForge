// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/vaults/YieldVault.sol";
import "../src/strategies/MockStrategy.sol";
import "../src/mocks/MockERC20.sol";

contract VaultTest is Test {
    YieldVault public vault;
    MockStrategy public strategy;
    MockERC20 public usdc;

    address public alice = address(0xA11CE);
    address public bob = address(0xB0B);

    function setUp() public {
        usdc = new MockERC20("USD Coin", "USDC", 1_000_000e6, address(this));
        strategy = new MockStrategy(address(usdc));
        vault = new YieldVault(address(usdc), address(strategy));

        // Give Alice and Bob some USDC
        usdc.transfer(alice, 1_000e6);
        usdc.transfer(bob, 1_000e6);
    }

    function testDeposit() public {
        vm.startPrank(alice);
        usdc.approve(address(vault), 500e6);
        vault.deposit(500e6);
        vm.stopPrank();

        assertEq(vault.shares(alice), 500e6);
        assertEq(strategy.balance(), 500e6);
    }

    function testWithdraw() public {
        vm.startPrank(alice);
        usdc.approve(address(vault), 500e6);
        vault.deposit(500e6);
        vault.withdraw(500e6);
        vm.stopPrank();

        assertEq(usdc.balanceOf(alice), 1_000e6);
        assertEq(vault.shares(alice), 0);
        assertEq(strategy.balance(), 0);
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

        assertEq(vault.shares(alice), 500e6);
        assertEq(vault.shares(bob), 1_000e6);
        assertEq(strategy.balance(), 1_500e6);
    }

    function testPreviewWithdraw() public {
        vm.startPrank(alice);
        usdc.approve(address(vault), 100e6);
        vault.deposit(100e6);
        vm.stopPrank();

        uint256 preview = vault.previewWithdraw(alice);
        assertEq(preview, 100e6);
    }
}
