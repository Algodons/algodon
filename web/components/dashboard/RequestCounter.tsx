'use client';

import { useEffect, useState } from 'react';
import { useUser } from '@clerk/nextjs';
import { AlertCircle } from 'lucide-react';
import { UpgradeModal } from '@/components/dashboard/UpgradeModal';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

interface Subscription {
  tier: 'free' | 'trial' | 'pro';
  requestsUsed: number;
  requestsLimit: number;
  status: 'active' | 'cancelled' | 'expired';
  trialEndDate: string | null;
}

export function RequestCounter() {
  const { user } = useUser();
  const [subscription, setSubscription] = useState<Subscription | null>(null);
  const [showUpgrade, setShowUpgrade] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) return;

    const fetchSubscription = async () => {
      try {
        const response = await fetch('/api/subscription');
        if (response.ok) {
          const data = await response.json();
          setSubscription(data);
          
          // Show upgrade modal if free tier and limit reached
          if (data.tier === 'free' && data.requestsUsed >= data.requestsLimit) {
            setShowUpgrade(true);
          }
          
          // Show upgrade modal if trial expired
          if (data.tier === 'trial' && data.trialEndDate) {
            const trialEnd = new Date(data.trialEndDate);
            if (trialEnd < new Date() && data.status === 'expired') {
              setShowUpgrade(true);
            }
          }
        }
      } catch (error) {
        console.error('Failed to fetch subscription:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchSubscription();
    
    // Poll for updates every 30 seconds
    const interval = setInterval(fetchSubscription, 30000);
    return () => clearInterval(interval);
  }, [user]);

  if (loading || !subscription) {
    return (
      <div className="h-8 w-32 bg-gray-200 dark:bg-gray-700 rounded animate-pulse" />
    );
  }

  const percentage = (subscription.requestsUsed / subscription.requestsLimit) * 100;
  const isNearLimit = percentage >= 80;
  const isAtLimit = subscription.requestsUsed >= subscription.requestsLimit;

  return (
    <>
      <div
        className={cn(
          'flex items-center space-x-3 px-4 py-2 rounded-lg border',
          isAtLimit
            ? 'border-red-300 bg-red-50 dark:border-red-800 dark:bg-red-900/20'
            : isNearLimit
            ? 'border-yellow-300 bg-yellow-50 dark:border-yellow-800 dark:bg-yellow-900/20'
            : 'border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-800'
        )}
      >
        {isAtLimit && <AlertCircle className="w-4 h-4 text-red-600 dark:text-red-400" />}
        <div className="flex flex-col">
          <span className="text-xs text-gray-500 dark:text-gray-400">
            {subscription.tier === 'free' ? 'Free Requests' : 'Requests'}
          </span>
          <span
            className={cn(
              'text-sm font-semibold',
              isAtLimit
                ? 'text-red-600 dark:text-red-400'
                : isNearLimit
                ? 'text-yellow-600 dark:text-yellow-400'
                : 'text-gray-900 dark:text-white'
            )}
          >
            {subscription.requestsUsed} / {subscription.requestsLimit === Infinity ? 'âˆž' : subscription.requestsLimit}
          </span>
        </div>
        {subscription.tier === 'free' && (
          <div className="w-24 h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
            <div
              className={cn(
                'h-full transition-all',
                isAtLimit
                  ? 'bg-red-500'
                  : isNearLimit
                  ? 'bg-yellow-500'
                  : 'bg-primary-500'
              )}
              style={{ width: `${Math.min(percentage, 100)}%` }}
            />
          </div>
        )}
        {isAtLimit && subscription.tier === 'free' && (
          <Button
            size="sm"
            onClick={() => setShowUpgrade(true)}
            className="ml-2"
          >
            Upgrade
          </Button>
        )}
      </div>

      {showUpgrade && (
        <UpgradeModal
          isOpen={showUpgrade}
          onClose={() => setShowUpgrade(false)}
          reason={isAtLimit ? 'limit_reached' : 'trial_expired'}
        />
      )}
    </>
  );
}
