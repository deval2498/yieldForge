// contracts/interfaces/IYieldStrategy.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IYieldStrategy {
    function deposit(address token, uint256 amount) external;
    function withdraw(address token, uint256 amount) external;
    function asset() external view returns (address);
    function balance() external view returns (uint256);
    function name() external view returns (string memory);
}
