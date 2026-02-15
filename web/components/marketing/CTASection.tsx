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
          22 free requests â€¢ No credit card â€¢ Cancel anytime
        </p>
      </div>
    </section>
  );
}
