export interface User {
  id: string;
  email: string;
  name: string | null;
  image: string | null;
  createdAt: Date;
  updatedAt: Date;
  role: 'user' | 'admin';
  subscriptionTier: 'free' | 'trial' | 'pro';
  subscriptionStatus: 'active' | 'cancelled' | 'expired';
  requestsUsed: number;
  requestsLimit: number;
  trialEndDate: Date | null;
}
