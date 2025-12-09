import { NextRequest, NextResponse } from 'next/server';
import { headers } from 'next/headers';
import Stripe from 'stripe';
import { getDbConnection } from '@/lib/db/oracle';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-11-20.acacia',
});

export async function POST(req: NextRequest) {
  const body = await req.text();
  const headersList = await headers();
  const signature = headersList.get('stripe-signature');

  if (!signature) {
    return NextResponse.json({ error: 'No signature' }, { status: 400 });
  }

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (err: any) {
    console.error('Webhook signature verification failed:', err.message);
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 });
  }

  const connection = await getDbConnection();

  try {
    switch (event.type) {
      case 'checkout.session.completed': {
        const session = event.data.object as Stripe.Checkout.Session;
        const userId = session.metadata?.userId;
        const plan = session.metadata?.plan;

        if (userId && plan) {
          await connection.execute(
            `UPDATE subscriptions 
             SET tier = :tier, 
                 status = 'active',
                 subscription_start_date = SYSTIMESTAMP,
                 subscription_end_date = SYSTIMESTAMP + INTERVAL '1' MONTH,
                 stripe_subscription_id = :subscriptionId,
                 requests_limit = -1
             WHERE user_id = :userId`,
            {
              tier: plan,
              subscriptionId: session.subscription as string,
              userId,
            }
          );
        }
        break;
      }

      case 'customer.subscription.updated': {
        const subscription = event.data.object as Stripe.Subscription;
        const userId = subscription.metadata?.userId;

        if (userId) {
          await connection.execute(
            `UPDATE subscriptions 
             SET status = :status,
                 subscription_end_date = TO_TIMESTAMP(:endDate, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
             WHERE stripe_subscription_id = :subscriptionId`,
            {
              status: subscription.status === 'active' ? 'active' : 'cancelled',
              endDate: new Date(subscription.current_period_end * 1000).toISOString(),
              subscriptionId: subscription.id,
            }
          );
        }
        break;
      }

      case 'customer.subscription.deleted': {
        const subscription = event.data.object as Stripe.Subscription;
        const userId = subscription.metadata?.userId;

        if (userId) {
          await connection.execute(
            `UPDATE subscriptions 
             SET status = 'cancelled',
                 requests_limit = 22
             WHERE stripe_subscription_id = :subscriptionId`,
            { subscriptionId: subscription.id }
          );
        }
        break;
      }

      case 'invoice.payment_succeeded': {
        const invoice = event.data.object as Stripe.Invoice;
        const subscriptionId = invoice.subscription as string;

        if (subscriptionId) {
          await connection.execute(
            `UPDATE subscriptions 
             SET subscription_end_date = TO_TIMESTAMP(:endDate, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
             WHERE stripe_subscription_id = :subscriptionId`,
            {
              endDate: new Date(invoice.period_end * 1000).toISOString(),
              subscriptionId,
            }
          );
        }
        break;
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
