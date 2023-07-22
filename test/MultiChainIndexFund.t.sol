// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { MultiChainIndexFund } from "../src/MultiChainIndexFund.sol";
import { AxelarMessageReceiver } from "../src/adapters/axelar/AxelarMessageReceiver.sol";
import { UniswapTokenAdapter } from "../src/adapters/UniswapTokenAdapter.sol";

import { IIndexToken } from "../src/interfaces/IIndexToken.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract MultiChainIndexFundTest is PRBTest, StdCheats {
    MultiChainIndexFund internal multiChainIndexFund;

    function setUp() public virtual {
        IIndexToken[] memory tokens = new IIndexToken[](2);

        // Replace with actual token addresses
        tokens[0] = IIndexToken(address(0x1));
        tokens[1] = IIndexToken(address(0x2));

        uint256[] memory targetWeights = new uint256[](2);
        targetWeights[0] = 50;
        targetWeights[1] = 50;

        multiChainIndexFund = new MultiChainIndexFund(tokens, targetWeights);
    }

    function test_Example() external {
        console2.log("Hello World");
        assertEq(address(multiChainIndexFund.tokens(0)), address(0x1), "value mismatch");
        assertEq(address(multiChainIndexFund.tokens(1)), address(0x2), "value mismatch");
    }
}

contract AxelarReceiverTest is PRBTest, StdCheats {
    MultiChainIndexFund internal multiChainIndexFund;

    function setUp() public virtual {
        IIndexToken[] memory tokens = new IIndexToken[](2);

        // Replace with actual token addresses
        tokens[0] = IIndexToken(address(0x1));
        tokens[1] = IIndexToken(address(0x2));

        uint256[] memory targetWeights = new uint256[](2);
        targetWeights[0] = 50;
        targetWeights[1] = 50;

        multiChainIndexFund = new MultiChainIndexFund(tokens, targetWeights);
    }

    function test_Example() external {
        console2.log("Hello World");
        assertEq(address(multiChainIndexFund.tokens(0)), address(0x1), "value mismatch");
        assertEq(address(multiChainIndexFund.tokens(1)), address(0x2), "value mismatch");
    }
}
