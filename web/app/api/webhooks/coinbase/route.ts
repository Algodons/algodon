import { NextRequest, NextResponse } from 'next/server';
import { headers } from 'next/headers';
import { Webhook } from 'coinbase-commerce-node';
import { getDbConnection } from '@/lib/db/oracle';

const webhookSecret = process.env.COINBASE_COMMERCE_WEBHOOK_SECRET!;

export async function POST(req: NextRequest) {
  const body = await req.text();
  const headersList = await headers();
  const signature = headersList.get('x-cc-webhook-signature');

  if (!signature) {
    return NextResponse.json({ error: 'No signature' }, { status: 400 });
  }

  let event: any;

  try {
    event = Webhook.verifyEventBody(body, signature, webhookSecret);
  } catch (err: any) {
    console.error('Webhook verification failed:', err.message);
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 });
  }

  const connection = await getDbConnection();

  try {
    if (event.type === 'charge:confirmed' || event.type === 'charge:resolved') {
      const charge = event.data;
      const userId = charge.metadata?.userId;
      const plan = charge.metadata?.plan;

      if (userId && plan) {
        // Update payment status
        await connection.execute(
          `UPDATE payments 
           SET status = 'completed'
           WHERE transaction_id = :chargeId`,
          { chargeId: charge.id }
        );

        // Activate subscription
        await connection.execute(
          `UPDATE subscriptions 
           SET tier = :tier,
               status = 'active',
               subscription_start_date = SYSTIMESTAMP,
               subscription_end_date = SYSTIMESTAMP + INTERVAL '1' MONTH,
               payment_method = 'crypto',
               requests_limit = -1
           WHERE user_id = :userId`,
          { tier: plan, userId }
        );
      }
    }

    await connection.commit();
  } catch (error) {
    console.error('Webhook processing error:', error);
    await connection.rollback();
    return NextResponse.json({ error: 'Webhook processing failed' }, { status: 500 });
  } finally {
    await connection.close();
  }

  return NextResponse.json({ received: true });
}
