# ALGODON Part 2: SEO Marketing Site
# This script creates the complete SEO-optimized marketing pages, components, and blog system

Write-Host "🚀 ALGODON Part 2: SEO Marketing Site" -ForegroundColor Cyan

Set-Location "ALGODON"

# Generate global styles
$globalStyles = @'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --font-inter: 'Inter', system-ui, sans-serif;
  --font-mono: 'Fira Code', 'Courier New', monospace;
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
    font-feature-settings: "rlig" 1, "calt" 1;
  }
}

@layer utilities {
  .text-balance {
    text-wrap: balance;
  }
}

/* Custom scrollbar */
::-webkit-scrollbar {
  width: 10px;
  height: 10px;
}

::-webkit-scrollbar-track {
  @apply bg-gray-100 dark:bg-gray-900;
}

::-webkit-scrollbar-thumb {
  @apply bg-gray-400 dark:bg-gray-600 rounded-full;
}

::-webkit-scrollbar-thumb:hover {
  @apply bg-gray-500 dark:bg-gray-500;
}
'@

$globalStyles | Out-File -FilePath "web/styles/globals.css" -Encoding UTF8
Write-Host "✅ Created global styles" -ForegroundColor Green

# Generate root layout
$rootLayout = @'
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { ClerkProvider } from '@clerk/nextjs';
import { ThemeProvider } from '@/components/ui/theme-provider';
import './styles/globals.css';

const inter = Inter({ 
  subsets: ['latin'],
  variable: '--font-inter',
  display: 'swap',
});

export const metadata: Metadata = {
  metadataBase: new URL(process.env.NEXT_PUBLIC_APP_URL || 'https://algodon.app'),
  title: {
    default: 'ALGODON - AI-Powered Online Code Editor | Code Anywhere',
    template: '%s | ALGODON',
  },
  description: 'Build, run, and deploy code in 50+ languages with AI assistance. Real-time collaboration, instant execution, and zero setup required. Start free today.',
  keywords: ['online code editor', 'AI coding assistant', 'collaborative IDE', 'code sandbox', 'Replit alternative', 'cloud IDE', 'programming environment'],
  authors: [{ name: 'ALGODON Team', url: 'https://algodon.app' }],
  creator: 'ALGODON',
  publisher: 'ALGODON',
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://algodon.app',
    siteName: 'ALGODON',
    title: 'ALGODON - Code Smarter with AI',
    description: 'The fastest way to code, collaborate, and deploy. Try ALGODON free.',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'ALGODON - AI-Powered Code Editor',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'ALGODON - AI Code Editor',
    description: 'Code in 50+ languages with AI help. Free forever.',
    images: ['/twitter-card.png'],
    creator: '@algodon',
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  verification: {
    google: 'your-google-verification-code',
    yandex: 'your-yandex-verification-code',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <ClerkProvider>
      <html lang="en" suppressHydrationWarning>
        <head>
          <link rel="icon" href="/favicon.ico" />
          <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
          <link rel="manifest" href="/manifest.json" />
        </head>
        <body className={`${inter.variable} font-sans antialiased`}>
          <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
            {children}
          </ThemeProvider>
        </body>
      </html>
    </ClerkProvider>
  );
}
'@

$rootLayout | Out-File -FilePath "web/app/layout.tsx" -Encoding UTF8
Write-Host "✅ Created root layout" -ForegroundColor Green

# Generate homepage
$homepage = @'
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
'@

$homepage | Out-File -FilePath "web/app/(marketing)/page.tsx" -Encoding UTF8
Write-Host "✅ Created homepage" -ForegroundColor Green

# Generate marketing layout
$marketingLayout = @'
export default function MarketingLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <>{children}</>;
}
'@

$marketingLayout | Out-File -FilePath "web/app/(marketing)/layout.tsx" -Encoding UTF8
Write-Host "✅ Created marketing layout" -ForegroundColor Green

# Generate SEO components
$structuredDataComponent = @'
import Script from 'next/script';

interface StructuredDataProps {
  data: Record<string, any>;
}

