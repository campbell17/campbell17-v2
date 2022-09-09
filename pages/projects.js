import Head from 'next/head';
import Layout from '../components/layout';
import Masthead from '../components/masthead';
import Gallery from '../components/gallery'

export default function Projects() {
  return (
    <Layout projects>
      <Head>
        <title>Projects by Tim Campbell</title>
      </Head>
      <Masthead 
        title="Projects" 
        subtitle="I create software interfaces, video game UI, websites, design systems, icon sets, brands, and anything else I can get my hands on." 
      />
      <Gallery projectsImages />
    </Layout>
  );
}