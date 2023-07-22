import fs from "fs";
import path from "path";

export const addresses = JSON.parse(
  fs.readFileSync(path.resolve(__dirname, "..", "data", "addresses.json")).toString()
);

export declare type ZetaProtocolAddress =
  | "connector"
  | "immutableCreate2Factory"
  | "tss"
  | "tssUpdater"
  | "zetaToken"
  | "zetaTokenConsumerUniV2"
  | "zetaTokenConsumerUniV3";

export const zetaProtocolAddress: ZetaProtocolAddress[] = [
  "connector",
  "immutableCreate2Factory",
  "tss",
  "tssUpdater",
  "zetaToken",
  "zetaTokenConsumerUniV2",
  "zetaTokenConsumerUniV3",
];
export const isZetaProtocolAddress = (str: string): str is ZetaProtocolAddress =>
  zetaProtocolAddress.includes(str as ZetaProtocolAddress);

export declare type ZetaZEVMAddress = "geth" | "systemContract" | "tbnb" | "tmatic";
export declare type ZetaProtocolTestNetwork =
  | "baobab_testnet"
  | "bsc_testnet"
  | "goerli_testnet"
  | "mumbai_testnet"
  | "zeta_testnet";

export const zetaProtocolTestNetworks: ZetaProtocolTestNetwork[] = [
  "baobab_testnet",
  "bsc_testnet",
  "goerli_testnet",
  "mumbai_testnet",
  "zeta_testnet",
];

export declare type NonZetaAddress = "uniswapV2Router02" | "uniswapV3Factory" | "uniswapV3Router" | "weth9";

export const nonZetaAddress: NonZetaAddress[] = ["uniswapV2Router02", "uniswapV3Router", "uniswapV3Factory", "weth9"];

export declare type ZetaProtocolMainNetwork = "etherum_mainnet";
export const zetaProtocolMainNetworks: ZetaProtocolMainNetwork[] = ["etherum_mainnet"];

export declare type ZetaProtocolNetwork = ZetaProtocolMainNetwork | ZetaProtocolTestNetwork;
export const zetaProtocolNetworks: ZetaProtocolNetwork[] = [...zetaProtocolTestNetworks, ...zetaProtocolMainNetworks];

export declare type ZetaProtocolEnviroment = "mainnet" | "testnet";

export const isProtocolNetworkName = (str: string): str is ZetaProtocolNetwork =>
  zetaProtocolNetworks.includes(str as ZetaProtocolNetwork);

export const isTestnetNetwork = (network: ZetaProtocolTestNetwork): boolean => {
  return zetaProtocolTestNetworks.includes(network);
};

export const isMainnetNetwork = (network: ZetaProtocolTestNetwork): boolean => {
  return false;
};

export const getAddress = (address: ZetaProtocolAddress | ZetaZEVMAddress, network: ZetaProtocolNetwork): string => {
  if (isZetaProtocolAddress(address)) {
    return addresses["ccm"][network][address];
  }

  return addresses["zevm"][network][address];
};

export const getZRC20Address = (network: ZetaProtocolNetwork): string => {
  return addresses["zevm"][network]["zrc20"];
};

export const getNonZetaAddress = (address: NonZetaAddress, network: ZetaProtocolNetwork): string => {
  return addresses["non-zeta"][network][address];
};
