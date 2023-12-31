import type { NextPage } from 'next';
import Head from 'next/head';
import styles from '../styles/Home.module.css';
import { Portfolio } from '../components'


const Home: NextPage = () => {
  return (
    <div className={styles.container}>
      <Head>
        <title>Ratatouille 500</title>
        <meta
          content="Generated by @rainbow-me/create-rainbowkit"
          name="description"
        />
        <link href="/favicon.ico" rel="icon" />
      </Head>

      <main>
        <Portfolio />
      </main >
    </div >
  );
};

export default Home;
