import Head from 'next/head';
import Layout, { siteTitle } from '../../components/layout';
import Link from 'next/link';
import CustomImage from '../../components/customImage';
import Masthead from '../../components/masthead';
import ContentBlock from '../../components/contentBlock';

export default function SpatialNetworks() {
  return (
    <Layout spatial-networks>
      <Head>
        <title>{siteTitle}</title>
      </Head>
      <Masthead         
        title="Spatial Networks, Inc" 
        subtitle="Solving problems with Geospatial intelligence." 
      />

      <ContentBlock
        heading="Overview"
        content="I was recruited by Spatial Networks in 2010 to be the UI Designer for Allinspections, a home inspection-based data collection platform and precursor to Fulcrum. During that time I also took the lead on corporate branding, marketing, and environmental design for Spatial Networks, Inc, which had its own customer base under their DaaS (Data as a service) model. While Creative Director of Spatial Networks, I was charged with raising the standards of design quality for our existing products as well as providing conceptual design support for any potential new business ventures spearheaded by the CEO."
      />
      <CustomImage 
        src="https://campbell17.s3.amazonaws.com/work/spatial-networks/homepage.jpg" 
        height={2130} 
        width={1364} 
        layout="responsive"
        alt="Spatial Networks homepage" 
      />
      <div className="flex flex-a-start flex-j-start">
        <Link href="/projects"><a className="cta">&larr; See all Projects</a></Link>      
      </div>
    </Layout>
  );
}