// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IIndexToken {
    function getUnderlying() external view returns (IERC20);
    function buy() external payable;
    function sell(uint256 tokenAmount) external payable;
}
