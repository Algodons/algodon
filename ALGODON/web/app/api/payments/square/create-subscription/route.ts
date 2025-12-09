import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { Client, Environment } from 'square';

const client = new Client({
  accessToken: process.env.SQUARE_ACCESS_TOKEN!,
  environment: process.env.SQUARE_ENVIRONMENT === 'production' ? Environment.Production : Environment.Sandbox,
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

    // Get user email
    const { user } = await import('@clerk/nextjs/server');
    const clerkUser = await user();
    const email = clerkUser?.emailAddresses[0]?.emailAddress;

    // Create or retrieve Square customer
    const connection = await import('@/lib/db/oracle').then((m) => m.getDbConnection());
    const customerResult = await connection.execute(
      `SELECT square_customer_id FROM users WHERE id = :userId`,
      { userId }
    );

    let customerId: string;
    if (customerResult.rows && customerResult.rows.length > 0 && customerResult.rows[0][0]) {
      customerId = customerResult.rows[0][0] as string;
    } else {
      const { result } = await client.customersApi.createCustomer({
        emailAddress: email,
        referenceId: userId,
      });
      customerId = result.customer!.id!;
      
      await connection.execute(
        `UPDATE users SET square_customer_id = :customerId WHERE id = :userId`,
        { customerId, userId }
      );
    }
    await connection.close();

    // Create subscription
    const { result } = await client.subscriptionsApi.createSubscription({
      locationId: process.env.SQUARE_LOCATION_ID!,
      planId: process.env.SQUARE_PLAN_ID!, // $19/month plan ID
      customerId,
      idempotencyKey: `${userId}-${Date.now()}`,
    });

    // Save subscription to database
    const dbConnection = await import('@/lib/db/oracle').then((m) => m.getDbConnection());
    await dbConnection.execute(
      `UPDATE subscriptions 
       SET tier = 'pro',
           status = 'active',
           subscription_start_date = SYSTIMESTAMP,
           subscription_end_date = SYSTIMESTAMP + INTERVAL '1' MONTH,
           square_subscription_id = :subscriptionId,
           requests_limit = -1
       WHERE user_id = :userId`,
      {
        subscriptionId: result.subscription!.id,
        userId,
      }
    );
    await dbConnection.commit();
    await dbConnection.close();

    return NextResponse.json({ 
      success: true,
      subscriptionId: result.subscription!.id,
    });
  } catch (error: any) {
    console.error('Square subscription error:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to create subscription' },
      { status: 500 }
    );
  }
}

