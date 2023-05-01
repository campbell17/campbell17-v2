import { useState } from 'react';
import Head from 'next/head';
import Layout, { siteTitle } from '../../components/layout';
import Link from 'next/link';
import Masthead from '../../components/masthead';
import ContentBlock from '../../components/contentBlock';
import Gallery from '../../components/gallery';
import { BlurImage } from '../../components/gallery';
import Image from 'next/image';

export default function Fulcrum() {
  const [isLoading, setLoading] = useState(true)

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
        content="Here are some examples of a few things I've designed during my tenure:"
      />
      <Link href="/projects/fulcrum/groups">
        <a className="blurOnHover">
          <div style={{ overflow: 'hidden', borderRadius: 8, position: "relative" }}>
            <Image
              alt="Groups Case Study"
              src="/images/fulcrum-groups.png"
              layout='responsive'
              width={192}
              height={108}
              objectFit="cover"
              className={
                isLoading
                  ? 'gallery-image transitioning'
                  : 'gallery-image transitioned'
              }
              onLoadingComplete={() => setLoading(false)}
            />  
            <h3 style={{ position: "absolute", width: "100%", height: "100%", top: "calc(50% - 1.6em)", textAlign: "center", zIndex: 0 }} className={ isLoading ? 'h5 tile-title transitioning' : 'h5 tile-title transitioned'}>Groups Case Study</h3>
          </div>
        </a>
      </Link>
      <Gallery fulcrumImages />
      <div className="flex flex-a-start flex-j-start">
        <Link href="/projects"><a className="cta">&larr; See all Projects</a></Link>      
      </div>
    </Layout>
  );
}