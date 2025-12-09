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
      `SELECT id, amount, currency, provider, status, created_at
       FROM payments
       WHERE user_id = :userId
       ORDER BY created_at DESC
       FETCH FIRST 20 ROWS ONLY`,
      { userId }
    );

    await connection.close();

    const invoices = (result.rows || []).map((row: any[]) => ({
      id: row[0],
      amount: row[1],
      currency: row[2],
      provider: row[3],
      status: row[4],
      createdAt: row[5]?.toISOString() || new Date().toISOString(),
    }));

    return NextResponse.json(invoices);
  } catch (error) {
    console.error('Failed to fetch invoices:', error);
    return NextResponse.json(
      { error: 'Failed to fetch invoices' },
      { status: 500 }
    );
  }
}

