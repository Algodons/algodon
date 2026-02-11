import { Metadata } from 'next';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { StructuredData } from '@/components/seo/StructuredData';
import { HeroSection } from '@/components/marketing/HeroSection';
import { FeaturesGrid } from '@/components/marketing/FeaturesGrid';
import { SocialProof } from '@/components/marketing/SocialProof';
import { DemoVideo } from '@/components/marketing/DemoVideo';
import { CTASection } from '@/components/marketing/CTASection';
import { Footer } from '@/components/marketing/Footer';
import { Navbar } from '@/components/marketing/Navbar';

export const metadata: Metadata = {
  title: 'ALGODON - AI-Powered Online Code Editor | Code Anywhere',
  description: 'Build, run, and deploy code in 50+ languages with AI assistance. Real-time collaboration, instant execution, and zero setup required. Start free today.',
  keywords: ['online code editor', 'AI coding assistant', 'collaborative IDE', 'code sandbox', 'Replit alternative'],
  openGraph: {
    title: 'ALGODON - Code Smarter with AI',
    description: 'The fastest way to code, collaborate, and deploy. Try ALGODON free.',
    images: ['/og-image.png'],
    url: 'https://algodon.app',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'ALGODON - AI Code Editor',
    description: 'Code in 50+ languages with AI help. Free forever.',
    images: ['/twitter-card.png'],
  },
  robots: 'index, follow',
  alternates: {
    canonical: 'https://algodon.app',
  },
};

export default function HomePage() {
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    "name": "ALGODON",
    "applicationCategory": "DeveloperApplication",
    "operatingSystem": "Web, iOS, Android, Windows, macOS, Linux",
    "offers": {
      "@type": "Offer",
      "price": "0",
      "priceCurrency": "USD",
      "availability": "https://schema.org/InStock",
    },
    "aggregateRating": {
      "@type": "AggregateRating",
      "ratingValue": "4.8",
      "ratingCount": "5420",
      "bestRating": "5",
      "worstRating": "1",
    },
    "featureList": [
      "AI-Powered Code Completion",
      "Real-time Collaboration",
      "50+ Programming Languages",
      "Instant Code Execution",
      "Git Integration",
      "Cloud Storage",
    ],
  };

  return (
    <>
      <StructuredData data={structuredData} />
      <Navbar />
      <main>
        <HeroSection />
        <SocialProof />
        <FeaturesGrid />
        <DemoVideo />
        <CTASection />
      </main>
      <Footer />
    </>
  );
}
