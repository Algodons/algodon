import { getDbConnection } from '@/lib/db/oracle';

export async function trackRequest(userId: string, requestType: string) {
  const connection = await getDbConnection();

  try {
    // Get user subscription
    const subResult = await connection.execute(
      `SELECT tier, status, requests_used, requests_limit, trial_end_date
       FROM subscriptions
       WHERE user_id = :userId`,
      { userId }
    );

    if (!subResult.rows || subResult.rows.length === 0) {
      // Create default free subscription
      await connection.execute(
        `INSERT INTO subscriptions (id, user_id, tier, status, requests_limit)
         VALUES (SYS_GUID(), :userId, 'free', 'active', 22)`,
        { userId }
      );
      await connection.commit();
      
      // Retry fetch
      const retryResult = await connection.execute(
        `SELECT tier, status, requests_used, requests_limit, trial_end_date
         FROM subscriptions
         WHERE user_id = :userId`,
        { userId }
      );
      
      if (retryResult.rows && retryResult.rows.length > 0) {
        return await checkLimit(connection, userId, retryResult.rows[0] as any[]);
      }
    }

    const [tier, status, requestsUsed, requestsLimit, trialEndDate] = subResult.rows[0] as any[];

    await checkLimit(connection, userId, [tier, status, requestsUsed, requestsLimit, trialEndDate]);

    // Increment request count
    await connection.execute(
      `UPDATE subscriptions 
       SET requests_used = requests_used + 1
       WHERE user_id = :userId`,
      { userId }
    );

    await connection.commit();
  } finally {
    await connection.close();
  }
}

async function checkLimit(
  connection: any,
  userId: string,
  [tier, status, requestsUsed, requestsLimit, trialEndDate]: any[]
) {
  // Free tier: 22 requests total
  if (tier === 'free') {
    if (requestsUsed >= requestsLimit) {
      throw new Error('FREE_LIMIT_REACHED');
    }
  }

  // Trial: Check if expired
  if (tier === 'trial') {
    if (trialEndDate) {
      const trialEnd = new Date(trialEndDate);
      if (trialEnd < new Date()) {
        throw new Error('TRIAL_EXPIRED');
      }
    }
  }

  // Pro: Check if active
  if (tier === 'pro') {
    if (status !== 'active') {
      throw new Error('SUBSCRIPTION_INACTIVE');
    }
  }
}
