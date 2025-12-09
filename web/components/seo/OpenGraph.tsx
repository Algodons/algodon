import { Metadata } from 'next';

interface OpenGraphProps {
  title: string;
  description: string;
  image?: string;
  url?: string;
  type?: 'website' | 'article';
}

export function generateOpenGraphMetadata({
  title,
  description,
  image = '/og-image.png',
  url = 'https://algodon.app',
  type = 'website',
}: OpenGraphProps): Metadata {
  return {
    openGraph: {
      title,
      description,
      images: [
        {
          url: image,
          width: 1200,
          height: 630,
          alt: title,
        },
      ],
      url,
      type,
      siteName: 'ALGODON',
    },
    twitter: {
      card: 'summary_large_image',
      title,
      description,
      images: [image],
    },
  };
}
