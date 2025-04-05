// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISwapAdapter {
    /// @notice Swaps tokenIn for tokenOut and returns the amount received
    /// @param tokenIn The address of the input token
    /// @param tokenOut The address of the output token
    /// @param amountIn The amount of tokenIn to swap
    /// @param amountOutMin The minimum acceptable amount of tokenOut
    /// @param to The address to receive the output tokens
    /// @return amountOut The amount of tokenOut received from the swap
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address to
    ) external returns (uint256 amountOut);

    function previewSwap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (uint256 expectedOut);
}
