import Image from 'next/image';
import { useState } from 'react';

export default function CustomImage({src, alt, width, height, layout, loader, objectFit}) {
  const [isLoading, setLoading] = useState(true)
  const aspectRatio = width / height;

  return (
    <div style={{ 
      position: 'relative',
      width: '100%',
      paddingBottom: `${(1 / aspectRatio) * 100}%`,
      overflow: 'hidden',
      borderRadius: 8
    }}>
      <Image
        src={src}
        alt={alt}
        fill
        sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
        style={{ objectFit: objectFit || 'cover' }}
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