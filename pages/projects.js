import Head from 'next/head';
import Layout, { siteTitle } from '../components/layout';
import { getSortedPostsData } from '../lib/posts';
import Masthead from '../components/masthead';
import Image from 'next/image';

export async function getStaticProps() {
  const allPostsData = getSortedPostsData();
  return {
    props: {
      allPostsData,
    },
  };
}

export default function Projects({allPostsData}) {
  return (
    <Layout projects>
      <Head>
        <title>{siteTitle}</title>
      </Head>
      <Masthead 
        title="Projects" 
        subtitle="Below are examples of my work. I create software interfaces, video game UI, websites, design systems, icon sets, brands, and anything else I can get my hands on." 
      />
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gridGap: 16 }}>
        <div style={{ position: 'relative', aspectRatio: '.738' }}>
          <Image layout="fill" src="https://campbell17.s3.amazonaws.com/art/tall-drawing-022321.jpg" />
        </div>
        <div style={{ position: 'relative', aspectRatio: '.738' }}>
          <Image layout="fill" src="https://campbell17.s3.amazonaws.com/art/tall-drawing-022718.jpg" />
        </div>
        <div style={{ position: 'relative', aspectRatio: '.738' }}>
          <Image layout="fill" src="https://campbell17.s3.amazonaws.com/art/tall-drawing-030218.jpg" />
        </div>
        <div style={{ position: 'relative', aspectRatio: '.738' }}>
          <Image layout="fill" src="https://campbell17.s3.amazonaws.com/art/tall-drawing-032018.jpg" />
        </div>
        <div style={{ position: 'relative', aspectRatio: '.738' }}>
          <Image layout="fill" src="https://campbell17.s3.amazonaws.com/art/tall-drawing-032518.jpg" />
        </div>
        <div style={{ position: 'relative', aspectRatio: '.738' }}>
          <Image layout="fill" src="https://campbell17.s3.amazonaws.com/art/tall-drawing-042118.jpg" />
        </div>
        <div style={{ position: 'relative', aspectRatio: '.738' }}>
          <Image layout="fill" src="https://campbell17.s3.amazonaws.com/art/tall-drawing-042418.jpg" />
        </div>
        <div style={{ position: 'relative', aspectRatio: '.738' }}>
          <Image layout="fill" src="https://campbell17.s3.amazonaws.com/art/tall-drawing-042518.jpg" />
        </div>
        <div style={{ position: 'relative', aspectRatio: '.738' }}>
          <Image layout="fill" src="https://campbell17.s3.amazonaws.com/art/tall-drawing-042519.jpg" />
        </div>
      </div>
    </Layout>
  );
}