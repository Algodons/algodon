import { NextRequest, NextResponse } from 'next/server';
import { getDbConnection } from '@/lib/db/oracle';
import { createClient } from 'redis';

export async function GET(req: NextRequest) {
  const checks: Record<string, string> = {};

  // Database check
  try {
    const connection = await getDbConnection();
    await connection.execute('SELECT 1 FROM DUAL');
    await connection.close();
    checks.database = 'healthy';
  } catch (error) {
    checks.database = 'unhealthy';
  }

  // Redis check
  try {
    const redis = createClient({ url: process.env.REDIS_URL });
    await redis.connect();
    await redis.ping();
    await redis.quit();
    checks.redis = 'healthy';
  } catch (error) {
    checks.redis = 'unhealthy';
  }

  const allHealthy = Object.values(checks).every((status) => status === 'healthy');

  return NextResponse.json(
    {
      status: allHealthy ? 'healthy' : 'degraded',
      checks,
      timestamp: new Date().toISOString(),
    },
    { status: allHealthy ? 200 : 503 }
  );
}