export function StructuredData({ data }: StructuredDataProps) {
  return (
    <Script
      id="structured-data"
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}
'@

$structuredDataComponent | Out-File -FilePath "web/components/seo/StructuredData.tsx" -Encoding UTF8

$openGraphComponent = @'
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
'@

$openGraphComponent | Out-File -FilePath "web/components/seo/OpenGraph.tsx" -Encoding UTF8
Write-Host "✅ Created SEO components" -ForegroundColor Green

# Generate marketing components
$navbarComponent = @'
'use client';

import Link from 'next/link';
import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Menu, X } from 'lucide-react';
import { useUser, SignInButton, SignUpButton } from '@clerk/nextjs';

export function Navbar() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const { isSignedIn, user } = useUser();

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-white/80 dark:bg-gray-900/80 backdrop-blur-md border-b border-gray-200 dark:border-gray-800">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center">
            <Link href="/" className="flex items-center space-x-2">
              <div className="w-8 h-8 bg-gradient-to-br from-primary-500 to-secondary-500 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-lg">A</span>
              </div>
              <span className="text-xl font-bold bg-gradient-to-r from-primary-600 to-secondary-600 bg-clip-text text-transparent">
                ALGODON
              </span>
            </Link>
          </div>

          <div className="hidden md:flex items-center space-x-8">
            <Link href="/features" className="text-gray-700 dark:text-gray-300 hover:text-primary-600 transition">
              Features
            </Link>
            <Link href="/pricing" className="text-gray-700 dark:text-gray-300 hover:text-primary-600 transition">
              Pricing
            </Link>
            <Link href="/blog" className="text-gray-700 dark:text-gray-300 hover:text-primary-600 transition">
              Blog
            </Link>
            <Link href="/docs" className="text-gray-700 dark:text-gray-300 hover:text-primary-600 transition">
              Docs
            </Link>
          </div>

          <div className="hidden md:flex items-center space-x-4">
            {isSignedIn ? (
              <>
                <Link href="/dashboard">
                  <Button variant="ghost">Dashboard</Button>
                </Link>
                <Link href="/dashboard/projects">
                  <Button>Start Coding</Button>
                </Link>
              </>
            ) : (
              <>
                <SignInButton mode="modal">
                  <Button variant="ghost">Sign In</Button>
                </SignInButton>
                <SignUpButton mode="modal">
                  <Button>Get Started</Button>
                </SignUpButton>
              </>
            )}
          </div>

          <button
            className="md:hidden p-2"
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            aria-label="Toggle menu"
          >
            {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>

        {mobileMenuOpen && (
          <div className="md:hidden py-4 space-y-4 border-t border-gray-200 dark:border-gray-800">
            <Link href="/features" className="block text-gray-700 dark:text-gray-300">
              Features
            </Link>
            <Link href="/pricing" className="block text-gray-700 dark:text-gray-300">
              Pricing
            </Link>
            <Link href="/blog" className="block text-gray-700 dark:text-gray-300">
              Blog
            </Link>
            <Link href="/docs" className="block text-gray-700 dark:text-gray-300">
              Docs
            </Link>
            <div className="pt-4 space-y-2">
              {isSignedIn ? (
                <>
                  <Link href="/dashboard">
                    <Button variant="ghost" className="w-full">Dashboard</Button>
                  </Link>
                  <Link href="/dashboard/projects">
                    <Button className="w-full">Start Coding</Button>
                  </Link>
                </>
              ) : (
                <>
                  <SignInButton mode="modal">
                    <Button variant="ghost" className="w-full">Sign In</Button>
                  </SignInButton>
                  <SignUpButton mode="modal">
                    <Button className="w-full">Get Started</Button>
                  </SignUpButton>
                </>
              )}
            </div>
          </div>
        )}
      </div>
    </nav>
  );
}
'@

$navbarComponent | Out-File -FilePath "web/components/marketing/Navbar.tsx" -Encoding UTF8

$heroSection = @'
'use client';

import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { ArrowRight, Play } from 'lucide-react';
import { SignUpButton } from '@clerk/nextjs';
import { motion } from 'framer-motion';

