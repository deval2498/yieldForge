// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {UniswapV2Adapter} from "../src/adapters/UniswapV2Router.sol";
import "../src/mocks/MockERC20.sol";
import "../src/mocks/MockUniswapV2Router.sol";

contract UniswapV2RouterTest is Test {
    UniswapV2Adapter public adapter;
    MockUniswapV2Router public mockRouter;
    MockERC20 public tokenIn;
    MockERC20 public tokenOut;
    address public alice = address(0xA11CE);

    function setUp() public {
        mockRouter = new MockUniswapV2Router();
        adapter = new UniswapV2Adapter(address(mockRouter));

        tokenIn = new MockERC20("Token In", "TIN", 1_000_000e18, address(this));
        tokenOut = new MockERC20(
            "Token Out",
            "TOUT",
            1_000_000e18,
            address(this)
        );

        tokenIn.transfer(alice, 1_000e18);
    }

    function testSwap() public {
        vm.startPrank(alice);
        tokenIn.approve(address(adapter), 500e18);

        uint256 amountOut = adapter.swap(
            address(tokenIn),
            address(tokenOut),
            500e18,
            0,
            alice
        );

        assertEq(amountOut, 500e18);
        assertEq(tokenOut.balanceOf(alice), 500e18);
    }

    function testPreviewSwap() public {
        uint256 expectedOut = adapter.previewSwap(
            address(tokenIn),
            address(tokenOut),
            500e18
        );

        assertEq(expectedOut, 500e18);
    }

    function testSwap_InvalidPath() public {
        vm.startPrank(alice);
        tokenIn.approve(address(adapter), 500e18);

        vm.expectRevert();
        adapter.swap(address(0), address(tokenOut), 500e18, 0, alice);
    }

    function testPreviewSwap_InvalidPath() public {
        vm.expectRevert();
        adapter.previewSwap(address(0), address(tokenOut), 500e18);
    }
}
