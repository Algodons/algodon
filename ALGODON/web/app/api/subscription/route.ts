import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { getDbConnection } from '@/lib/db/oracle';

export async function GET(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const connection = await getDbConnection();
    
    const result = await connection.execute(
      `SELECT 
        tier,
        status,
        requests_used,
        requests_limit,
        trial_end_date,
        subscription_end_date
      FROM subscriptions
      WHERE user_id = :userId`,
      { userId }
    );

    await connection.close();

    if (result.rows && result.rows.length > 0) {
      const row = result.rows[0] as any[];
      return NextResponse.json({
        tier: row[0],
        status: row[1],
        requestsUsed: row[2],
        requestsLimit: row[3] === -1 ? Infinity : row[3],
        trialEndDate: row[4]?.toISOString() || null,
        subscriptionEndDate: row[5]?.toISOString() || null,
      });
    }

    // Default free tier
    return NextResponse.json({
      tier: 'free',
      status: 'active',
      requestsUsed: 0,
      requestsLimit: 22,
      trialEndDate: null,
      subscriptionEndDate: null,
    });
  } catch (error) {
    console.error('Failed to fetch subscription:', error);
    return NextResponse.json(
      { error: 'Failed to fetch subscription' },
      { status: 500 }
    );
  }
}

