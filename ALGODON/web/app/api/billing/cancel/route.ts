import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { getDbConnection } from '@/lib/db/oracle';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-11-20.acacia',
});

export async function POST(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const connection = await getDbConnection();
    
    // Get subscription
    const subResult = await connection.execute(
      `SELECT stripe_subscription_id, square_subscription_id, payment_method
       FROM subscriptions
       WHERE user_id = :userId AND status = 'active'`,
      { userId }
    );

    if (!subResult.rows || subResult.rows.length === 0) {
      return NextResponse.json({ error: 'No active subscription' }, { status: 400 });
    }

    const [stripeSubId, squareSubId, paymentMethod] = subResult.rows[0] as any[];

    // Cancel with provider
    if (paymentMethod === 'stripe' && stripeSubId) {
      await stripe.subscriptions.update(stripeSubId, {
        cancel_at_period_end: true,
      });
    } else if (paymentMethod === 'square' && squareSubId) {
      // Square cancellation would go here
      // await squareClient.subscriptionsApi.cancelSubscription(squareSubId);
    }

    // Update database
    await connection.execute(
      `UPDATE subscriptions 
       SET status = 'cancelled',
           auto_renew = 0
       WHERE user_id = :userId`,
      { userId }
    );

    await connection.commit();
    await connection.close();

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Failed to cancel subscription:', error);
    return NextResponse.json(
      { error: 'Failed to cancel subscription' },
      { status: 500 }
    );
  }
}

