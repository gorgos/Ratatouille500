import dynamic from 'next/dynamic';
import { Box, Text, Heading, Button, Flex, Stack, Stat, StatLabel, StatNumber, InputGroup, Input, InputRightAddon, ChakraProvider, Table, Thead, Tbody, Tr, Th, Td, Grid, VStack } from '@chakra-ui/react';
import React, { useState, useEffect } from 'react'
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { portfolio } from '../data/chain-data';
import { ethers, AlchemyProvider } from 'ethers'
import abi from '../data/abi.json'
import { usePublicClient, useWalletClient } from 'wagmi'

const ApexChart = dynamic(() => import('react-apexcharts'), { ssr: false });


const MemoizedApexChart = React.memo(({ options, series, type }) => (
  <ApexChart options={options} series={series} type={type} />
));


export const Portfolio = () => {
  const { data: signer } = useWalletClient()
  const provider = usePublicClient()
  const contract = new ethers.Contract("0x478C2D2698F162C55E064C8C3B1f4F9E2Abb1181", abi.abi, signer)

  const [tokenSelected, setTokenSelected] = useState('ETH')
  const [userTokenBalance, setUserTokenBalance] = useState()

  useEffect(() => {
    const interval = setInterval(() => {
      getUserTokenBalance()
    }, 15000)

    // This is the cleanup function. It will be called before a new interval is started by a re-render.
    return () => {
      clearInterval(interval)
    }
  }, [])

  useEffect(() => {
    getUserTokenBalance()
  }, [])

  const handleSubscribe = () => {
    const formattedAmount = buyTokenAmount * 10 ** 18
    contract.subscribe({ value: formattedAmount.toFixed() }).then(() => {
      setBuyTokenAmount('');
    })
  }

  const tokenData = {
    name: "Ratatouille 500",
    description: "Stirring up tokens into one fanciful pot",
    components: [
      { token: "ETH", price: 4000, weight: 0.2 },
      // add more tokens here
    ],
  };

  const getUserTokenBalance = async () => {
    const alchemyProvider = new AlchemyProvider("goerli", '1JY5meElVcdGRrGpQGU6TxG1geduQi49');

    const providerContract = new ethers.Contract("0x478C2D2698F162C55E064C8C3B1f4F9E2Abb1181", abi.abi, alchemyProvider)



    const balance = await providerContract.balanceOf('0x16aEF18dbAA341952f1aF1795cB49960f68DfEe3') || 0

    const formattedBalance = Number(balance) / Number(BigInt(10n ** BigInt(18)))

    setUserTokenBalance(formattedBalance)
  }


  // const { wallet } = useWallet();
  const wallet = '1343'
  const [buyTokenAmount, setBuyTokenAmount] = useState();
  const [sellTokenAmount, setSellTokenAmount] = useState();
  // const [userTokenBalance, setUserTokenBalance] = useState(0);



  const handleSell = async () => {
    const result = BigInt(sellTokenAmount * 10e18)


    await contract.redeem(result)
  };

  const tokenPriceEth = tokenData.components.reduce((total, component) => total + component.price * component.weight, 0);

  const [tokens, setTokens] = useState([]);

  // Assume we have a hook to fetch token data
  const useFetchTokenData = () => null
  const { data, isLoading, error } = useFetchTokenData() || { data: '', isLoading: false, error: '' }

  // if (isLoading) return <div>Loading...</div>;
  // if (error) return <div>Error: {error.message}</div>;

  const donutOptions = {
    labels: portfolio.map((token) => token.symbol),
    legend: {
      show: false,
    },
    chart: {
      height: 300,
      type: 'donut',
    },
    responsive: [
      {
        breakpoint: 480,
        options: {
          chart: {
            height: 300,
            width: 300,   // Adjust chart width
          },
          legend: {
            position: 'bottom',
          },
        },
      },
    ],
    tooltip: {
      y: {
        formatter: function (value) {
          return `${value}%`;
        },
      },
    },

    pie: {
      donut: {
        labels: {
          show: true,
          name: {
            // show: true,
            fontSize: '16px',
            fontFamily: 'Helvetica, Arial, sans-serif',
            color: '#fff',
            offsetY: -10,
            formatter: function (seriesName, opts) {
              // Add custom code to format seriesName here
              // e.g., return seriesName.toUpperCase();
              return 'bananas';
            },
          },
          value: {
            show: false,
            formatter: function (value, opts) {
              // Add custom code to format value here
              // e.g., return value.toFixed(2);
              return 'bananas'
            },
          },
          total: {
            show: false,
          }
        }
      }
    }
  }


  const donutSeries = portfolio.map((token) => token.weight);

  return (
    <div>
      <Flex width="100%" mb="50px">
        <Box flex="1" />
        <Box flex="1" textAlign="center" w="300px">
          <Heading mb={2}>{tokenData.name}</Heading>
          <Box overflow="auto">
            <Text mb={5}>{tokenData.description}</Text>
          </Box>
        </Box>

        <Box flex="1" textAlign="right" display="flex" justifyContent="flex-end">
          <div>
            <ConnectButton accountStatus="avatar" chainStatus="icon" />
          </div>

        </Box>
      </Flex>

      <Box mr="2" w="100" >
        <InputGroup>
          <Flex justifyContent="center" width="100%">
            <Box w="600px">
              <InputGroup>
                <Grid templateColumns="repeat(2, 1fr)" gap={4}>
                  <VStack spacing={4}>
                    <InputGroup>
                      <Input
                        type="number"
                        value={buyTokenAmount}
                        onChange={(e) => setBuyTokenAmount(e.target.value)}
                      />
                      <InputRightAddon bg="gray.700" children="ETH" />
                    </InputGroup>
                    <Button colorScheme="teal" variant="solid" onClick={handleSubscribe}>
                      Buy {tokenData.name}
                    </Button>
                  </VStack>

                  <VStack spacing={4}>
                    <InputGroup>
                      <Input
                        type="number"
                        value={sellTokenAmount}
                        onChange={(e) => setSellTokenAmount(e.target.value)}
                      />
                      <InputRightAddon bg="gray.700" children="Ratatouille 500" />
                    </InputGroup>
                    <Button colorScheme="red" variant="solid" onClick={handleSell}>
                      Sell {tokenData.name}
                    </Button>
                  </VStack>
                </Grid>
              </InputGroup>
            </Box>
          </Flex>
        </InputGroup>

        <Flex justifyContent="center" marginTop="20">
          <Text fontSize="36px">Your balance: {parseFloat(userTokenBalance).toFixed(8)} {tokenData.name}</Text>
        </Flex>



        <Flex mt="100" justify="space-between" height="550px">
        <Table variant="simple" mt={5} flex="1" size="sm">
          <Thead>
            <Tr>
              <Th py={0}>Name</Th>
              <Th py={0}>Address</Th>
              <Th py={0}>Price</Th>
              <Th py={0}>Weight</Th>
              <Th py={0}>Chain</Th>
            </Tr>
          </Thead>
          <Tbody>
            {portfolio.map((token) => (
              <Tr key={token.symbol}>
                <Td py={0}>{token.symbol}</Td>
                <Td isTruncated maxWidth="200px" py={0}>{token.address}</Td>
                <Td py={0}>${token.price}</Td>
                <Td py={0}>{token.weight}%</Td>
                <Td py={0}>{token.chain}</Td>
              </Tr>
            ))}
          </Tbody>
        </Table>


<Box flex="1" ml="2" paddingTop="0" marginTop="-50" maxHeight="300px">
  <MemoizedApexChart options={donutOptions} series={donutSeries} type="donut" maxHeight="300px" />
</Box>
        </Flex>
      </Box>
    </div >)
}

