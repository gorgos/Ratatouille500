// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IERC20 } from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol";
import { IAxelarGasService } from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import { AxelarExecutable } from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";

contract AxelarMessageReceiver is AxelarExecutable {
    IAxelarGasService immutable gasService;

    constructor(address _gateway, address _gasReceiver) AxelarExecutable(_gateway) {
        gasService = IAxelarGasService(_gasReceiver);
    }

    event Executed();

    function _executeWithToken(
        string calldata,
        string calldata,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    )
        internal
        override
    {
        address uniswapRouter = abi.decode(payload, (address));
        address tokenAddress = gateway.tokenAddresses(tokenSymbol);

        IERC20(tokenAddress).transfer(uniswapRouter, amount);

        emit Executed();
    }
}
