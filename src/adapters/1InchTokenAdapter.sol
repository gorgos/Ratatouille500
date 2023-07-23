// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISwapRouter } from "@uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";

import { IIndexToken } from "../interfaces/IIndexToken.sol";
import { IAggregationExecutor, IAggregationRouterV5 } from "../interfaces/IAggregationRouterV5.sol";

interface IUniswapRouter is ISwapRouter {
    function refundETH() external payable;
}

contract OneInchTokenAdapter is IIndexToken {
    address private constant WETH9 = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;

    IAggregationRouterV5 private immutable aggregationRouter;
    IERC20 private underlying;

    constructor(IERC20 _underlying, IAggregationRouterV5 _aggregationRouter) {
        underlying = _underlying;
        aggregationRouter = _aggregationRouter;
        underlying.approve(address(aggregationRouter), type(uint256).max);
    }

    function getUnderlying() external view returns (IERC20) {
        return underlying;
    }

    function buy() external payable {
        require(msg.value > 0, "Must pass non 0 ETH amount");

        address tokenIn = WETH9;
        address tokenOut = address(underlying);
        address recipient = msg.sender;
        uint256 amountIn = msg.value;
        uint256 amountOutMinimum = 1;

        aggregationRouter.swap(
            IAggregationExecutor(address(this)),
            IAggregationRouterV5.SwapDescription(
                IERC20(tokenIn), IERC20(tokenOut), payable(recipient), payable(recipient), amountIn, amountOutMinimum, 0
            ),
            "",
            ""
        );
    }

    function sell(uint256 tokenAmount) external payable {
        address tokenIn = address(underlying);
        address tokenOut = WETH9;
        address recipient = msg.sender;
        uint256 amountIn = tokenAmount;
        uint256 amountOutMinimum = 1;

        aggregationRouter.swap(
            IAggregationExecutor(address(this)),
            IAggregationRouterV5.SwapDescription(
                IERC20(tokenIn), IERC20(tokenOut), payable(recipient), payable(recipient), amountIn, amountOutMinimum, 0
            ),
            "",
            ""
        );
    }
}
