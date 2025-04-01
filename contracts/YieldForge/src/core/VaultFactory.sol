// contracts/core/VaultFactory.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../vaults/YieldVault.sol";

contract VaultFactory {
    address[] public allVaults;
    mapping(address => mapping(address => address)) public getVault; // token => strategy => vault

    event VaultCreated(address indexed asset, address indexed strategy, address vault);

    function createVault(address _asset, address _strategy) external returns (address vault) {
        require(getVault[_asset][_strategy] == address(0), "Vault already exists");

        vault = address(new YieldVault(_asset, _strategy));
        getVault[_asset][_strategy] = vault;
        allVaults.push(vault);

        emit VaultCreated(_asset, _strategy, vault);
    }

    function getAllVaults() external view returns (address[] memory) {
        return allVaults;
    }
}
