// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@zetachain/protocol-contracts/contracts/zevm/SystemContract.sol";
import "@zetachain/protocol-contracts/contracts/zevm/interfaces/zContract.sol";

import "@zetachain/toolkit/contracts/SwapHelperLib.sol";

import { IIndexToken } from "../interfaces/IIndexToken.sol";

contract ZetaSwapV2 is zContract, IIndexToken {
    SystemContract public immutable systemContract;

    address private targetZRC20Address;

    constructor(address systemContractAddress, address _targetZRC20Address) {
        systemContract = SystemContract(systemContractAddress);
        targetZRC20Address = _targetZRC20Address;
    }

    function getUnderlying() external view override returns (IERC20) {
        return IERC20(targetZRC20Address);
    }

    function buy() external payable override {
        onCrossChainCall(
            targetZRC20Address,
            msg.value,
            abi.encode(targetZRC20Address, bytes32(uint256(uint160(msg.sender))), uint256(1))
        );
    }

    function sell(uint256 tokenAmount) external payable override {
        // TODO
    }

    function onCrossChainCall(address zrc20, uint256 amount, bytes memory message) public virtual override {
        (address targetZRC20, bytes32 receipient, uint256 minAmountOut) =
            abi.decode(message, (address, bytes32, uint256));
        uint256 outputAmount = SwapHelperLib._doSwap(
            systemContract.wZetaContractAddress(),
            systemContract.uniswapv2FactoryAddress(),
            systemContract.uniswapv2Router02Address(),
            zrc20,
            amount,
            targetZRC20,
            minAmountOut
        );
        SwapHelperLib._doWithdrawal(targetZRC20, outputAmount, receipient);
    }
}