export function HeroSection() {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden pt-16">
      <div className="absolute inset-0 bg-gradient-to-br from-primary-50 via-white to-secondary-50 dark:from-gray-900 dark:via-gray-900 dark:to-gray-800" />
      <div className="absolute inset-0 bg-[url('/grid.svg')] bg-center [mask-image:linear-gradient(180deg,white,rgba(255,255,255,0))]" />
      
      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="text-center"
        >
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="inline-flex items-center px-4 py-2 rounded-full bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300 text-sm font-medium mb-8"
          >
            <span className="w-2 h-2 bg-primary-500 rounded-full mr-2 animate-pulse" />
            New: AI Code Completion with GPT-4
          </motion.div>

          <h1 className="text-5xl md:text-6xl lg:text-7xl font-bold tracking-tight mb-6">
            <span className="bg-gradient-to-r from-primary-600 via-secondary-600 to-primary-600 bg-clip-text text-transparent bg-[length:200%_auto] animate-gradient">
              Code Smarter,
            </span>
            <br />
            <span className="text-gray-900 dark:text-white">Build Faster</span>
          </h1>

          <p className="text-xl md:text-2xl text-gray-600 dark:text-gray-300 mb-8 max-w-3xl mx-auto">
            The AI-powered online code editor with real-time collaboration.
            <br />
            <span className="text-gray-500 dark:text-gray-400">
              Start coding in seconds. No setup required.
            </span>
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-12">
            <SignUpButton mode="modal">
              <Button size="lg" className="text-lg px-8 py-6">
                Start Coding in Seconds
                <ArrowRight className="ml-2 w-5 h-5" />
              </Button>
            </SignUpButton>
            <Button size="lg" variant="outline" className="text-lg px-8 py-6">
              <Play className="mr-2 w-5 h-5" />
              Watch Demo
            </Button>
          </div>

          <div className="flex items-center justify-center gap-8 text-sm text-gray-500 dark:text-gray-400">
            <div className="flex items-center gap-2">
              <div className="w-5 h-5 rounded-full bg-green-500 flex items-center justify-center">
                <span className="text-white text-xs">✓</span>
              </div>
              <span>Free Forever</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-5 h-5 rounded-full bg-green-500 flex items-center justify-center">
                <span className="text-white text-xs">✓</span>
              </div>
              <span>No Credit Card</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-5 h-5 rounded-full bg-green-500 flex items-center justify-center">
                <span className="text-white text-xs">✓</span>
              </div>
              <span>22 Free Requests</span>
            </div>
          </div>
        </motion.div>
      </div>

      <div className="absolute bottom-0 left-0 right-0 h-24 bg-gradient-to-t from-white dark:from-gray-900 to-transparent" />
    </section>
  );
}
'@

$heroSection | Out-File -FilePath "web/components/marketing/HeroSection.tsx" -Encoding UTF8

$featuresGrid = @'
'use client';

import { Code, Zap, Users, Globe, Shield, GitBranch } from 'lucide-react';
import { motion } from 'framer-motion';

const features = [
  {
    icon: Code,
    title: '50+ Languages',
    description: 'Full support for Python, JavaScript, TypeScript, Go, Rust, Java, C++, and more with syntax highlighting and IntelliSense.',
  },
  {
    icon: Zap,
    title: 'AI-Powered',
    description: 'Get intelligent code completion, explanations, and suggestions powered by GPT-4, Claude, and Gemini.',
  },
  {
    icon: Users,
    title: 'Real-time Collaboration',
    description: 'Code together with your team in real-time. See cursors, selections, and changes as they happen.',
  },
  {
    icon: Globe,
    title: 'Run Anywhere',
    description: 'Access your projects from web, mobile, or desktop. Your code syncs across all devices.',
  },
  {
    icon: Shield,
    title: 'Secure & Private',
    description: 'Enterprise-grade security with encrypted storage, private projects, and role-based access control.',
  },
  {
    icon: GitBranch,
    title: 'Git Integration',
    description: 'Connect to GitHub, GitLab, or Bitbucket. Commit, push, and pull without leaving the editor.',
  },
];

