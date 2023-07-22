// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { IIndexToken } from "./interfaces/IIndexToken.sol";
import { Oracle } from "./Oracle.sol";
import { IOracle } from "./interfaces/IOracle.sol";

contract MultiChainIndexFund is ERC20 {
    // Array to hold the addresses of the tokens in the fund
    IIndexToken[] public tokens;

    // Mapping from token addresses to target weights (in percentage terms)
    mapping(IIndexToken => uint256) public targetWeights;

    // The oracle providing prices
    IOracle public oracle;

    constructor(IIndexToken[] memory _tokens, uint256[] memory _targetWeights) ERC20("MultiChain Index Fund", "MCI") {
        for (uint256 i = 0; i < _tokens.length; i++) {
            targetWeights[_tokens[i]] = _targetWeights[i];
        }

        uint256 totalWeight = 0;
        for (uint256 i = 0; i < _tokens.length; i++) {
            totalWeight += _targetWeights[i];
        }
        require(totalWeight == 100, "Target weights must add up to 100");

        tokens = _tokens;
        oracle = IOracle(new Oracle());
    }

    // Rebalance the fund to target weights
    function rebalance() public {
        uint256 totalValue = getTotalFundValueInEth();

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 price = oracle.getPrice(address(tokens[i]));
            uint256 balance = tokens[i].getUnderlying().balanceOf(address(this));

            uint256 currentValue = price * balance / 1e18;
            uint256 targetValue = totalValue * targetWeights[tokens[i]] / 100;

            if (currentValue > targetValue) {
                uint256 excessValue = currentValue - targetValue;
                uint256 sellAmount = excessValue * 1e18 / price;
                tokens[i].sell(sellAmount);
            } else if (currentValue < targetValue) {
                uint256 requiredValue = targetValue - currentValue;
                uint256 buyAmount = requiredValue * 1e18 / price;
                tokens[i].buy{ value: buyAmount }();
            }
        }
    }

    // Subscribe to the fund by sending Ether
    function subscribe() external payable {
        require(msg.value > 0, "No Ether received to subscribe");

        uint256 totalValue = getTotalFundValueInEth();

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 buyEthAmount = msg.value * targetWeights[tokens[i]] / 100;
            tokens[i].buy{ value: buyEthAmount }();
        }

        uint256 mintIndexTokenAmount = totalValue == 0 ? msg.value : msg.value * totalSupply() / totalValue;
        _mint(msg.sender, mintIndexTokenAmount);
    }

    // Redeem the fund tokens for Ether
    function redeem(uint256 fundTokenAmount) external {
        require(balanceOf(msg.sender) >= fundTokenAmount, "Insufficient fund tokens to redeem");
        _burn(msg.sender, fundTokenAmount);

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 sellAmount = fundTokenAmount * targetWeights[tokens[i]] / 100;
            tokens[i].sell(sellAmount);
        }

        payable(msg.sender).transfer(address(this).balance);
    }

    function getTotalFundValueInEth() public view returns (uint256) {
        uint256 totalValue = 0;

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 price = oracle.getPrice(address(tokens[i]));
            uint256 balance = tokens[i].getUnderlying().balanceOf(address(this));
            totalValue += price * balance / 1e18;
        }

        return totalValue;
    }

    receive() external payable { }

    fallback(bytes calldata data) external payable returns (bytes memory) { }
}
