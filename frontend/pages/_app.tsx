import '../styles/globals.css';
import '@rainbow-me/rainbowkit/styles.css';
import { getDefaultWallets, RainbowKitProvider } from '@rainbow-me/rainbowkit';
import type { AppProps } from 'next/app';
import { configureChains, createConfig, WagmiConfig } from 'wagmi';
import {
  arbitrum,
  goerli,
  mainnet,
  optimism,
  polygon,
  zora,
  filecoinCalibration,
  lineaTestnet,
  mantleTestnet,
  polygonZkEvmTestnet,
  celoAlfajores,
  zkSyncTestnet,
  gnosisChiado,
} from 'wagmi/chains';
import { ChakraProvider } from '@chakra-ui/react';
import { publicProvider } from 'wagmi/providers/public';
import { alchemyProvider } from 'wagmi/providers/alchemy';
import theme from "../theme";



const { chains, publicClient } = configureChains(
  [
    goerli,
    filecoinCalibration,
    lineaTestnet,
    mantleTestnet,
    polygonZkEvmTestnet,
    celoAlfajores,
    zkSyncTestnet,
    gnosisChiado,
  ],
  [publicProvider(), alchemyProvider({
    // This is Alchemy's default API key.
    // You can get your own at https://dashboard.alchemyapi.io
    apiKey: process.env.NEXT_PUBLIC_ALCHEMY_ID || ''
  }),]
);

const { connectors } = getDefaultWallets({
  appName: 'Ratatouille 500',
  projectId: 'RATA500',
  chains
});

const wagmiConfig = createConfig({
  autoConnect: true,
  connectors,
  publicClient,
});


function MyApp({ Component, pageProps }: AppProps) {
  return (
    <WagmiConfig config={wagmiConfig}>
      <RainbowKitProvider chains={chains}>
        <ChakraProvider theme={theme}>
          <Component {...pageProps}>
          </Component>
        </ChakraProvider>
      </RainbowKitProvider>
    </WagmiConfig>
  );
}

export default MyApp;
