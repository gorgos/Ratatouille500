// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISwapRouter } from "@uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";

import { IIndexToken } from "../interfaces/IIndexToken.sol";

interface IUniswapRouter is ISwapRouter {
    function refundETH() external payable;
}

contract UniswapTokenAdapter is IIndexToken {
    address private constant WETH9 = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;

    IUniswapRouter public constant uniswapRouter = IUniswapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    IERC20 private underlying;

    constructor(IERC20 _underlying) {
        underlying = _underlying;
        underlying.approve(address(uniswapRouter), type(uint256).max);
    }

    function getUnderlying() external view returns (IERC20) {
        return underlying;
    }

    function buy() external payable {
        require(msg.value > 0, "Must pass non 0 ETH amount");

        uint256 deadline = block.timestamp + 15;
        address tokenIn = WETH9;
        address tokenOut = address(underlying);
        uint24 fee = 3000;
        address recipient = msg.sender;
        uint256 amountIn = msg.value;
        uint256 amountOutMinimum = 1;
        uint160 sqrtPriceLimitX96 = 0;

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
            tokenIn, tokenOut, fee, recipient, deadline, amountIn, amountOutMinimum, sqrtPriceLimitX96
        );

        uniswapRouter.exactInputSingle{ value: msg.value }(params);
        uniswapRouter.refundETH();

        if (address(this).balance > 0) {
            (bool success,) = msg.sender.call{ value: address(this).balance }("");
            require(success, "refund failed");
        }
    }

    function sell(uint256 tokenAmount) external payable {
        uint256 deadline = block.timestamp + 15;
        address tokenIn = address(underlying);
        address tokenOut = WETH9;
        uint24 fee = 3000;
        address recipient = msg.sender;
        uint256 amountIn = tokenAmount;
        uint256 amountOutMinimum = 1;
        uint160 sqrtPriceLimitX96 = 0;

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
            tokenIn, tokenOut, fee, recipient, deadline, amountIn, amountOutMinimum, sqrtPriceLimitX96
        );

        uniswapRouter.exactInputSingle(params);
        uniswapRouter.refundETH();

        if (address(this).balance > 0) {
            (bool success,) = msg.sender.call{ value: address(this).balance }("");
            require(success, "refund failed");
        }
    }

    receive() external payable { }

    fallback(bytes calldata data) external payable returns (bytes memory) { }
}
