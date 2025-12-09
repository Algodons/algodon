export interface Payment {
  id: string;
  userId: string;
  amount: number;
  currency: string;
  provider: 'stripe' | 'square' | 'cashapp' | 'crypto' | 'web3';
  status: 'pending' | 'completed' | 'failed' | 'refunded';
  transactionId: string | null;
  metadata: Record<string, any>;
  createdAt: Date;
  updatedAt: Date;
}
