import Layout from '../../components/layout';
import { getAllPostIds, getPostData } from '../../lib/posts';
import Date from '../../components/date';
import Head from 'next/head';
import Masthead from '../../components/masthead'
import layoutStyles from '../../components/layout.module.scss';

export async function getStaticProps({ params }) {
  const postData = await getPostData(params.id);
  return {
    props: {
      postData,
    },
  }
}

export async function getStaticPaths() {
  const paths = getAllPostIds();
  return {
    paths,
    fallback: false,
  } 
}

export default function Journal({ postData }) {
  return (
    <Layout>
      <Head>
        <title>{postData.title} by Tim Campbell</title>
      </Head>
      <article className="post-content">
        <p class="overline">
          <Date dateString={postData.date} />
        </p>
        <Masthead         
          title={postData.title} 
          subtitle={postData.subtitle}
        />
        <div className={layoutStyles.innerContentGrid} dangerouslySetInnerHTML={{ __html: postData.contentHtml }} />
      </article>
    </Layout>
  )
}

