import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';

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

    // Cash App API integration
    // Note: Cash App Pay API requires OAuth and specific setup
    const response = await fetch('https://api.cash.app/v1/payments', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.CASHAPP_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        amount: { amount: 1900, currency: 'USD' }, // $19.00 in cents
        cashtag: process.env.CASHAPP_CASHTAG || '$ALGODON',
        note: 'ALGODON Pro Subscription - 1 Month',
        redirect_url: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard/billing?success=true&provider=cashapp`,
        metadata: {
          userId,
          plan: 'pro',
        },
      }),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Cash App payment failed');
    }

    const data = await response.json();

    // Store payment intent
    const connection = await import('@/lib/db/oracle').then((m) => m.getDbConnection());
    await connection.execute(
      `INSERT INTO payments (id, user_id, amount, currency, provider, status, transaction_id, metadata)
       VALUES (SYS_GUID(), :userId, 19.00, 'USD', 'cashapp', 'pending', :paymentId, :metadata)`,
      {
        userId,
        paymentId: data.id,
        metadata: JSON.stringify(data),
      }
    );
    await connection.commit();
    await connection.close();

    return NextResponse.json({ 
      paymentUrl: data.redirect_url || data.hosted_url,
      paymentId: data.id,
    });
  } catch (error: any) {
    console.error('CashApp payment error:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to create payment' },
      { status: 500 }
    );
  }
}

