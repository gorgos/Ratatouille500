import { isLocalNetworkName } from "@zetachain/addresses";
import { ethers, network } from "hardhat";

import { isEthNetworkName } from "../../../lib/contracts.helpers";
import { setZetaAddresses } from "../../tools/set-zeta-token-addresses";
import { deployZetaConnector } from "./deploy-zeta-connector";
import { deployZetaToken } from "./deploy-zeta-token";

async function main() {
  if (isLocalNetworkName(network.name)) {
    const [owner] = await ethers.getSigners();
  }

  const zetaTokenAddress = await deployZetaToken();
  const connectorAddress = await deployZetaConnector();

  /**
   * @description The Eth implementation of Zeta token doesn't need any address
   */
  if (isEthNetworkName(network.name)) return;

  /**
   * @description Avoid setting Zeta addresses for local network,
   * since it must be done after starting the local Zeta node
   */
  if (!isLocalNetworkName(network.name)) {
    await setZetaAddresses(connectorAddress, zetaTokenAddress);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
