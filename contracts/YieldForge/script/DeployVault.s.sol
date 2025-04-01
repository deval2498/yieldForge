// scripts/DeployVault.s.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/vaults/YieldVault.sol";
import "../src/strategies/MockStrategy.sol";
import "../src/mocks/MockERC20.sol";

contract DeployVault is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy mock USDC with 1M initial supply to deployer
        MockERC20 usdc = new MockERC20("USD Coin", "USDC", 1_000_000e6, msg.sender);

        // Deploy MockStrategy for USDC
        MockStrategy strategy = new MockStrategy(address(usdc));

        // Deploy YieldVault
        YieldVault vault = new YieldVault(address(usdc), address(strategy));

        console.log("Mock USDC:     ", address(usdc));
        console.log("Mock Strategy: ", address(strategy));
        console.log("Vault:         ", address(vault));

        vm.stopBroadcast();
    }
}
