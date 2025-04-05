// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract YieldStrategyRegistry {
    address public admin;
    mapping(address => bool) public isWhitelisted;

    event StrategyWhitelisted(address strategy);
    event StrategyRevoked(address strategy);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function whitelist(address strategy) external onlyAdmin {
        isWhitelisted[strategy] = true;
        emit StrategyWhitelisted(strategy);
    }

    function revoke(address strategy) external onlyAdmin {
        isWhitelisted[strategy] = false;
        emit StrategyRevoked(strategy);
    }

    function isStrategyApproved(address strategy) external view returns (bool) {
        return isWhitelisted[strategy];
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Zero address");
        admin = newAdmin;
    }
}
