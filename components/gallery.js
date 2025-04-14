import Image from 'next/image';
import Link from 'next/link';
import { useState } from 'react';

export default function Gallery(props) {
  const homeGallery = props.homeImages;
  const indexGallery = props.projectsImages;
  const fulcrumGallery = props.fulcrumImages;

  const homeImages = [
    { link: "/projects/fulcrum", linkTitle: "Fulcrum", category: "art", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/square/fulcrum.jpg", alt: "Fulcrum icon, a red triangle enclosed in a red circle", title: "" },
    { link: "/projects/divide", linkTitle: "Divide", category: "work", subcategory: "divide", src: "https://campbell17.s3.amazonaws.com/work/square/divide.jpg", alt: "Illustration of blurry person on a bridge overlooking a city with a lone skyscraper", title: "" },
    { link: "/projects/personal", linkTitle: "Personal", category: "art", subcategory: "drawing", src: "https://campbell17.s3.amazonaws.com/work/square/personal-alt.jpg", alt: "Drawing of a grimacing Emma Watson with an expressionless emoji thought bubble", title: "" },
  ]
  const projectsImages = [
    { link: "/projects/fulcrum", linkTitle: "Fulcrum", category: "art", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/square/fulcrum.jpg", alt: "", title: "" },
    { link: "/projects/fulcrum-blog", linkTitle: "Fulcrum Blog", category: "art", subcategory: "fulcrum blog", src: "https://campbell17.s3.amazonaws.com/work/square/fulcrum-blog.gif", alt: "", title: "" },
    { link: "/projects/spatial-networks", linkTitle: "Spatial Networks, Inc", category: "art", subcategory: "spatial networks", src: "https://campbell17.s3.amazonaws.com/work/square/sni.jpg", alt: "", title: "" },
    { link: "/projects/divide", linkTitle: "Divide", category: "work", subcategory: "divide", src: "https://campbell17.s3.amazonaws.com/work/square/divide.jpg", alt: "", title: "" },
    { link: "/projects/personal", linkTitle: "Personal", category: "art", subcategory: "drawing", src: "https://campbell17.s3.amazonaws.com/work/square/personal-alt.jpg", alt: "", title: "" },
  ]
  const fulcrumImages = [
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-homescreen.png", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-tasks.png", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-issues.png", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-future.png", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-2.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-guides.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-mini-1-wide.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-mini-2-wide.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-mini-3-wide.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-mini-4-wide.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-mini-5-wide.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-mini-6-wide.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-mini-7-wide.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-mini-8-wide.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-8.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-9.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-10.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-11.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-12.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-sticker-3-wide.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-sticker-2-wide.jpg", alt: "", title: "" },
    { category: "work", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/fulcrum/fulcrum-sticker-1-wide.jpg", alt: "", title: "" },
  ]

  return (  
    <div>
      {homeGallery &&
        <div className="grid-container">
          {homeImages.map((index) => (
            <BlurImage key={index.src} src={index.src} link={index.link} linkTitle={index.linkTitle} alt={index.alt}  />      
          ))}
        </div>
      }
      {indexGallery &&
        <div className="grid-container double">
          {projectsImages.map((index) => (
            <BlurImage key={index.src} src={index.src} link={index.link} linkTitle={index.linkTitle} alt={index.alt}  />      
          ))}
        </div>
      }
      {fulcrumGallery &&
        <div className="grid-container double">
          {fulcrumImages.map((index) => (
            <ImageUnlinked key={index.src} src={index.src} alt={index.alt} />      
          ))}
        </div>
      }
    </div>    
  )
}

function BlurImage(index) {
  const [isLoading, setLoading] = useState(true)

  return (
    <Link href={index.link} className="blurOnHover">
      <div style={{ 
        aspectRatio: '1', 
        overflow: 'hidden', 
        borderRadius: 8, 
        position: "relative",
      }}>
        <Image
          alt={index.alt}
          src={index.src}
          fill
          sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
          style={{ objectFit: 'cover' }}
          className={
            isLoading
              ? 'gallery-image transitioning'
              : 'gallery-image transitioned'
          }
          onLoad={() => setLoading(false)}
        />
        <h3 
          style={{ 
            position: "absolute", 
            width: "100%", 
            height: "100%", 
            top: "calc(50% - 1.6em)", 
            textAlign: "center", 
            zIndex: 0 
          }} 
          className={ isLoading ? 'h5 tile-title transitioning' : 'h5 tile-title transitioned'}
        >
          {index.linkTitle}
        </h3>
      </div>
    </Link>
  )
}

function ImageUnlinked(index) {
  const [isLoading, setLoading] = useState(true)

  return (
    <div style={{ 
      overflow: 'hidden', 
      borderRadius: 8, 
      position: "relative",
      aspectRatio: '16/9'
    }}>
      <Image
        alt={index.alt}
        src={index.src}
        fill
        sizes="(max-width: 768px) 100vw, 50vw"
        style={{ objectFit: 'cover' }}
        className={
          isLoading
            ? 'gallery-image transitioning'
            : 'gallery-image transitioned'
        }
        onLoad={() => setLoading(false)}
      />
    </div>
  )
}
