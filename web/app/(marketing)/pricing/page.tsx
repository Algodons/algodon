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
