'use client';

import { useState } from 'react';
import { loadStripe } from '@stripe/stripe-js';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!);

interface StripeCheckoutFormProps {
  plan: 'pro';
  onSuccess: () => void;
}

export function StripeCheckoutForm({ plan, onSuccess }: StripeCheckoutFormProps) {
  const [loading, setLoading] = useState(false);

  const handleCheckout = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/payments/stripe/create-subscription', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ plan }),
      });

      const { url } = await response.json();
      
      if (url) {
        const stripe = await stripePromise;
        if (stripe) {
          await stripe.redirectToCheckout({ url });
        }
      }
    } catch (error) {
      console.error('Checkout error:', error);
      alert('Failed to start checkout. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div className="mb-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
        <div className="flex items-center justify-between mb-2">
          <span className="text-gray-600 dark:text-gray-300">Plan</span>
          <span className="font-semibold text-gray-900 dark:text-white">Pro - $19/month</span>
        </div>
        <div className="flex items-center justify-between">
          <span className="text-gray-600 dark:text-gray-300">Trial</span>
          <span className="text-sm text-gray-900 dark:text-white">30 days free</span>
        </div>
      </div>
      <Button
        onClick={handleCheckout}
        disabled={loading}
        className="w-full"
        size="lg"
      >
        {loading ? (
          <>
            <Loader2 className="mr-2 w-4 h-4 animate-spin" />
            Processing...
          </>
        ) : (
          'Continue to Checkout'
        )}
      </Button>
      <p className="text-xs text-gray-500 dark:text-gray-400 mt-2 text-center">
        Secure payment powered by Stripe
      </p>
    </div>
  );
}
