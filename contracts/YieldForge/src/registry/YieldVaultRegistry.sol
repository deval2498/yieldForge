// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VaultRegistry {
    address public admin;
    mapping(address => bool) public isWhitelisted;

    event VaultWhitelisted(address indexed vault);
    event VaultRevoked(address indexed vault);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function whitelist(address vault) external onlyAdmin {
        require(vault != address(0), "Invalid vault");
        isWhitelisted[vault] = true;
        emit VaultWhitelisted(vault);
    }

    function revoke(address vault) external onlyAdmin {
        require(vault != address(0), "Invalid vault");
        isWhitelisted[vault] = false;
        emit VaultRevoked(vault);
    }

    function isVaultApproved(address vault) external view returns (bool) {
        return isWhitelisted[vault];
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Zero address");
        admin = newAdmin;
    }
}
