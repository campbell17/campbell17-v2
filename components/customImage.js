import Image from 'next/image';
import { useState } from 'react';

export default function CustomImage({src, alt, width, height, layout, loader, objectFit}) {
  const [isLoading, setLoading] = useState(true)

  return (
    <div style={{ overflow: 'hidden', borderRadius: 8, position: "relative" }}>
      <Image
        src={src}
        alt={alt}
        width={width}
        height={height}
        layout={layout}
        loader={loader}      
        objectFit={objectFit}
        className={
          isLoading
            ? 'gallery-image transitioning'
            : 'gallery-image transitioned'
        }
        onLoadingComplete={() => setLoading(false)}    
      />
    </div>
  )
}