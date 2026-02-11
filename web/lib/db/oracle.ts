import oracledb from 'oracledb';

let pool: oracledb.Pool | null = null;

export async function initDbPool() {
  if (pool) {
    return pool;
  }

  try {
    pool = await oracledb.createPool({
      user: process.env.ORACLE_USER || 'algodon',
      password: process.env.ORACLE_PASSWORD || 'password',
      connectString: process.env.ORACLE_CONNECTION_STRING || 'localhost:1521/XE',
      poolMin: 2,
      poolMax: 10,
      poolIncrement: 1,
      poolTimeout: 60,
    });

    console.log('Oracle connection pool created');
    return pool;
  } catch (error) {
    console.error('Failed to create Oracle connection pool:', error);
    throw error;
  }
}

export async function getDbConnection() {
  if (!pool) {
    await initDbPool();
  }

  if (!pool) {
    throw new Error('Database pool not initialized');
  }

  return await pool.getConnection();
}

export async function closeDbPool() {
  if (pool) {
    await pool.close();
    pool = null;
  }
}
