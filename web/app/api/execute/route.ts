import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { getDbConnection } from '@/lib/db/oracle';
import { trackRequest } from '@/lib/utils/request-tracker';
import { executeCode } from '@/lib/execution/sandbox';

export async function POST(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { language, code, input, projectId } = await req.json();

    if (!language || !code) {
      return NextResponse.json(
        { error: 'Language and code are required' },
        { status: 400 }
      );
    }

    // Track request (will throw if limit reached)
    await trackRequest(userId, 'code_execution');

    // Execute code in sandbox
    const startTime = Date.now();
    const result = await executeCode(language, code, input);
    const executionTime = Date.now() - startTime;

    // Save execution to database
    const connection = await getDbConnection();
    const executionId = `exec_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    await connection.execute(
      `INSERT INTO code_executions (
        id, user_id, project_id, language, code, input, output, error,
        execution_time, status, created_at
      ) VALUES (
        :id, :userId, :projectId, :language, :code, :input, :output, :error,
        :executionTime, :status, CURRENT_TIMESTAMP
      )`,
      {
        id: executionId,
        userId,
        projectId: projectId || null,
        language,
        code,
        input: input || null,
        output: result.output || null,
        error: result.error || null,
        executionTime: executionTime / 1000, // Convert to seconds
        status: result.error ? 'failed' : 'completed',
      }
    );

    // Update project last executed time if projectId provided
    if (projectId) {
      await connection.execute(
        `UPDATE projects SET last_executed_at = CURRENT_TIMESTAMP WHERE id = :projectId`,
        { projectId }
      );
    }

    await connection.commit();
    await connection.close();

    // Log request
    await logRequest(userId, 'code_execution', result.error ? 'failed' : 'success');

    return NextResponse.json({
      id: executionId,
      output: result.output,
      error: result.error,
      executionTime,
    });
  } catch (error: any) {
    if (error.message === 'FREE_LIMIT_REACHED' || error.message === 'TRIAL_EXPIRED') {
      return NextResponse.json(
        { error: error.message, code: 'LIMIT_REACHED' },
        { status: 403 }
      );
    }

    console.error('Code execution error:', error);
    return NextResponse.json(
      { error: 'Failed to execute code' },
      { status: 500 }
    );
  }
}

async function logRequest(userId: string, type: string, status: string) {
  try {
    const connection = await getDbConnection();
    await connection.execute(
      `INSERT INTO user_requests (id, user_id, request_type, status, timestamp)
       VALUES (SYS_GUID(), :userId, :type, :status, CURRENT_TIMESTAMP)`,
      { userId, type, status }
    );
    await connection.commit();
    await connection.close();
  } catch (error) {
    console.error('Failed to log request:', error);
  }
}
