export interface Subscription {
  id: string;
  userId: string;
  tier: 'free' | 'trial' | 'pro';
  status: 'active' | 'cancelled' | 'expired';
  trialStartDate: Date | null;
  trialEndDate: Date | null;
  subscriptionStartDate: Date | null;
  subscriptionEndDate: Date | null;
  paymentMethod: 'stripe' | 'square' | 'cashapp' | 'crypto' | 'web3' | null;
  stripeSubscriptionId: string | null;
  squareSubscriptionId: string | null;
  requestsUsed: number;
  requestsLimit: number;
  autoRenew: boolean;
  createdAt: Date;
  updatedAt: Date;
}
