import Head from 'next/head';
import Layout, { siteTitle } from '../../components/layout';
import Link from 'next/link';
import Masthead from '../../components/masthead';
import ContentBlock from '../../components/contentBlock';
import CustomImage from '../../components/customImage';

export default function Divide() {
  return (
    <Layout divide>
      <Head>
        <title>Divide Game</title>
      </Head>
      <Masthead         
        title="Divide" 
        subtitle="A character-driven, science fiction action/adventure game with a modern take on isometric adventures of the past." 
      />
      <ContentBlock
        heading="Overview"
        content="Divide is character-driven, science fiction action/adventure game released on PS4 & Steam. It's a modern take on old isometric adventure games and I was hired to design the in-game UI, AR textures, menus, HUD, icons, and lore content (posters, signs, etc). I also designed the logo, PS4 splash screens & Trophy assets, game conference collateral, and soundtrack artwork. As a lifelong gamer I have to admit it was pretty special to see my name in the credits after beating it."
      />
      <div className="grid-container single">
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/divide-0.jpg" alt="White Divide logo over black background with a faded in-game screenshot" width={1280} height={844} />
      </div>

      <div className="grid-container">
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/divide-cover-0.jpg" alt="The Divide logo with the text 'Divide EP, Extended play soundtrack, music by Chris Tilton' over blue sky and skyscraper in the distance" width={512} height={512} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/divide-cover-1.jpg" alt="divide soundtrack art" width={512} height={512} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/divide-cover-2.jpg" alt="divide soundtrack art" width={512} height={512} />
      </div>

      <div className="grid-container single">
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/concrete-vestige-better-world.jpg" alt="divide poster" width={1024} height={512} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/concrete-vestige-simpler.jpg" alt="divide poster" width={1024} height={512} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/concrete-vestige-tomorrow.jpg" alt="divide poster" width={1024} height={512} />      
      </div>

      <div className="grid-container double">
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/ui-icons.jpg" alt="divide UI - icons" width={720} height={527} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/ui-ar.jpg" alt="divide UI - AR" width={720} height={527} />
      </div>

      <div className="grid-container double">
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/solus-1.jpg" alt="divide UI - Solus" width={1440} height={720} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/solus-2.jpg" alt="divide UI - Solus" width={1440} height={720} />
      </div>

      <div className="grid-container">
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/ps5-cover.jpg" alt="divide console game cover" width={1440} height={810} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/ps5-library.jpg" alt="divide console library" width={1440} height={810} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/ps5-trophies.jpg" alt="divide console trophies" width={1440} height={810} />
      </div>

      <div className="grid-container single">
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/divide-2-lg.jpg" alt="divide UI - HUD" width={1920} height={1080} />
      </div>

      <div className="grid-container quad">
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_CitizenID_CheckIns_Generic.jpg" alt="divide graphic" width={512} height={1024} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_CitizenID_Clearances_Visa.jpg" alt="divide graphic" width={512} height={1024} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_CitizenID_Hardware_Solus.jpg" alt="divide graphic" width={512} height={1024} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_CitizenID_Software_Access.jpg" alt="divide graphic" width={512} height={1024} />        
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_CitizenID_Clearances_Alpha.jpg" alt="divide graphic" width={512} height={1024} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_CitizenID_Clearances_Bravo.jpg" alt="divide graphic" width={512} height={1024} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_CitizenID_Clearances_Charlie.jpg" alt="divide graphic" width={512} height={1024} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_CitizenID_Clearances_India.jpg" alt="divide graphic" width={512} height={1024} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_CitizenID_Hardware_AgentSuitAdvanced.jpg" alt="divide graphic" width={512} height={1024} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_CitizenID_Hardware_ArmorAdapter.jpg" alt="divide graphic" width={512} height={1024} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_CitizenID_Hardware_CapacitorPerma.jpg" alt="divide graphic" width={512} height={1024} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_CitizenID_Hardware_CapacitorPort.jpg" alt="divide graphic" width={512} height={1024} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_Database_REN_Generic.jpg" alt="divide graphic" width={512} height={1024} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_Database_SteadyStream_InterplanetaryVesselTheEndeavor.jpg" alt="divide graphic" width={512} height={1024} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_Database_SteadyStream_Maglev-Current.jpg" alt="divide graphic" width={512} height={1024} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/work/divide/XCRD_Database_SteadyStream_OceanReport.jpg" alt="divide graphic" width={512} height={1024} />
      </div>

      <div className="flex flex-a-start flex-j-start">
        <Link href="/projects"><a className="cta">&larr; See all Projects</a></Link>     
      </div>
    </Layout>
  );
}