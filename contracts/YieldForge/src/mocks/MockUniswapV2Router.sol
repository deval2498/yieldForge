// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        require(path.length == 2, "Invalid path length");
        require(
            path[0] != address(0) && path[1] != address(0),
            "Invalid token address"
        );

        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        IERC20(path[1]).transfer(to, amountIn);

        amounts = new uint[](2);
        amounts[0] = amountIn;
        amounts[1] = amountIn;
    }

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts) {
        require(path.length == 2, "Invalid path length");
        require(
            path[0] != address(0) && path[1] != address(0),
            "Invalid token address"
        );

        amounts = new uint[](2);
        amounts[0] = amountIn;
        amounts[1] = amountIn;
    }
}
