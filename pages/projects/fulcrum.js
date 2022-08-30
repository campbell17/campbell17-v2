import Head from 'next/head';
import Layout, { siteTitle } from '../../components/layout';
import Masthead from '../../components/masthead';
import Gallery from '../../components/gallery'

export default function Fulcrum() {
  return (
    <Layout projects>
      <Head>
        <title>{siteTitle}</title>
      </Head>
      <Masthead 
        title="Fulcrum" 
        subtitle="Below are examples of my work. I create software interfaces, video game UI, websites, design systems, icon sets, brands, and anything else I can get my hands on." 
      />
      <Gallery />
    </Layout>
  );
}