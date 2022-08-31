import Head from 'next/head';
import Layout, { siteTitle } from '../../components/layout';
import Masthead from '../../components/masthead';
import ContentBlock from '../../components/contentBlock';
import Gallery from '../../components/gallery';

export default function Fulcrum() {
  return (
    <Layout fulcrum>
      <Head>
        <title>{siteTitle}</title>
      </Head>
      <Masthead         
        title="Fulcrum" 
        subtitle="Fulcrum was created in 2011 to scratch an itch that surfaced from our parent company, Spatial Networks. Its value to a wider market presented itself almost immediately and I was asked to design the logo, marketing website, and the look and feel of the product." 
      >
        <p>Since then, I've lead the design on every product feature, brand refresh, marketing website, slide deck, trade show tchotchke, all-hands t-shirt, and any other creative need that's bubbled up. In 2020, I moved over to Product Design full time after Fulcrum was acquired and the organization changed hands.</p>
        <p>Below are a handful of examples of some of my work from my time here:</p>
      </Masthead>
      
      <Gallery />
    </Layout>
  );
}