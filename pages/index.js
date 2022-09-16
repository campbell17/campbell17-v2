import Head from 'next/head';
import Layout from '../components/layout';
import { getSortedPostsData } from '../lib/posts';
import Link from 'next/link';
import Date from '../components/date';
import Masthead from '../components/masthead';
import ContentBlock from '../components/contentBlock';
import Gallery from '../components/gallery';

export async function getStaticProps() {
  const allPostsData = getSortedPostsData();
  return {
    props: {
      allPostsData,
    },
  };
}

export default function Home({allPostsData}) {
  return (
    <Layout home>
      <Head>
        <title>Tim Campbell</title>
      </Head>
      <Masthead 
        title="Hi, I'm Tim."
        subtitle="I'm a software designer living in the Keystone State. I'm shaping new feature strategy and design at Fulcrum, focusing on the quality and continued evolution of the UI/UX." 
      />
      <ContentBlock
        heading="My Approach"
        content="As a generalist, I like learning new things, growing in different areas, gaining new perspective, and expanding my capacity to understand."
      >
        <p>This trait couples well with my undying faith in the 80/20 rule - cutting to the bone of a problem and getting it shipped beats trying to make an already pretty thing prettier.</p>
      </ContentBlock>
      <ContentBlock
        heading="Projects"
        content="My work is a mix of design, illustration, and creative direction. Check out some highlights:"
        >
        <Gallery homeImages />
      </ContentBlock>
      <div className="flex flex-a-start flex-j-start">
        <Link href="/projects"><a className="cta">All Projects &rarr;</a></Link>      
      </div>

      <ContentBlock
        heading="Journal"
        content="Some observations and general meanderings. Here's a few I like:"
      >
        <section>
          <ul className="no-style">
            {allPostsData.map(({ id, date, title, homepage }) => (
              homepage ? <li key={id}>
                <Link href={`/journal/${id}`}>
                  <a>{title}</a>
                </Link>
                <br />
                <small>
                  <Date dateString={date} />
                </small>
              </li>      
              : null      
            ))}
          </ul>
        </section>      
      </ContentBlock>
      <div className="flex flex-a-start flex-j-start">
        <Link href="/journal"><a className="cta">All Entries &rarr;</a></Link>      
      </div>
   </Layout>
  );
}