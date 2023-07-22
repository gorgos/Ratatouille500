// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IOracle } from "./interfaces/IOracle.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/interfaces/AggregatorV3Interface.sol";

contract Oracle is IOracle {
    // Chainlink LINK/ETH Goerli
    AggregatorV3Interface private oracle = AggregatorV3Interface(0xb4c4a493AB6356497713A78FFA6c60FB53517c63);

    function getPrice(address token) external view returns (uint256) {
        if (token == 0x326C977E6efc84E512bB9C30f76E30c160eD06FB) {
            (, int256 price,,,) = oracle.latestRoundData();
            return uint256(price);
        }

        // dummy data
        return 1e18;
    }
}
