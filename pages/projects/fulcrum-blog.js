import Head from 'next/head';
import Layout, { siteTitle } from '../../components/layout';
import Link from 'next/link';
import CustomImage from '../../components/customImage';
import Masthead from '../../components/masthead';
import ContentBlock from '../../components/contentBlock';

export default function FulcrumBlog() {
  return (
    <Layout fulcrum-blog>
      <Head>
        <title>Fulcrum Blog</title>
      </Head>
      <Masthead         
        title="Fulcrum Blog" 
        subtitle="An illustration series for the Fulcrum Product blog, 2016-2019." 
      />
      <div style={{ overflow: 'hidden', borderRadius: 8, position: "relative" }}>
        <CustomImage 
          src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/spreadsheet-to-mobile-animated.gif"
          height={220} 
          width={640}
          layout="responsive" 
          alt="Spatial Networks homepage" 
        />
      </div>      
      <ContentBlock
        heading="Overview"
        content="Before focusing on Product Design full time, I handled all the marketing design at Fulcrum which included creating featured illustrations for our blog posts."
      >
        <p>We went through a fairly prolific content creation spell with high levels of writing participation from the team, so I got to do a ton of illustrations. I was given total freedom which led to some pretty fun ones.</p>
      </ContentBlock>

      <div className="grid-container double">
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-1.jpg" alt="Layered maps on a purple background" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-2.jpg" alt="Grid of boxes on a plum background" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-3.jpg" alt="Wave line bisecting a blue background with green arrow pointing to the right" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-4.jpg" alt="Green AGS logo overlaying a green map" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-5.jpg" alt="Fulcrum icon on a blue background patterned with gear icons" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-6.jpg" alt="Empty battery icon on blue & purple gradient background" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-7.jpg" alt="Blue terrain map background underneath interconnected checkboxe icons" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-8.jpg" alt="Fleet of tiny truck illustrations arranged in groups that form triangles" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-9.jpg" alt="Navy blue background with graphs and charts overlaid" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-10.jpg" alt="Google Sheets icon with graphic extension chords attaching from both sides" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-11.jpg" alt="Isometric cube of the Fulcrum logo atop a yellow background with a pattern of arrows" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-12.jpg" alt="Fulcrum icon with hand-drawn arrows pointint to it, flanked by muscle and thumbs-up emojis on an orange background" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-13.jpg" alt="Map icons perched on water droplets sliding down a v-shaped funnel toward a single page icon" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-14.jpg" alt="Fulcrum and Docker logos on a blue & purple gradient background" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-15.jpg" alt="Large Google Calendar icon & smaller Fulcrum icon overlaying a blue abstraction of a calendar" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-16.jpg" alt="Pen & paper icon with a gold star at the top on a light blue background" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-17.jpg" alt="Fulcrum logo overlaying a green barcode" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-18.jpg" alt="Fulcrum & Carto logos with arrows pointing to each other" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-19.jpg" alt="Fulcrum icon on a blue background with faded photo of an audience with their hands up" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-20.jpg" alt="Three identical icons of a fulcrum-branded server, each more covered in vegetation than the last" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-21.jpg" alt="Fulcrum icon centered on a graphic of Earth with various software logos in orbit" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-22.jpg" alt="Fulcrum icon centered on a graphic of Earth with a gear and chat icon in orbit" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-23.jpg" alt="Fulcrum icon centered on a graphic of Earth with an illustration of a workflow above" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-24.jpg" alt="Fulcrum padlock icon over a navy blue map of Europe and the European Union ring of gold stars" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-25.jpg" alt="Fulcrum icon centered in a modified Google Drive icon" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-26.jpg" alt="Globe icon overlaying a green background patterned with lat long values" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-27.jpg" alt="Isometric map with various colored routes and pins" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-28.jpg" alt="Map with various software icons as pins" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-29.jpg" alt="Google Maps icon with Fulcrum icon and a large map pin between them" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-30.jpg" alt="Illustrations of 2 mobile devices between strips of torn paper on a blue background" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-31.jpg" alt="Forshortened view of a mobile device with Fulcrum icons stood up where app icons would be" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-32.jpg" alt="Android, desktop, and iOS devices on a blue background with the Fulcrum logo in the middle" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-33.jpg" alt="Fulcrum-branded paper shredder icon over a teal background" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-34.jpg" alt="Google Sheets icon with colored bar charts below it overlaying an abstraction of a spreadsheet" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-35.jpg" alt="Google Sheets icon overlaying an abstraction of a spreadsheet" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-36.jpg" alt="Google Sheets icon with an arrow pointing to a globe icon overlaying an abstraction of a spreadsheet" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-37.jpg" alt="Icons of abstract people with one spotlighted on a blue background" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-38.jpg" alt="Fulcrum icon over a green abstract map background" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-39.jpg" alt="Green background with Spatial Networks icon behind a white up-arrow icon" height={254} width={721} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/fulcrum/blog/singles/fulcrum-blog-40.jpg" alt="Green background with snow and an evergreen tree pattern behind a Fulcrum gift box illustration" height={254} width={721} />
      </div>

      <div className="flex flex-a-start flex-j-start">
        <Link href="/projects"><a className="cta">&larr; See all Projects</a></Link>      
      </div>
    </Layout>
  );
}