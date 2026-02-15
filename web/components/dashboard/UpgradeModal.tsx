'use client';

import { useState } from 'react';
import { X, Check, Zap } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { PaymentModal } from '@/components/payments/PaymentModal';

interface UpgradeModalProps {
  isOpen: boolean;
  onClose: () => void;
  reason: 'limit_reached' | 'trial_expired';
}

export function UpgradeModal({ isOpen, onClose, reason }: UpgradeModalProps) {
  const [showPayment, setShowPayment] = useState(false);

  if (!isOpen) return null;

  const features = [
    'Unlimited code executions',
    'Unlimited AI assistance',
    'Priority support',
    'Advanced collaboration tools',
    'Private projects',
    'Custom domains',
    '100GB storage',
    'Git integration',
    'API access',
    'Advanced analytics',
  ];

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex min-h-screen items-center justify-center p-4">
        <div
          className="fixed inset-0 bg-black/50 transition-opacity"
          onClick={onClose}
        />
        <div className="relative bg-white dark:bg-gray-900 rounded-2xl shadow-xl max-w-2xl w-full p-8">
          <button
            onClick={onClose}
            className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
          >
            <X className="w-6 h-6" />
          </button>

          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary-100 dark:bg-primary-900/30 mb-4">
              <Zap className="w-8 h-8 text-primary-600 dark:text-primary-400" />
            </div>
            <h2 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
              {reason === 'limit_reached'
                ? "You've Used All 22 Free Requests! ðŸš€"
                : 'Your Trial Has Expired'}
            </h2>
            <p className="text-lg text-gray-600 dark:text-gray-300">
              {reason === 'limit_reached'
                ? 'Unlock unlimited coding power with ALGODON Pro'
                : 'Continue enjoying unlimited access with ALGODON Pro'}
            </p>
          </div>

          <div className="bg-gradient-to-br from-primary-50 to-secondary-50 dark:from-primary-900/20 dark:to-secondary-900/20 rounded-xl p-6 mb-6">
            <div className="text-center mb-4">
              <div className="text-4xl font-bold text-gray-900 dark:text-white mb-1">
                $19<span className="text-xl text-gray-600 dark:text-gray-400">/month</span>
              </div>
              <div className="text-sm text-gray-600 dark:text-gray-400">
                30-Day Trial â€¢ Cancel Anytime
              </div>
            </div>

            <ul className="space-y-3 mb-6">
              {features.map((feature) => (
                <li key={feature} className="flex items-start">
                  <Check className="w-5 h-5 text-primary-600 dark:text-primary-400 mr-3 flex-shrink-0 mt-0.5" />
                  <span className="text-gray-700 dark:text-gray-300">{feature}</span>
                </li>
              ))}
            </ul>

            <Button
              onClick={() => setShowPayment(true)}
              className="w-full"
              size="lg"
            >
              Start 30-Day Trial ($19/mo)
            </Button>
            <p className="text-center text-sm text-gray-500 dark:text-gray-400 mt-4">
              No long-term commitment. Cancel anytime.
            </p>
          </div>

          <div className="text-center">
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-2">
              We accept multiple payment methods:
            </p>
            <div className="flex items-center justify-center space-x-4 text-xs text-gray-500 dark:text-gray-500">
              <span>ðŸ’³ Credit/Debit</span>
              <span>ðŸ“± Square</span>
              <span>ðŸ’° Cash App</span>
              <span>â‚¿ Crypto</span>
              <span>ðŸ”· Web3</span>
            </div>
          </div>
        </div>
      </div>

      {showPayment && (
        <PaymentModal
          isOpen={showPayment}
          onClose={() => setShowPayment(false)}
          plan="pro"
        />
      )}
    </div>
  );
}