export function FeaturesGrid() {
  return (
    <section className="py-24 bg-white dark:bg-gray-900">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
            Everything You Need to Code
          </h2>
          <p className="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
            Powerful features designed for modern developers
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => {
            const Icon = feature.icon;
            return (
              <motion.div
                key={feature.title}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="p-6 rounded-xl border border-gray-200 dark:border-gray-800 bg-gray-50 dark:bg-gray-800/50 hover:border-primary-300 dark:hover:border-primary-700 transition"
              >
                <div className="w-12 h-12 rounded-lg bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center mb-4">
                  <Icon className="w-6 h-6 text-primary-600 dark:text-primary-400" />
                </div>
                <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                  {feature.title}
                </h3>
                <p className="text-gray-600 dark:text-gray-300">
                  {feature.description}
                </p>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
'@

$featuresGrid | Out-File -FilePath "web/components/marketing/FeaturesGrid.tsx" -Encoding UTF8

$socialProof = @'
'use client';

import { motion } from 'framer-motion';

const stats = [
  { value: '100,000+', label: 'Active Developers' },
  { value: '1M+', label: 'Projects Created' },
  { value: '50+', label: 'Languages Supported' },
  { value: '99.9%', label: 'Uptime' },
];

const logos = [
  'TechCorp', 'StartupXYZ', 'DevStudio', 'CodeLab', 'BuildCo',
];

export function SocialProof() {
  return (
    <section className="py-16 bg-gray-50 dark:bg-gray-800/50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <p className="text-sm font-semibold text-primary-600 dark:text-primary-400 uppercase tracking-wide mb-2">
            Trusted by Developers Worldwide
          </p>
          <h2 className="text-3xl font-bold text-gray-900 dark:text-white">
            Join 100,000+ developers building with ALGODON
          </h2>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-8 mb-16">
          {stats.map((stat, index) => (
            <motion.div
              key={stat.label}
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              className="text-center"
            >
              <div className="text-4xl md:text-5xl font-bold text-primary-600 dark:text-primary-400 mb-2">
                {stat.value}
              </div>
              <div className="text-gray-600 dark:text-gray-300">{stat.label}</div>
            </motion.div>
          ))}
        </div>

        <div className="flex flex-wrap items-center justify-center gap-8 opacity-60">
          {logos.map((logo) => (
            <div
              key={logo}
              className="text-2xl font-bold text-gray-400 dark:text-gray-600"
            >
              {logo}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
'@

$socialProof | Out-File -FilePath "web/components/marketing/SocialProof.tsx" -Encoding UTF8

$demoVideo = @'
'use client';

import { Play } from 'lucide-react';
import { useState } from 'react';

export function DemoVideo() {
  const [playing, setPlaying] = useState(false);

  return (
    <section className="py-24 bg-white dark:bg-gray-900">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
            See ALGODON in Action
          </h2>
          <p className="text-xl text-gray-600 dark:text-gray-300">
            Watch how easy it is to code, collaborate, and deploy
          </p>
        </div>

        <div className="relative aspect-video rounded-2xl overflow-hidden shadow-2xl bg-gray-900">
          {!playing ? (
            <div className="absolute inset-0 flex items-center justify-center">
              <button
                onClick={() => setPlaying(true)}
                className="w-20 h-20 rounded-full bg-primary-600 hover:bg-primary-700 flex items-center justify-center transition"
                aria-label="Play video"
              >
                <Play className="w-10 h-10 text-white ml-1" fill="white" />
              </button>
            </div>
          ) : (
            <iframe
              className="w-full h-full"
              src="https://www.youtube.com/embed/dQw4w9WgXcQ?autoplay=1"
              title="ALGODON Demo"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
            />
          )}
        </div>
      </div>
    </section>
  );
}
'@

$demoVideo | Out-File -FilePath "web/components/marketing/DemoVideo.tsx" -Encoding UTF8

$ctaSection = @'
'use client';

import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { ArrowRight } from 'lucide-react';
import { SignUpButton } from '@clerk/nextjs';

export function CTASection() {
  return (
    <section className="py-24 bg-gradient-to-br from-primary-600 to-secondary-600">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h2 className="text-4xl md:text-5xl font-bold text-white mb-6">
          Ready to Start Coding?
        </h2>
        <p className="text-xl text-primary-100 mb-8">
          Join thousands of developers building amazing things with ALGODON.
          <br />
          Get started in seconds. No credit card required.
        </p>
        <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
          <SignUpButton mode="modal">
            <Button size="lg" variant="secondary" className="text-lg px-8 py-6">
              Start Coding Free
              <ArrowRight className="ml-2 w-5 h-5" />
            </Button>
          </SignUpButton>
          <Link href="/pricing">
            <Button size="lg" variant="outline" className="text-lg px-8 py-6 bg-white/10 border-white/20 text-white hover:bg-white/20">
              View Pricing
            </Button>
          </Link>
        </div>
        <p className="text-sm text-primary-100 mt-4">
          22 free requests • No credit card • Cancel anytime
        </p>
      </div>
    </section>
  );
}
'@

$ctaSection | Out-File -FilePath "web/components/marketing/CTASection.tsx" -Encoding UTF8

$footer = @'
import Link from 'next/link';

const footerLinks = {
  Product: [
    { name: 'Features', href: '/features' },
    { name: 'Pricing', href: '/pricing' },
    { name: 'Documentation', href: '/docs' },
    { name: 'Changelog', href: '/changelog' },
  ],
  Company: [
    { name: 'About', href: '/about' },
    { name: 'Blog', href: '/blog' },
    { name: 'Careers', href: '/careers' },
    { name: 'Contact', href: '/contact' },
  ],
  Legal: [
    { name: 'Privacy Policy', href: '/privacy' },
    { name: 'Terms of Service', href: '/terms' },
    { name: 'Cookie Policy', href: '/cookies' },
    { name: 'Security', href: '/security' },
  ],
  Social: [
    { name: 'Twitter', href: 'https://twitter.com/algodon' },
    { name: 'GitHub', href: 'https://github.com/algodon' },
    { name: 'Discord', href: 'https://discord.gg/algodon' },
    { name: 'LinkedIn', href: 'https://linkedin.com/company/algodon' },
  ],
};

export function Footer() {
  return (
    <footer className="bg-gray-900 text-gray-300">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8 mb-8">
          {Object.entries(footerLinks).map(([category, links]) => (
            <div key={category}>
              <h3 className="text-white font-semibold mb-4">{category}</h3>
              <ul className="space-y-2">
                {links.map((link) => (
                  <li key={link.name}>
                    <Link
                      href={link.href}
                      className="hover:text-white transition"
                    >
                      {link.name}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="border-t border-gray-800 pt-8 flex flex-col md:flex-row justify-between items-center">
          <div className="flex items-center space-x-2 mb-4 md:mb-0">
            <div className="w-8 h-8 bg-gradient-to-br from-primary-500 to-secondary-500 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold">A</span>
            </div>
            <span className="text-white font-bold text-lg">ALGODON</span>
          </div>
          <p className="text-sm text-gray-400">
            © {new Date().getFullYear()} ALGODON. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  );
}
'@

$footer | Out-File -FilePath "web/components/marketing/Footer.tsx" -Encoding UTF8
Write-Host "✅ Created marketing components" -ForegroundColor Green

# Generate pricing page
$pricingPage = @'
import { Metadata } from 'next';
import { PricingSection } from '@/components/marketing/PricingSection';
import { Navbar } from '@/components/marketing/Navbar';
import { Footer } from '@/components/marketing/Footer';
import { FAQ } from '@/components/marketing/FAQ';

export const metadata: Metadata = {
  title: 'Pricing - ALGODON',
  description: 'Choose the perfect plan for your coding needs. Free forever plan with 22 requests, or upgrade to Pro for unlimited access.',
  openGraph: {
    title: 'Pricing - ALGODON',
    description: 'Choose the perfect plan for your coding needs.',
  },
};

export default function PricingPage() {
  return (
    <>
      <Navbar />
      <main className="pt-16">
        <PricingSection />
        <FAQ />
      </main>
      <Footer />
    </>
  );
}
'@

$pricingPage | Out-File -FilePath "web/app/(marketing)/pricing/page.tsx" -Encoding UTF8

$pricingSection = @'
'use client';

import { Button } from '@/components/ui/button';
import { Check } from 'lucide-react';
import { SignUpButton } from '@clerk/nextjs';
import Link from 'next/link';

const plans = [
  {
    name: 'Free',
    price: '$0',
    period: 'forever',
    description: 'Perfect for trying out ALGODON',
    features: [
      '22 free requests',
      '50+ programming languages',
      'Basic AI assistance',
      'Public projects only',
      'Community support',
      '5GB storage',
    ],
    cta: 'Get Started Free',
    popular: false,
  },
  {
    name: 'Pro',
    price: '$19',
    period: 'per month',
    description: 'For professional developers and teams',
    features: [
      'Unlimited requests',
      'Unlimited AI assistance',
      'Private projects',
      'Real-time collaboration',
      'Priority support',
      '100GB storage',
      'Custom domains',
      'Advanced analytics',
      'Git integration',
      'API access',
    ],
    cta: 'Start 30-Day Trial',
    popular: true,
  },
];

export function PricingSection() {
  return (
    <section className="py-24 bg-white dark:bg-gray-900">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h1 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
            Simple, Transparent Pricing
          </h1>
          <p className="text-xl text-gray-600 dark:text-gray-300">
            Choose the plan that works best for you. Upgrade or downgrade anytime.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-5xl mx-auto">
          {plans.map((plan) => (
            <div
              key={plan.name}
              className={`relative rounded-2xl border-2 p-8 ${
                plan.popular
                  ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/10'
                  : 'border-gray-200 dark:border-gray-800'
              }`}
            >
              {plan.popular && (
                <div className="absolute -top-4 left-1/2 -translate-x-1/2">
                  <span className="bg-primary-500 text-white px-4 py-1 rounded-full text-sm font-semibold">
                    Most Popular
                  </span>
                </div>
              )}

              <div className="mb-6">
                <h3 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
                  {plan.name}
                </h3>
                <div className="flex items-baseline mb-2">
                  <span className="text-5xl font-bold text-gray-900 dark:text-white">
                    {plan.price}
                  </span>
                  {plan.period !== 'forever' && (
                    <span className="text-gray-600 dark:text-gray-400 ml-2">
                      /{plan.period}
                    </span>
                  )}
                </div>
                <p className="text-gray-600 dark:text-gray-300">{plan.description}</p>
              </div>

              <ul className="space-y-4 mb-8">
                {plan.features.map((feature) => (
                  <li key={feature} className="flex items-start">
                    <Check className="w-5 h-5 text-primary-600 dark:text-primary-400 mr-3 flex-shrink-0 mt-0.5" />
                    <span className="text-gray-700 dark:text-gray-300">{feature}</span>
                  </li>
                ))}
              </ul>

              {plan.name === 'Free' ? (
                <SignUpButton mode="modal">
                  <Button
                    variant={plan.popular ? 'default' : 'outline'}
                    className="w-full"
                    size="lg"
                  >
                    {plan.cta}
                  </Button>
                </SignUpButton>
              ) : (
                <Link href="/dashboard/billing?plan=pro">
                  <Button
                    variant={plan.popular ? 'default' : 'outline'}
                    className="w-full"
                    size="lg"
                  >
                    {plan.cta}
                  </Button>
                </Link>
              )}
            </div>
          ))}
        </div>

        <div className="text-center mt-12">
          <p className="text-gray-600 dark:text-gray-300 mb-4">
            All plans include our core features. Need something custom?
          </p>
          <Link href="/contact">
            <Button variant="link">Contact Sales</Button>
          </Link>
        </div>
      </div>
    </section>
  );
}
'@

$pricingSection | Out-File -FilePath "web/components/marketing/PricingSection.tsx" -Encoding UTF8

$faq = @'
'use client';

import { useState } from 'react';
import { ChevronDown } from 'lucide-react';

const faqs = [
  {
    question: 'What is included in the free plan?',
    answer: 'The free plan includes 22 free requests (code executions or AI completions), access to all 50+ programming languages, basic AI assistance, public projects, and 5GB of storage. Perfect for trying out ALGODON!',
  },
  {
    question: 'What happens when I use all 22 free requests?',
    answer: 'When you reach your limit, you\'ll see an upgrade prompt. You can start a 30-day trial of Pro for $19/month, which includes unlimited requests. You can cancel anytime during the trial.',
  },
  {
    question: 'Can I upgrade or downgrade my plan?',
    answer: 'Yes! You can upgrade or downgrade your plan at any time from your billing settings. Changes take effect immediately, and we\'ll prorate any charges.',
  },
  {
    question: 'What payment methods do you accept?',
    answer: 'We accept credit/debit cards via Stripe, Square, Cash App Pay, cryptocurrency (Bitcoin, Ethereum, USDC), and Web3 wallets (MetaMask, WalletConnect).',
  },
  {
    question: 'Is my code private and secure?',
    answer: 'Absolutely! All code is encrypted at rest and in transit. Pro users can create private projects that are only accessible to them and invited collaborators. We use enterprise-grade security practices.',
  },
  {
    question: 'Do you offer refunds?',
    answer: 'Yes, we offer a 30-day money-back guarantee for Pro subscriptions. If you\'re not satisfied, contact us within 30 days for a full refund.',
  },
];

export function FAQ() {
  const [openIndex, setOpenIndex] = useState<number | null>(null);

  return (
    <section className="py-24 bg-gray-50 dark:bg-gray-800/50">
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <h2 className="text-4xl font-bold text-gray-900 dark:text-white mb-4">
            Frequently Asked Questions
          </h2>
        </div>

        <div className="space-y-4">
          {faqs.map((faq, index) => (
            <div
              key={index}
              className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 overflow-hidden"
            >
              <button
                onClick={() => setOpenIndex(openIndex === index ? null : index)}
                className="w-full px-6 py-4 flex items-center justify-between text-left hover:bg-gray-50 dark:hover:bg-gray-800 transition"
              >
                <span className="font-semibold text-gray-900 dark:text-white">
                  {faq.question}
                </span>
                <ChevronDown
                  className={`w-5 h-5 text-gray-500 transition-transform ${
                    openIndex === index ? 'transform rotate-180' : ''
                  }`}
                />
              </button>
              {openIndex === index && (
                <div className="px-6 pb-4 text-gray-600 dark:text-gray-300">
                  {faq.answer}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
'@

$faq | Out-File -FilePath "web/components/marketing/FAQ.tsx" -Encoding UTF8
Write-Host "✅ Created pricing page and FAQ" -ForegroundColor Green

# Generate sitemap
$sitemap = @'
import { MetadataRoute } from 'next';

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = 'https://algodon.app';

  return [
    {
      url: baseUrl,
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 1,
    },
    {
      url: `${baseUrl}/features`,
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 0.8,
    },
    {
      url: `${baseUrl}/pricing`,
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 0.9,
    },
    {
      url: `${baseUrl}/blog`,
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 0.7,
    },
    {
      url: `${baseUrl}/docs`,
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 0.6,
    },
  ];
}
'@

$sitemap | Out-File -FilePath "web/app/sitemap.ts" -Encoding UTF8

# Generate robots.txt
$robots = @'
User-agent: *
Allow: /
Disallow: /api/
Disallow: /dashboard/
Disallow: /admin/

Sitemap: https://algodon.app/sitemap.xml
'@

$robots | Out-File -FilePath "web/app/robots.ts" -Encoding UTF8
Write-Host "✅ Created sitemap and robots.txt" -ForegroundColor Green

# Generate UI components
$buttonComponent = @'
import * as React from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-primary-600 text-white hover:bg-primary-700',
        destructive: 'bg-red-600 text-white hover:bg-red-700',
        outline: 'border border-gray-300 bg-transparent hover:bg-gray-100 dark:border-gray-700 dark:hover:bg-gray-800',
        secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200 dark:bg-gray-800 dark:text-gray-100 dark:hover:bg-gray-700',
        ghost: 'hover:bg-gray-100 dark:hover:bg-gray-800',
        link: 'text-primary-600 underline-offset-4 hover:underline',
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm: 'h-9 rounded-md px-3',
        lg: 'h-11 rounded-md px-8',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, ...props }, ref) => {
    return (
      <button
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    );
  }
);
Button.displayName = 'Button';

export { Button, buttonVariants };
'@

$buttonComponent | Out-File -FilePath "web/components/ui/button.tsx" -Encoding UTF8

# Generate utility functions
$utils = @'
import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatDate(date: Date | string): string {
  return new Intl.DateTimeFormat('en-US', {
    month: 'long',
    day: 'numeric',
    year: 'numeric',
  }).format(new Date(date));
}

export function formatCurrency(amount: number, currency = 'USD'): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
  }).format(amount);
}
'@

$utils | Out-File -FilePath "web/lib/utils.ts" -Encoding UTF8

# Generate theme provider
$themeProvider = @'
'use client';

import * as React from 'react';
import { ThemeProvider as NextThemesProvider } from 'next-themes';
import { type ThemeProviderProps } from 'next-themes/dist/types';

export function ThemeProvider({ children, ...props }: ThemeProviderProps) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>;
}
'@

$themeProvider | Out-File -FilePath "web/components/ui/theme-provider.tsx" -Encoding UTF8
Write-Host "✅ Created UI components and utilities" -ForegroundColor Green

Write-Host "`n✅ Part 2: SEO Marketing Site Complete!" -ForegroundColor Green
Write-Host "Next: Run .\part3-user-panel.ps1" -ForegroundColor Yellow

