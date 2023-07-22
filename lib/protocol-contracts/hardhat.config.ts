import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-etherscan";
import "@typechain/hardhat";
import "tsconfig-paths/register";
import "hardhat-abi-exporter";

import { getHardhatConfigNetworks } from "@zetachain/networks";
import * as dotenv from "dotenv";
import type { HardhatUserConfig } from "hardhat/types";

dotenv.config();

const PRIVATE_KEYS = process.env.PRIVATE_KEY !== undefined ? [`0x${process.env.PRIVATE_KEY}`] : [];

const config: HardhatUserConfig = {
  networks: {
    ...getHardhatConfigNetworks(PRIVATE_KEYS),
    hardhat: {
      chainId: 1337,
      forking: {
        blockNumber: 14672712,
        url: "https://rpc.ankr.com/eth",
      },
    },
  },
  solidity: {
    compilers: [
      { version: "0.4.19" /** For zevm/wzeta.sol */ },
      { version: "0.5.10" /** For create2 factory */ },
      {
        settings: {
          optimizer: {
            enabled: true,
            runs: 999999,
          },
        },
        version: "0.5.16",
      },
      {
        settings: {
          optimizer: {
            enabled: true,
            runs: 999999,
          },
        },
        version: "0.6.6" /** For uniswap v2 */,
      },
      { version: "0.7.6" /** For uniswap v3 */ },
      { version: "0.8.7" },
    ],
  },
};

export default config;
