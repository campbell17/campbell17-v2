import Head from 'next/head';
import Layout, { siteTitle } from '../../components/layout';
import Link from 'next/link';
import Masthead from '../../components/masthead';
import ContentBlock from '../../components/contentBlock';
import Gallery from '../../components/gallery';

export default function Fulcrum() {
  return (
    <Layout fulcrum>
      <Head>
        <title>Fulcrum</title>
      </Head>
      <Masthead         
        title="Fulcrum" 
        subtitle="The better way to collect data and manage your field inspections." 
      />

      <ContentBlock
        heading="Overview"
        content="Fulcrum was created in 2011 to scratch an itch that surfaced from our parent company, Spatial Networks. Its value to a wider market presented itself almost immediately and I was asked to design the logo, marketing website, and the look and feel of the product."
      >
        <p>Since then, I've lead the design on every product feature, brand refresh, marketing website, slide deck, trade show tchotchke, all-hands t-shirt, and any other creative need that's bubbled up. In 2020, I moved over to Product Design full time after Fulcrum was acquired and the organization changed hands.</p>
      </ContentBlock>
      <ContentBlock
        heading="The Work"
        content="I'm currently writing a full case study and condensing 12+ years into a cohesive thread is just as hard as it sounds. In the meantime here are some examples of a few things I've designed during my tenure:"
      />
      <Gallery fulcrumImages />
      <div className="flex flex-a-start flex-j-start">
        <Link href="/projects"><a className="cta">&larr; See all Projects</a></Link>      
      </div>
    </Layout>
  );
}