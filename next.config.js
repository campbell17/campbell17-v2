/** @type {import('next').NextConfig} */
const nextConfig = {
  // Keep updater and download URLs used by existing Geese installations working.
  async redirects() {
    return [
      { source: '/apps/geese/appcast.xml', destination: 'https://app-geese.vercel.app/updates/appcast.xml', permanent: false },
      { source: '/apps/geese/install/Geese.dmg', destination: 'https://app-geese.vercel.app/download', permanent: false },
      { source: '/apps/geese/:archive(Geese-\\d+\\.zip)', destination: 'https://app-geese.vercel.app/updates/archives/:archive', permanent: false },
      { source: '/apps/geese/old_updates/:archive(Geese-\\d+\\.zip)', destination: 'https://app-geese.vercel.app/updates/archives/:archive', permanent: false },
    ]
  },
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'campbell17.s3.amazonaws.com',
      },
    ],
  },
  reactStrictMode: true,
  swcMinify: true,
}

module.exports = nextConfig
