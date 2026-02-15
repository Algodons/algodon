'use client';

import { useState } from 'react';
import { X, CreditCard, Square, DollarSign, Bitcoin, Wallet } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { StripeCheckoutForm } from '@/components/payments/StripeCheckoutForm';
import { SquarePaymentForm } from '@/components/payments/SquarePaymentForm';
import { CashAppButton } from '@/components/payments/CashAppButton';
import { CoinbaseCommerceButton } from '@/components/payments/CoinbaseCommerceButton';
import { PrivyWalletConnect } from '@/components/payments/PrivyWalletConnect';

type PaymentMethod = 'stripe' | 'square' | 'cashapp' | 'crypto' | 'web3';

interface PaymentModalProps {
  isOpen: boolean;
  onClose: () => void;
  plan: 'pro';
}

export function PaymentModal({ isOpen, onClose, plan }: PaymentModalProps) {
  const [method, setMethod] = useState<PaymentMethod>('stripe');

  if (!isOpen) return null;

  const paymentMethods = [
    { id: 'stripe' as PaymentMethod, name: 'Credit/Debit Card', icon: CreditCard, badge: 'Recommended' },
    { id: 'square' as PaymentMethod, name: 'Square', icon: Square },
    { id: 'cashapp' as PaymentMethod, name: 'Cash App', icon: DollarSign },
    { id: 'crypto' as PaymentMethod, name: 'Cryptocurrency', icon: Bitcoin },
    { id: 'web3' as PaymentMethod, name: 'Web3 Wallet', icon: Wallet },
  ];

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex min-h-screen items-center justify-center p-4">
        <div
          className="fixed inset-0 bg-black/50 transition-opacity"
          onClick={onClose}
        />
        <div className="relative bg-white dark:bg-gray-900 rounded-2xl shadow-xl max-w-3xl w-full p-8">
          <button
            onClick={onClose}
            className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
          >
            <X className="w-6 h-6" />
          </button>

          <div className="mb-6">
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
              Choose Payment Method
            </h2>
            <p className="text-gray-600 dark:text-gray-300">
              Select your preferred payment method to start your 30-day trial
            </p>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mb-6">
            {paymentMethods.map((pm) => {
              const Icon = pm.icon;
              return (
                <button
                  key={pm.id}
                  onClick={() => setMethod(pm.id)}
                  className={`p-4 rounded-lg border-2 transition ${
                    method === pm.id
                      ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20'
                      : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'
                  }`}
                >
                  <Icon className="w-6 h-6 mx-auto mb-2 text-gray-700 dark:text-gray-300" />
                  <div className="text-sm font-medium text-gray-900 dark:text-white">
                    {pm.name}
                  </div>
                  {pm.badge && (
                    <div className="text-xs text-primary-600 dark:text-primary-400 mt-1">
                      {pm.badge}
                    </div>
                  )}
                </button>
              );
            })}
          </div>

          <div className="border-t border-gray-200 dark:border-gray-700 pt-6">
            {method === 'stripe' && <StripeCheckoutForm plan={plan} onSuccess={onClose} />}
            {method === 'square' && <SquarePaymentForm plan={plan} onSuccess={onClose} />}
            {method === 'cashapp' && <CashAppButton plan={plan} onSuccess={onClose} />}
            {method === 'crypto' && <CoinbaseCommerceButton plan={plan} onSuccess={onClose} />}
            {method === 'web3' && <PrivyWalletConnect plan={plan} onSuccess={onClose} />}
          </div>
        </div>
      </div>
    </div>
  );
}
