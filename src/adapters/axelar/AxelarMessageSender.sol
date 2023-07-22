// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IAxelarGateway } from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import { IAxelarGasService } from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";

import { IIndexToken } from "../../interfaces/IIndexToken.sol";
import { IWETH } from "../../interfaces/IWETH.sol";

contract AxelarMessageSender is IIndexToken {
    IAxelarGasService immutable gasService;
    IAxelarGateway immutable gateway;

    string private underlyingSymbol;
    IWETH private weth;
    string private destinationChain;
    string private destinationAddress;
    address private uniswapRouter;

    constructor(
        address _gateway,
        address _gasReceiver,
        address _weth,
        string memory _underlyingSymbol,
        string memory _destinationChain,
        string memory _destinationAddress,
        address _uniswapRouter
    ) {
        gateway = IAxelarGateway(_gateway);
        gasService = IAxelarGasService(_gasReceiver);
        underlyingSymbol = _underlyingSymbol;
        weth = IWETH(_weth);

        destinationChain = _destinationChain;
        destinationAddress = _destinationAddress;
        uniswapRouter = _uniswapRouter;

        weth.approve(_uniswapRouter, type(uint256).max);
    }

    function getUnderlying() external view returns (IERC20) {
        address tokenAddress = gateway.tokenAddresses(underlyingSymbol);
        return IERC20(tokenAddress);
    }

    function buy() external payable {
        uint256 ethForGas = 0.01 ether;
        uint256 ethForSwap = msg.value - ethForGas;
        weth.deposit{ value: ethForSwap }();

        sendTokenToDestination(destinationChain, destinationAddress, uniswapRouter, underlyingSymbol, ethForSwap);
    }

    function sell(uint256 tokenAmount) external payable {
        // TODO
    }

    function sendTokenToDestination(
        string memory _destinationChain,
        string memory _destinationAddress,
        address _uniswapRouter,
        string memory symbol,
        uint256 amount
    )
        public
        payable
    {
        require(msg.value > 0, "Gas payment is required");

        address tokenAddress = gateway.tokenAddresses(symbol);
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        IERC20(tokenAddress).approve(address(gateway), amount);

        bytes memory payload = abi.encode(_uniswapRouter);

        gasService.payNativeGasForContractCallWithToken{ value: msg.value }(
            address(this), _destinationChain, _destinationAddress, payload, symbol, amount, msg.sender
        );
        gateway.callContractWithToken(_destinationChain, _destinationAddress, payload, symbol, amount);
    }
}
