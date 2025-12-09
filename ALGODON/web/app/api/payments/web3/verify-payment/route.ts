import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { ethers } from 'ethers';

export async function POST(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { plan, txHash, walletAddress } = await req.json();
    
    if (plan !== 'pro') {
      return NextResponse.json({ error: 'Invalid plan' }, { status: 400 });
    }

    // Verify transaction on-chain
    const provider = new ethers.JsonRpcProvider(process.env.ETH_RPC_URL!);
    const tx = await provider.getTransaction(txHash);
    const receipt = await provider.getTransactionReceipt(txHash);

    if (!tx || !receipt || receipt.status !== 1) {
      return NextResponse.json({ error: 'Invalid transaction' }, { status: 400 });
    }

    // Verify amount (0.019 ETH or equivalent)
    const expectedAmount = ethers.parseEther('0.019');
    if (tx.value.toString() !== expectedAmount.toString()) {
      return NextResponse.json({ error: 'Incorrect payment amount' }, { status: 400 });
    }

    // Verify recipient
    const expectedRecipient = process.env.PAYMENT_WALLET_ADDRESS!.toLowerCase();
    if (tx.to?.toLowerCase() !== expectedRecipient) {
      return NextResponse.json({ error: 'Incorrect recipient address' }, { status: 400 });
    }

    // Store payment and activate subscription
    const connection = await import('@/lib/db/oracle').then((m) => m.getDbConnection());
    
    await connection.execute(
      `INSERT INTO payments (id, user_id, amount, currency, provider, status, transaction_id, metadata)
       VALUES (SYS_GUID(), :userId, 19.00, 'USD', 'web3', 'completed', :txHash, :metadata)`,
      {
        userId,
        txHash,
        metadata: JSON.stringify({ walletAddress, blockNumber: receipt.blockNumber }),
      }
    );

    await connection.execute(
      `UPDATE subscriptions 
       SET tier = :tier,
           status = 'active',
           subscription_start_date = SYSTIMESTAMP,
           subscription_end_date = SYSTIMESTAMP + INTERVAL '1' MONTH,
           payment_method = 'web3',
           requests_limit = -1
       WHERE user_id = :userId`,
      { tier: plan, userId }
    );

    await connection.commit();
    await connection.close();

    return NextResponse.json({ success: true });
  } catch (error: any) {
    console.error('Web3 payment verification error:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to verify payment' },
      { status: 500 }
    );
  }
}

