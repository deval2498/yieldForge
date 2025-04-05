pragma solidity ^0.8.20;

import {ISwapAdapter} from "../interfaces/ISwapAdapter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

contract UniswapV2Adapter is ISwapAdapter {
    address public immutable router;

    constructor(address _router) {
        router = _router;
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address to
    ) external override returns (uint256 amountOut) {
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(router, amountIn);

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        uint[] memory amounts = IUniswapV2Router(router)
            .swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                to,
                block.timestamp
            );

        amountOut = amounts[amounts.length - 1];
    }

    function previewSwap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view override returns (uint256 expectedOut) {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        uint[] memory amounts = IUniswapV2Router(router).getAmountsOut(
            amountIn,
            path
        );
        expectedOut = amounts[amounts.length - 1];
    }
}
