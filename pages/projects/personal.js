import Head from 'next/head';
import Layout, { siteTitle } from '../../components/layout';
import Link from 'next/link';
import Masthead from '../../components/masthead';
import CustomImage from '../../components/customImage';

export default function Personal() {
  return (
    <Layout personal>
      <Head>
        <title>Personal Work</title>
      </Head>
      <Masthead         
        title="Personal Work" 
        subtitle="I studied traditional illustration and photography before I became a designer and I still practice when I can. I'm still hungry to improve, and while my biggest source of creative frustration is a botching drawing, it's also one of the most rewarding things when it goes right." 
      />
      <div className="grid-container">
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-022321.jpg" alt="Graphite drawing, woman's face in three quarter view" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-022718.jpg" alt="Graphite drawing, woman's face with hair obscuring one eye " width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-030218.jpg" alt="Graphite drawing, woman's face in profile with her hair up" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-032018.jpg" alt="Graphite drawing, woman looking to the side" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-032518.jpg" alt="Graphite drawing, woman with hair up in a turtleneck looking straight ahead" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-042118.jpg" alt="Graphite drawing, woman with long blonde hair looking straight ahead" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-042418.jpg" alt="Pen & ink drawing, woman in collared shirt, three quarter view" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-042518.jpg" alt="Pen & ink drawing, woman with long hair in choker necklace, looking straight ahead" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-042618.jpg" alt="Pen & ink drawing, woman with long hair, eyes closed in a black shirt turned to the side" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-042519.jpg" alt="Ilustration of a Falcon with its talons up and wings spread" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-claptrap.jpg" alt="Drawings of ClapTrap from the Borderlands video game franchise" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-081719.jpg" alt="Painting of a male cardinal perched on a branch" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-042918.jpg" alt="Graphite & charcoal drawing, woman's face close up looking straight ahead" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-050618.jpg" alt="Ink & marker sketch, woman turned to the side looking back toward the viewer" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-052018.jpg" alt="Pen & ink drawing, woman with black hair and eyes closed looking slightly upwards" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-062018.jpg" alt="Ink & marker sketch of girl in close-up, eyes closed in white shirt, three quarter view" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-062918.jpg" alt="Ink & marker illustration of girl with hoop earrings, teal hair in a teal and chartreuse striped blouse, leaning forward" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-071517.jpg" alt="Mixed media sketch of woman in black dress, back turned" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-072817.jpg" alt="Pen & ink sketch of woman in black dress with one hand on her head and the other on her hip, eyes closed" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-100318.jpg" alt="Drawing of a grimacing Emma Watson with an expressionless emoji thought bubble" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-100518.jpg" alt="Ink & marker sketch of a young woman with a yellow chick on here shirt, looking forward" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-102720.jpg" alt="Light graphite sketch of a woman in three quarter view with her hair up" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-102820.jpg" alt="Graphite drawing, woman with long hair in profile" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-102920.jpg" alt="Graphite drawing, woman with hair up, looking down and slightly over her shoulder" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-103020.jpg" alt="Graphite drawing, woman with long hair in profile" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-110520.jpg" alt="Graphite sketch, woman with long hair and bangs in three quarter view" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-111120.jpg" alt="Graphite sketch, woman with head tilted, looking straight ahead" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-drawing-112720.jpg" alt="Graphite sketch, looking up at a woman in profile" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-painting-072317.jpg" alt="Oil painting, woman in green shirt with long black hair, looking straigt ahead" width={640} height={867} />
        <CustomImage src="https://campbell17.s3.amazonaws.com/art/tall-painting-110520.jpg" alt="Acrylic painting, brown haired woman in blue coat looking skyward" width={640} height={867} />
      </div>
      <div className="flex flex-a-start flex-j-start">
        <Link href="/projects" className="cta">&larr; See all Projects</Link>      
      </div>
    </Layout>
  );
}