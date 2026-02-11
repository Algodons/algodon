'use client';

import { useEffect, useState } from 'react';
import { useUser } from '@clerk/nextjs';
import { Button } from '@/components/ui/button';
import { PaymentModal } from '@/components/payments/PaymentModal';
import { formatDate, formatCurrency } from '@/lib/utils';
import { Download } from 'lucide-react';

interface Subscription {
  tier: string;
  status: string;
  subscriptionStartDate: string | null;
  subscriptionEndDate: string | null;
  paymentMethod: string | null;
  autoRenew: boolean;
}

interface Invoice {
  id: string;
  amount: number;
  currency: string;
  status: string;
  createdAt: string;
  provider: string;
}

export default function BillingPage() {
  const { user } = useUser();
  const [subscription, setSubscription] = useState<Subscription | null>(null);
  const [invoices, setInvoices] = useState<Invoice[]>([]);
  const [showPayment, setShowPayment] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [subRes, invRes] = await Promise.all([
          fetch('/api/subscription'),
          fetch('/api/billing/invoices'),
        ]);

        if (subRes.ok) {
          const subData = await subRes.json();
          setSubscription(subData);
        }

        if (invRes.ok) {
          const invData = await invRes.json();
          setInvoices(invData);
        }
      } catch (error) {
        console.error('Failed to fetch billing data:', error);
      } finally {
        setLoading(false);
      }
    };

    if (user) {
      fetchData();
    }
  }, [user]);

  const handleCancel = async () => {
    if (!confirm('Are you sure you want to cancel your subscription?')) {
      return;
    }

    try {
      const response = await fetch('/api/billing/cancel', {
        method: 'POST',
      });

      if (response.ok) {
        alert('Subscription cancelled. You can continue using Pro until the end of your billing period.');
        window.location.reload();
      }
    } catch (error) {
      alert('Failed to cancel subscription. Please try again.');
    }
  };

  if (loading) {
    return <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">Loading...</div>;
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
          Billing & Subscription
        </h1>
        <p className="text-gray-600 dark:text-gray-300">
          Manage your subscription and payment methods
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
            Current Plan
          </h2>
          {subscription && (
            <div>
              <div className="mb-4">
                <div className="text-3xl font-bold text-gray-900 dark:text-white mb-1">
                  {subscription.tier === 'pro' ? 'Pro' : subscription.tier === 'trial' ? 'Trial' : 'Free'}
                </div>
                {subscription.tier === 'pro' && (
                  <div className="text-gray-600 dark:text-gray-300">
                    {formatCurrency(19)}/month
                  </div>
                )}
              </div>

              {subscription.subscriptionEndDate && (
                <div className="mb-4 text-sm text-gray-600 dark:text-gray-300">
                  {subscription.status === 'active' ? 'Renews' : 'Expires'} on{' '}
                  {formatDate(subscription.subscriptionEndDate)}
                </div>
              )}

              {subscription.paymentMethod && (
                <div className="mb-4 text-sm text-gray-600 dark:text-gray-300">
                  Payment method: {subscription.paymentMethod}
                </div>
              )}

              <div className="space-y-2">
                {subscription.tier === 'free' ? (
                  <Button onClick={() => setShowPayment(true)} className="w-full">
                    Upgrade to Pro
                  </Button>
                ) : subscription.status === 'active' ? (
                  <Button
                    variant="outline"
                    onClick={handleCancel}
                    className="w-full"
                  >
                    Cancel Subscription
                  </Button>
                ) : (
                  <Button onClick={() => setShowPayment(true)} className="w-full">
                    Reactivate Subscription
                  </Button>
                )}
              </div>
            </div>
          )}
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
            Payment History
          </h2>
          {invoices.length > 0 ? (
            <div className="space-y-3">
              {invoices.slice(0, 5).map((invoice) => (
                <div
                  key={invoice.id}
                  className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded"
                >
                  <div>
                    <div className="font-medium text-gray-900 dark:text-white">
                      {formatCurrency(invoice.amount, invoice.currency)}
                    </div>
                    <div className="text-sm text-gray-500 dark:text-gray-400">
                      {formatDate(invoice.createdAt)} â€¢ {invoice.provider}
                    </div>
                  </div>
                  <div className="flex items-center space-x-2">
                    <span
                      className={`text-xs px-2 py-1 rounded ${
                        invoice.status === 'completed'
                          ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'
                          : 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400'
                      }`}
                    >
                      {invoice.status}
                    </span>
                    <Button variant="ghost" size="sm">
                      <Download className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500 dark:text-gray-400">No payment history</p>
          )}
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
