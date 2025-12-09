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
    
    // Get total requests
    const totalResult = await connection.execute(
      `SELECT COUNT(*) as total FROM user_requests WHERE user_id = :userId`,
      { userId }
    );
    const total = (totalResult.rows?.[0] as any[])?.[0] || 0;

    // Get requests by type
    const byTypeResult = await connection.execute(
      `SELECT request_type, COUNT(*) as count 
       FROM user_requests 
       WHERE user_id = :userId 
       GROUP BY request_type`,
      { userId }
    );
    const byType: Record<string, number> = {};
    if (byTypeResult.rows) {
      for (const row of byTypeResult.rows) {
        const [type, count] = row as any[];
        byType[type] = count;
      }
    }

    // Get requests by day (last 30 days)
    const byDayResult = await connection.execute(
      `SELECT 
        TO_CHAR(timestamp, 'YYYY-MM-DD') as date,
        COUNT(*) as count
      FROM user_requests
      WHERE user_id = :userId 
        AND timestamp >= SYSDATE - 30
      GROUP BY TO_CHAR(timestamp, 'YYYY-MM-DD')
      ORDER BY date`,
      { userId }
    );
    const byDay = (byDayResult.rows || []).map((row: any[]) => ({
      date: row[0],
      count: row[1],
    }));

    // Get recent requests
    const recentResult = await connection.execute(
      `SELECT id, request_type, timestamp, status
       FROM user_requests
       WHERE user_id = :userId
       ORDER BY timestamp DESC
       FETCH FIRST 20 ROWS ONLY`,
      { userId }
    );
    const recent = (recentResult.rows || []).map((row: any[]) => ({
      id: row[0],
      type: row[1],
      timestamp: row[2]?.toISOString() || new Date().toISOString(),
      status: row[3] || 'success',
    }));

    await connection.close();

    return NextResponse.json({
      total,
      byType,
      byDay,
      recent,
    });
  } catch (error) {
    console.error('Failed to fetch usage stats:', error);
    return NextResponse.json(
      { error: 'Failed to fetch usage stats' },
      { status: 500 }
    );
  }
}

