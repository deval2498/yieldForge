// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/registry/YieldStrategyRegistry.sol";
import "../src/mocks/MockStrategy.sol";

contract YieldStrategyRegistryTest is Test {
    YieldStrategyRegistry public registry;
    MockStrategy public strategy;
    address public admin;
    address public alice;

    function setUp() public {
        // Use makeAddr for consistent test account generation
        admin = makeAddr("admin");
        alice = makeAddr("alice");

        // Start with admin context
        vm.startPrank(admin);
        registry = new YieldStrategyRegistry();
        strategy = new MockStrategy(address(0));
        vm.stopPrank();
    }

    function testWhitelist() public {
        vm.prank(admin);
        registry.whitelist(address(strategy));

        assertTrue(registry.isWhitelisted(address(strategy)));
    }

    function testWhitelist_NotAdmin() public {
        vm.expectRevert("Not admin");
        vm.prank(alice);
        registry.whitelist(address(strategy));
    }

    function testRevoke() public {
        vm.prank(admin);
        registry.whitelist(address(strategy));

        vm.prank(admin);
        registry.revoke(address(strategy));

        assertFalse(registry.isWhitelisted(address(strategy)));
    }

    function testRevoke_NotAdmin() public {
        vm.prank(admin);
        registry.whitelist(address(strategy));

        vm.expectRevert("Not admin");
        vm.prank(alice);
        registry.revoke(address(strategy));
    }

    function testIsWhitelisted() public {
        assertFalse(registry.isWhitelisted(address(strategy)));

        vm.prank(admin);
        registry.whitelist(address(strategy));

        assertTrue(registry.isWhitelisted(address(strategy)));
    }
}
