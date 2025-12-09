import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
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

    const { plan } = await req.json();
    
    if (plan !== 'pro') {
      return NextResponse.json({ error: 'Invalid plan' }, { status: 400 });
    }

    // Get user email from Clerk
    const { user } = await import('@clerk/nextjs/server');
    const clerkUser = await user();
    const email = clerkUser?.emailAddresses[0]?.emailAddress;

    // Create or retrieve Stripe customer
    let customerId: string;
    const connection = await import('@/lib/db/oracle').then((m) => m.getDbConnection());
    const customerResult = await connection.execute(
      `SELECT stripe_customer_id FROM users WHERE id = :userId`,
      { userId }
    );

    if (customerResult.rows && customerResult.rows.length > 0 && customerResult.rows[0][0]) {
      customerId = customerResult.rows[0][0] as string;
    } else {
      const customer = await stripe.customers.create({
        email,
        metadata: { userId },
      });
      customerId = customer.id;
      
      await connection.execute(
        `UPDATE users SET stripe_customer_id = :customerId WHERE id = :userId`,
        { customerId, userId }
      );
    }
    await connection.close();

    // Create checkout session
    const session = await stripe.checkout.sessions.create({
      customer: customerId,
      mode: 'subscription',
      line_items: [
        {
          price: process.env.STRIPE_PRICE_ID_PRO!, // $19/month price ID
          quantity: 1,
        },
      ],
      success_url: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard/billing?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/pricing`,
      metadata: {
        userId,
        plan: 'pro',
      },
      subscription_data: {
        trial_period_days: 30,
        metadata: {
          userId,
          plan: 'pro',
        },
      },
    });

    return NextResponse.json({ url: session.url });
  } catch (error) {
    console.error('Stripe checkout error:', error);
    return NextResponse.json(
      { error: 'Failed to create checkout session' },
      { status: 500 }
    );
  }
}

