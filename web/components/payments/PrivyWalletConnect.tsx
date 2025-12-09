'use client';

import { useState } from 'react';
import { usePrivy } from '@privy-io/react-auth';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';
import { ethers } from 'ethers';

interface PrivyWalletConnectProps {
  plan: 'pro';
  onSuccess: () => void;
}

export function PrivyWalletConnect({ plan, onSuccess }: PrivyWalletConnectProps) {
  const { ready, authenticated, login, user } = usePrivy();
  const [loading, setLoading] = useState(false);

  const handlePayment = async () => {
    if (!authenticated) {
      login();
      return;
    }

    setLoading(true);
    try {
      const wallet = user?.wallet;
      if (!wallet) {
        alert('Please connect your wallet first');
        return;
      }

      // Amount: $19 = 0.019 ETH (or equivalent in USDC)
      const amount = ethers.parseEther('0.019'); // Adjust based on current ETH price
      const recipient = process.env.NEXT_PUBLIC_PAYMENT_WALLET_ADDRESS!;

      // Create transaction
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const tx = await signer.sendTransaction({
        to: recipient,
        value: amount,
      });

      // Wait for confirmation
      await tx.wait();

      // Verify payment on backend
      const response = await fetch('/api/payments/web3/verify-payment', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          plan,
          txHash: tx.hash,
          walletAddress: wallet.address,
        }),
      });

      const data = await response.json();
      
      if (data.error) {
        alert(data.error);
        return;
      }

      if (data.success) {
        onSuccess();
      }
    } catch (error: any) {
      console.error('Web3 payment error:', error);
      alert(error.message || 'Failed to process payment. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  if (!ready) {
    return <div className="text-center text-gray-500">Loading...</div>;
  }

  return (
    <div>
      {!authenticated ? (
        <div>
          <p className="text-sm text-gray-600 dark:text-gray-300 mb-4">
            Connect your Web3 wallet to pay with cryptocurrency
          </p>
          <Button onClick={login} className="w-full" size="lg">
            Connect Wallet
          </Button>
        </div>
      ) : (
        <div>
          <div className="mb-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="text-gray-600 dark:text-gray-300">Plan</span>
              <span className="font-semibold text-gray-900 dark:text-white">Pro - $19/month</span>
            </div>
            <div className="text-xs text-gray-500 dark:text-gray-400 mt-2">
              Connected: {user?.wallet?.address?.slice(0, 6)}...{user?.wallet?.address?.slice(-4)}
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
              'Pay with Web3 Wallet'
            )}
          </Button>
          <p className="text-xs text-gray-500 dark:text-gray-400 mt-2 text-center">
            Secure payment on Ethereum/Polygon
          </p>
        </div>
      )}
    </div>
  );
}
