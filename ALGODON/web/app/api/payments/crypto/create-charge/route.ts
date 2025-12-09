import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { Client, resources } from 'coinbase-commerce-node';

Client.init(process.env.COINBASE_COMMERCE_API_KEY!);
const { Charge } = resources;

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

    const charge = await Charge.create({
      name: 'ALGODON Pro - 1 Month',
      description: 'Unlimited code execution and AI assistance',
      pricing_type: 'fixed_price',
      local_price: {
        amount: '19.00',
        currency: 'USD',
      },
      metadata: {
        userId,
        plan: 'pro',
      },
      redirect_url: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard/billing?success=true&provider=crypto`,
      cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/pricing`,
    });

    // Store charge
    const connection = await import('@/lib/db/oracle').then((m) => m.getDbConnection());
    await connection.execute(
      `INSERT INTO payments (id, user_id, amount, currency, provider, status, transaction_id, metadata)
       VALUES (SYS_GUID(), :userId, 19.00, 'USD', 'crypto', 'pending', :chargeId, :metadata)`,
      {
        userId,
        chargeId: charge.id,
        metadata: JSON.stringify(charge),
      }
    );
    await connection.commit();
    await connection.close();

    return NextResponse.json({ 
      hosted_url: charge.hosted_url,
      chargeId: charge.id,
    });
  } catch (error: any) {
    console.error('Coinbase Commerce error:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to create charge' },
      { status: 500 }
    );
  }
}

