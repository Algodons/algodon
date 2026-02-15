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
