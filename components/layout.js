import Head from 'next/head';
import { Menu } from './menu'
import Footer from './footer';
import styles from './layout.module.scss';

export const siteTitle = "Tim Campbell";

export default function Layout({ children }) {
  return (
    <>
      <div className={styles.container}>
        <Head>
          <link rel="icon" href="/favicon.ico" />
          <meta
            name="description"
            content="Tim's digital home | a collection of design work, traditional art, and journal entries."
            key="desc"
          />
          <meta property="og:image" content="/images/og.jpg" />
          <meta name="og:title" content={siteTitle} />
          <meta name="twitter:card" content="summary_large_image" />
        </Head>
        <Menu />
        <main className={styles.pageGrid}>{children}</main>
      </div>
      <Footer />
    </>
  );
}