import { getAddress as getAddressLib, NetworkName, ZetaAddress, ZetaNetworkName } from "@zetachain/addresses";
import { network } from "hardhat";

import { isProtocolNetworkName, ZetaProtocolNetwork } from "./address.tools";

const MissingZetaNetworkError = new Error(
  "ZETA_NETWORK is not defined, please set the environment variable (e.g.: ZETA_NETWORK=athens <command>)"
);

export const ProtocolNetworkNetworkNameMap: Record<ZetaProtocolNetwork, NetworkName> = {
  baobab_testnet: "klaytn-baobab",
  bsc_testnet: "bsc-testnet",
  etherum_mainnet: "eth-mainnet",
  goerli_testnet: "goerli",
  mumbai_testnet: "polygon-mumbai",
  zeta_testnet: "athens",
};

export const getExternalAddress = (
  address: ZetaAddress,
  {
    customNetworkName,
    customZetaNetwork,
  }: { customNetworkName?: ZetaProtocolNetwork; customZetaNetwork?: ZetaNetworkName } = {}
): string => {
  const { name: _networkName } = network;

  const protocolNetworkName = customNetworkName || _networkName;

  if (!isProtocolNetworkName(protocolNetworkName)) {
    throw new Error(`network.name: ${protocolNetworkName} isn't supported.`);
  }

  const networkName = ProtocolNetworkNetworkNameMap[protocolNetworkName];

  const { ZETA_NETWORK: _ZETA_NETWORK } = process.env;
  const zetaNetwork = customZetaNetwork || _ZETA_NETWORK;

  if (!zetaNetwork) throw MissingZetaNetworkError;
  return getAddressLib({ address, networkName, zetaNetwork });
};
