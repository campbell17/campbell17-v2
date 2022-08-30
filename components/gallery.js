import Image from 'next/image';
import { useState } from 'react'

export default function Gallery() {
  const images = [
    { link: "/projects/fulcrum", linkTitle: "Fulcrum", category: "art", subcategory: "fulcrum", src: "https://campbell17.s3.amazonaws.com/work/square/fulcrum.jpg", alt: "", title: "" },
    { link: "/projects/fulcrum-blog", linkTitle: "Fulcrum Blog", category: "art", subcategory: "fulcrum blog", src: "https://campbell17.s3.amazonaws.com/work/square/fulcrum-blog.gif", alt: "", title: "" },
    { link: "/projects/spatial-networks", linkTitle: "Spatial Networks, Inc", category: "art", subcategory: "spatial networks", src: "https://campbell17.s3.amazonaws.com/work/square/sni.jpg", alt: "", title: "" },
    { link: "/projects/allinspections", linkTitle: "Allinspections", category: "work", subcategory: "allinspections", src: "https://campbell17.s3.amazonaws.com/work/square/allinspections.jpg", alt: "", title: "" },
    { link: "/projects/divide", linkTitle: "Divide", category: "work", subcategory: "divide", src: "https://campbell17.s3.amazonaws.com/work/square/divide.jpg", alt: "", title: "" },
    { link: "/projects/personal", linkTitle: "Personal", category: "art", subcategory: "drawing", src: "https://campbell17.s3.amazonaws.com/work/square/personal-alt.jpg", alt: "", title: "" },
  ]
  
  return (  
    <div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gridGap: 16 }}>
        {images.map((index) => (
          <BlurImage key={index.src} src={index.src} link={index.link} linkTitle={index.linkTitle}  />      
        ))}
      </div>
    </div>    
  )
}

function BlurImage(index) {
  const [isLoading, setLoading] = useState(true)
  
  return (
    <a href={index.link} className="gallery-item">
      <div style={{ background: '#fff', aspectRatio: '1', overflow: 'hidden', borderRadius: 8, position: "relative" }}>
        <Image
          alt={index.alt}
          src={index.src}
          layout='responsive'
          width={100}
          height={100}
          objectFit="cover"
          className={
            isLoading
              ? 'gallery-image transitioning'
              : 'gallery-image transitioned'
          }
          onLoadingComplete={() => setLoading(false)}
        />
        <h5 style={{ position: "absolute", width: "100%", height: "100%", top: "calc(100% - .5em)", zIndex: 0 }} class="tile-title">{index.linkTitle}</h5>
      </div>
    </a>
  )
}
