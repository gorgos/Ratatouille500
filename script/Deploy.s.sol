// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { MultiChainIndexFund } from "../src/MultiChainIndexFund.sol";

import { AxelarMessageSender } from "../src/adapters/axelar/AxelarMessageSender.sol";
import { AxelarMessageReceiver } from "../src/adapters/axelar/AxelarMessageReceiver.sol";
import { AxelarContracts } from "../src/adapters/axelar/AxelarContracts.sol";

import { IIndexToken } from "../src/interfaces/IIndexToken.sol";
import { IWETH } from "../src/interfaces/IWETH.sol";
import { UniswapTokenAdapter } from "../src/adapters/UniswapTokenAdapter.sol";

import { BaseScript } from "./Base.s.sol";

contract DeployMultiChainIndexFund is BaseScript {
    function run() public broadcast returns (MultiChainIndexFund multiChainIndexFund) {
        IIndexToken[] memory tokens = new IIndexToken[](1);

        tokens[0] = new UniswapTokenAdapter(IERC20(address(0x326C977E6efc84E512bB9C30f76E30c160eD06FB)));
        // tokens[0] = IIndexToken(address(0x326C977E6efc84E512bB9C30f76E30c160eD06FB));

        // Define corresponding target weights
        uint256[] memory targetWeights = new uint256[](1);
        targetWeights[0] = 100;

        multiChainIndexFund = new MultiChainIndexFund(tokens, targetWeights);
    }
}

contract DeployAxelarMessageSender is BaseScript {
    function run() public payable broadcast returns (AxelarMessageSender axelarMessageSender) {
        string memory destinationAddressString = "0x98F08EecE9eB1c8928C823b240388BB446D892F6";
        address uniswapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

        uint256 ethAmount = 0.01 ether;

        axelarMessageSender =
        new AxelarMessageSender(AxelarContracts.GOERLI_GATEWAY, AxelarContracts.GOERLI_SERVICE_CONTRACT, AxelarContracts.GOERLI_WETH, "WETH", "celo", destinationAddressString, uniswapRouter);

        IWETH weth = IWETH(AxelarContracts.GOERLI_WETH);
        weth.deposit{ value: ethAmount }();

        weth.approve(address(axelarMessageSender), type(uint256).max);

        axelarMessageSender.sendTokenToDestination{ value: 0.02 ether }(
            "celo", destinationAddressString, uniswapRouter, "WETH", ethAmount
        );
    }
}

contract DeployAxelarMessageReceiver is BaseScript {
    function run() public broadcast returns (AxelarMessageReceiver axelarMessageReceiver) {
        axelarMessageReceiver =
            new AxelarMessageReceiver(AxelarContracts.GOERLI_GATEWAY, AxelarContracts.GOERLI_SERVICE_CONTRACT);
    }
}
