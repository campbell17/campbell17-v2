import Head from 'next/head';
import Layout from '../components/layout';
import { getSortedPostsData } from '../lib/posts';
import Link from 'next/link';
import Date from '../components/date';
import Masthead from '../components/masthead';

export async function getStaticProps() {
  const allPostsData = getSortedPostsData();
  return {
    props: {
      allPostsData,
    },
  };
}

export default function Journal({allPostsData}) {
  return (
    <Layout journal>
      <Head>
        <title>Journal of Tim Campbell</title>
      </Head>
      <Masthead 
        title="Journal" 
        subtitle="Thoughts on design, art, life, and whatever comes to mind." 
      />
      <div className="content" style={{ padding: "2em 0" }}>
        <p>Update: I use Substack for publishing now, so Journal updates here will be less frequent, if at all. If you want to read newer essays (and put some wind in my writing sails), consider subscribing below:</p>
        <iframe src="https://campbellseventeen.substack.com/embed" width="100%" height="220" style={{ border: "1px solid #ddd", backgroundColor: 'white', frameborder: 0, scrolling: "no" }}></iframe>
      </div>      
      <section className="grid-container">
        {allPostsData.map(({ id, title, date, draft }) => (
          draft != true && title ? 
          <Link href={`/journal/${id}`} key={id}>
            <a className="cardShadow" style={{ background: 'rgba(255,255,255,.25)', borderRadius: 8, padding: '8px 16px' }}>
              {title}
              <br />
              <small className="soft">
                <Date dateString={date} />
              </small>
            </a>
          </Link>
          : null            
        ))}
      </section>      
    </Layout>
  );
}