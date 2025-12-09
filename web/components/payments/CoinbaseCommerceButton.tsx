'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';

interface CoinbaseCommerceButtonProps {
  plan: 'pro';
  onSuccess: () => void;
}

export function CoinbaseCommerceButton({ plan, onSuccess }: CoinbaseCommerceButtonProps) {
  const [loading, setLoading] = useState(false);

  const handlePayment = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/payments/crypto/create-charge', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ plan }),
      });

      const data = await response.json();
      
      if (data.error) {
        alert(data.error);
        return;
      }

      if (data.hosted_url) {
        window.location.href = data.hosted_url;
      }
    } catch (error) {
      console.error('Crypto payment error:', error);
      alert('Failed to process payment. Please try again.');
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
        <div className="text-xs text-gray-500 dark:text-gray-400 mt-2">
          Accepts: BTC, ETH, USDC, USDT, DOGE
        </div>
      </div>
      <Button
        onClick={handlePayment}
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
          'Pay with Cryptocurrency'
        )}
      </Button>
      <p className="text-xs text-gray-500 dark:text-gray-400 mt-2 text-center">
        Secure payment powered by Coinbase Commerce
      </p>
    </div>
  );
}
