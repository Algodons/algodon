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
