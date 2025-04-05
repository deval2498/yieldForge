// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Vault} from "./YieldVault.sol";

contract VaultFactory {
    mapping(address => address) public getVaultForAsset;
    address[] public allVaults;

    event VaultCreated(address indexed asset, address vault);

    function createVault(
        address asset,
        address strategyRegistry,
        address adapter
    ) external returns (address vault) {
        require(
            getVaultForAsset[asset] == address(0),
            "Vault already exists for asset"
        );

        vault = address(new Vault(asset, strategyRegistry, adapter));
        getVaultForAsset[asset] = vault;
        allVaults.push(vault);

        emit VaultCreated(asset, vault);
    }

    function getAllVaults() external view returns (address[] memory) {
        return allVaults;
    }
}
