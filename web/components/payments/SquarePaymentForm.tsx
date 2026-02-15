'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';

interface SquarePaymentFormProps {
  plan: 'pro';
  onSuccess: () => void;
}

export function SquarePaymentForm({ plan, onSuccess }: SquarePaymentFormProps) {
  const [loading, setLoading] = useState(false);

  const handlePayment = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/payments/square/create-subscription', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ plan }),
      });

      const data = await response.json();
      
      if (data.error) {
        alert(data.error);
        return;
      }

      // Square Web Payments SDK would be initialized here
      // For now, redirect to Square payment page
      if (data.paymentUrl) {
        window.location.href = data.paymentUrl;
      }
    } catch (error) {
      console.error('Square payment error:', error);
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
          'Pay with Square'
        )}
      </Button>
      <p className="text-xs text-gray-500 dark:text-gray-400 mt-2 text-center">
        Secure payment powered by Square
      </p>
    </div>
  );
}
