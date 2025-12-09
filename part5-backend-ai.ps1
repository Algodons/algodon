# ALGODON Part 5: Backend & AI Services
# This script creates Oracle database schemas, AI agents, and backend API routes

Write-Host "🚀 ALGODON Part 5: Backend & AI Services" -ForegroundColor Cyan

Set-Location "ALGODON"

# Generate Oracle database connection utility
$oracleConnection = @'
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
'@

$oracleConnection | Out-File -FilePath "web/lib/db/oracle.ts" -Encoding UTF8
Write-Host "✅ Created Oracle connection utility" -ForegroundColor Green

# Generate Oracle database schema SQL
$oracleSchema = @'
-- ALGODON Oracle Database Schema
-- Run this script to create all tables, indexes, and triggers

-- Users table
CREATE TABLE users (
  id VARCHAR2(36) PRIMARY KEY,
  email VARCHAR2(255) UNIQUE NOT NULL,
  name VARCHAR2(255),
  image VARCHAR2(500),
  role VARCHAR2(20) DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  stripe_customer_id VARCHAR2(100),
  square_customer_id VARCHAR2(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Subscriptions table
CREATE TABLE subscriptions (
  id VARCHAR2(36) PRIMARY KEY,
  user_id VARCHAR2(36) UNIQUE NOT NULL,
  tier VARCHAR2(20) DEFAULT 'free' CHECK (tier IN ('free', 'trial', 'pro')),
  status VARCHAR2(20) DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired')),
  trial_start_date TIMESTAMP,
  trial_end_date TIMESTAMP,
  subscription_start_date TIMESTAMP,
  subscription_end_date TIMESTAMP,
  payment_method VARCHAR2(50) CHECK (payment_method IN ('stripe', 'square', 'cashapp', 'crypto', 'web3')),
  stripe_subscription_id VARCHAR2(100),
  square_subscription_id VARCHAR2(100),
  requests_used NUMBER DEFAULT 0,
  requests_limit NUMBER DEFAULT 22,
  auto_renew NUMBER(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_subscription_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Projects table
CREATE TABLE projects (
  id VARCHAR2(36) PRIMARY KEY,
  user_id VARCHAR2(36) NOT NULL,
  name VARCHAR2(255) NOT NULL,
  description VARCHAR2(1000),
  language VARCHAR2(50),
  is_public NUMBER(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_executed_at TIMESTAMP,
  CONSTRAINT fk_project_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Project files table
CREATE TABLE project_files (
  id VARCHAR2(36) PRIMARY KEY,
  project_id VARCHAR2(36) NOT NULL,
  path VARCHAR2(500) NOT NULL,
  content CLOB,
  language VARCHAR2(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_file_project FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  CONSTRAINT uk_file_project_path UNIQUE (project_id, path)
);

-- User requests table (for tracking free tier usage)
CREATE TABLE user_requests (
  id VARCHAR2(36) PRIMARY KEY,
  user_id VARCHAR2(36) NOT NULL,
  request_type VARCHAR2(50) NOT NULL,
  status VARCHAR2(20) DEFAULT 'success' CHECK (status IN ('success', 'failed')),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  metadata CLOB,
  CONSTRAINT fk_request_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Code executions table
CREATE TABLE code_executions (
  id VARCHAR2(36) PRIMARY KEY,
  user_id VARCHAR2(36) NOT NULL,
  project_id VARCHAR2(36),
  language VARCHAR2(50) NOT NULL,
  code CLOB NOT NULL,
  input CLOB,
  output CLOB,
  error CLOB,
  execution_time NUMBER,
  status VARCHAR2(20) DEFAULT 'pending' CHECK (status IN ('pending', 'running', 'completed', 'failed', 'timeout')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_execution_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_execution_project FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL
);

-- Payments table
CREATE TABLE payments (
  id VARCHAR2(36) PRIMARY KEY,
  user_id VARCHAR2(36) NOT NULL,
  amount NUMBER(10, 2) NOT NULL,
  currency VARCHAR2(10) DEFAULT 'USD',
  provider VARCHAR2(50) NOT NULL CHECK (provider IN ('stripe', 'square', 'cashapp', 'crypto', 'web3')),
  status VARCHAR2(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  transaction_id VARCHAR2(255),
  metadata CLOB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payment_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- AI conversations table
CREATE TABLE ai_conversations (
  id VARCHAR2(36) PRIMARY KEY,
  user_id VARCHAR2(36) NOT NULL,
  project_id VARCHAR2(36),
  model VARCHAR2(50) NOT NULL,
  messages CLOB NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_conversation_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_conversation_project FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL
);

-- AI model configurations table
CREATE TABLE ai_model_configs (
  id VARCHAR2(36) PRIMARY KEY,
  name VARCHAR2(100) UNIQUE NOT NULL,
  provider VARCHAR2(50) NOT NULL,
  model_id VARCHAR2(100) NOT NULL,
  api_key_encrypted VARCHAR2(500),
  temperature NUMBER(3, 2) DEFAULT 0.7,
  max_tokens NUMBER DEFAULT 2000,
  is_active NUMBER(1) DEFAULT 1,
  rate_limit_per_user NUMBER DEFAULT 50,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_project_files_project_id ON project_files(project_id);
CREATE INDEX idx_user_requests_user_id ON user_requests(user_id);
CREATE INDEX idx_user_requests_timestamp ON user_requests(timestamp);
CREATE INDEX idx_code_executions_user_id ON code_executions(user_id);
CREATE INDEX idx_code_executions_project_id ON code_executions(project_id);
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_ai_conversations_user_id ON ai_conversations(user_id);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE TRIGGER update_users_timestamp
  BEFORE UPDATE ON users
  FOR EACH ROW
BEGIN
  :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER update_subscriptions_timestamp
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW
BEGIN
  :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER update_projects_timestamp
  BEFORE UPDATE ON projects
  FOR EACH ROW
BEGIN
  :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER update_project_files_timestamp
  BEFORE UPDATE ON project_files
  FOR EACH ROW
BEGIN
  :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Insert default AI models
INSERT INTO ai_model_configs (id, name, provider, model_id, is_active, temperature, max_tokens) VALUES
  (SYS_GUID(), 'GPT-4 Turbo', 'openai', 'gpt-4-turbo-preview', 1, 0.7, 4096),
  (SYS_GUID(), 'Claude 3 Opus', 'anthropic', 'claude-3-opus-20240229', 1, 0.7, 4096),
  (SYS_GUID(), 'Gemini Pro', 'google', 'gemini-pro', 1, 0.7, 2048);

COMMIT;
'@

$oracleSchema | Out-File -FilePath "database/oracle/schemas/01_schema.sql" -Encoding UTF8
Write-Host "✅ Created Oracle database schema" -ForegroundColor Green

# Generate code execution API
$executeApi = @'
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
'@

$executeApi | Out-File -FilePath "web/app/api/execute/route.ts" -Encoding UTF8

# Generate request tracker utility
$requestTracker = @'
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
'@

$requestTracker | Out-File -FilePath "web/lib/utils/request-tracker.ts" -Encoding UTF8
Write-Host "✅ Created request tracker" -ForegroundColor Green

# Generate code execution sandbox
$sandboxExecutor = @'
import Docker from 'dockerode';

const docker = new Docker();

interface ExecutionResult {
  output: string | null;
  error: string | null;
  exitCode: number;
}

const languageConfigs: Record<string, { image: string; command: string[] }> = {
  python: {
    image: 'python:3.11-slim',
    command: ['python', '-c'],
  },
  javascript: {
    image: 'node:20-slim',
    command: ['node', '-e'],
  },
  typescript: {
    image: 'node:20-slim',
    command: ['ts-node', '-e'],
  },
  go: {
    image: 'golang:1.21-alpine',
    command: ['go', 'run'],
  },
  rust: {
    image: 'rust:1.75-slim',
    command: ['rustc', '-o', '/tmp/out', '-'],
  },
  java: {
    image: 'openjdk:17-slim',
    command: ['javac', '-d', '/tmp', '-'],
  },
  cpp: {
    image: 'gcc:latest',
    command: ['g++', '-o', '/tmp/out', '-'],
  },
};

export async function executeCode(
  language: string,
  code: string,
  input?: string
): Promise<ExecutionResult> {
  const config = languageConfigs[language.toLowerCase()];
  if (!config) {
    throw new Error(`Unsupported language: ${language}`);
  }

  try {
    // Create container
    const container = await docker.createContainer({
      Image: config.image,
      Cmd: [...config.command, code],
      AttachStdout: true,
      AttachStderr: true,
      Tty: false,
      HostConfig: {
        Memory: 512 * 1024 * 1024, // 512MB
        CpuQuota: 100000, // 1 CPU core
        NetworkMode: 'none',
      },
      OpenStdin: !!input,
      StdinOnce: !!input,
    });

    // Start container
    await container.start();

    // Set timeout (30 seconds)
    const timeout = setTimeout(async () => {
      try {
        await container.stop();
        await container.remove();
      } catch (error) {
        // Container may already be stopped
      }
    }, 30000);

    // Attach to container streams
    const stream = await container.attach({
      stream: true,
      stdout: true,
      stderr: true,
    });

    // Send input if provided
    if (input) {
      container.stdin?.write(input);
      container.stdin?.end();
    }

    // Collect output
    let output = '';
    let error = '';

    stream.on('data', (chunk: Buffer) => {
      const data = chunk.toString();
      // Try to determine if it's stdout or stderr
      // This is a simplified approach
      output += data;
    });

    // Wait for container to finish
    const exitCode = await container.wait();
    clearTimeout(timeout);

    // Get logs
    const logs = await container.logs({
      stdout: true,
      stderr: true,
    });

    const logOutput = logs.toString();

    // Clean up
    await container.remove();

    return {
      output: exitCode.StatusCode === 0 ? logOutput : null,
      error: exitCode.StatusCode !== 0 ? logOutput : null,
      exitCode: exitCode.StatusCode || 0,
    };
  } catch (error: any) {
    return {
      output: null,
      error: error.message || 'Execution failed',
      exitCode: 1,
    };
  }
}
'@

$sandboxExecutor | Out-File -FilePath "web/lib/execution/sandbox.ts" -Encoding UTF8
Write-Host "✅ Created code execution sandbox" -ForegroundColor Green

# Generate AI completion API
$aiCompleteApi = @'
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { trackRequest } from '@/lib/utils/request-tracker';
import { generateCompletion } from '@/lib/ai/completion';

export async function POST(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { code, language, cursorPosition, model = 'gpt-4-turbo' } = await req.json();

    if (!code) {
      return NextResponse.json(
        { error: 'Code is required' },
        { status: 400 }
      );
    }

    // Track request
    await trackRequest(userId, 'ai_completion');

    // Generate completion
    const completion = await generateCompletion(code, language, cursorPosition, model);

    return NextResponse.json({ completion });
  } catch (error: any) {
    if (error.message === 'FREE_LIMIT_REACHED' || error.message === 'TRIAL_EXPIRED') {
      return NextResponse.json(
        { error: error.message, code: 'LIMIT_REACHED' },
        { status: 403 }
      );
    }

    console.error('AI completion error:', error);
    return NextResponse.json(
      { error: 'Failed to generate completion' },
      { status: 500 }
    );
  }
}
'@

$aiCompleteApi | Out-File -FilePath "web/app/api/ai/complete/route.ts" -Encoding UTF8

# Generate AI chat API
$aiChatApi = @'
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { trackRequest } from '@/lib/utils/request-tracker';
import { generateChatResponse } from '@/lib/ai/chat';
import { getDbConnection } from '@/lib/db/oracle';

export async function POST(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { message, conversationId, projectId, model = 'gpt-4-turbo' } = await req.json();

    if (!message) {
      return NextResponse.json(
        { error: 'Message is required' },
        { status: 400 }
      );
    }

    // Track request
    await trackRequest(userId, 'ai_chat');

    // Get or create conversation
    const connection = await getDbConnection();
    let convId = conversationId;
    let messages: any[] = [];

    if (convId) {
      const convResult = await connection.execute(
        `SELECT messages FROM ai_conversations WHERE id = :convId AND user_id = :userId`,
        { convId, userId }
      );

      if (convResult.rows && convResult.rows.length > 0) {
        messages = JSON.parse(convResult.rows[0][0] as string);
      }
    } else {
      convId = `conv_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }

    // Add user message
    messages.push({ role: 'user', content: message });

    // Generate AI response
    const response = await generateChatResponse(messages, model);

    // Add assistant response
    messages.push({ role: 'assistant', content: response });

    // Save conversation
    if (conversationId) {
      await connection.execute(
        `UPDATE ai_conversations 
         SET messages = :messages, updated_at = CURRENT_TIMESTAMP
         WHERE id = :convId`,
        { messages: JSON.stringify(messages), convId }
      );
    } else {
      await connection.execute(
        `INSERT INTO ai_conversations (id, user_id, project_id, model, messages)
         VALUES (:convId, :userId, :projectId, :model, :messages)`,
        {
          convId,
          userId,
          projectId: projectId || null,
          model,
          messages: JSON.stringify(messages),
        }
      );
    }

    await connection.commit();
    await connection.close();

    return NextResponse.json({
      conversationId: convId,
      response,
      messages,
    });
  } catch (error: any) {
    if (error.message === 'FREE_LIMIT_REACHED' || error.message === 'TRIAL_EXPIRED') {
      return NextResponse.json(
        { error: error.message, code: 'LIMIT_REACHED' },
        { status: 403 }
      );
    }

    console.error('AI chat error:', error);
    return NextResponse.json(
      { error: 'Failed to generate chat response' },
      { status: 500 }
    );
  }
}
'@

$aiChatApi | Out-File -FilePath "web/app/api/ai/chat/route.ts" -Encoding UTF8

# Generate AI completion generator
$aiCompletion = @'
import OpenAI from 'openai';
import Anthropic from '@anthropic-ai/sdk';
import { GoogleGenerativeAI } from '@google/generative-ai';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_GEMINI_API_KEY!);

export async function generateCompletion(
  code: string,
  language: string,
  cursorPosition: number,
  model: string
): Promise<string> {
  const prompt = `You are an AI code completion assistant. Complete the following ${language} code at cursor position ${cursorPosition}:

\`\`\`${language}
${code}
\`\`\`

Provide only the completion text that should be inserted at the cursor position, without any explanations or markdown formatting.`;

  try {
    if (model.startsWith('gpt-')) {
      const response = await openai.chat.completions.create({
        model: model,
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 200,
        temperature: 0.7,
      });
      return response.choices[0]?.message?.content || '';
    } else if (model.startsWith('claude-')) {
      const response = await anthropic.messages.create({
        model: model,
        max_tokens: 200,
        messages: [{ role: 'user', content: prompt }],
      });
      return response.content[0].type === 'text' ? response.content[0].text : '';
    } else if (model.startsWith('gemini-')) {
      const genModel = genAI.getGenerativeModel({ model: model });
      const result = await genModel.generateContent(prompt);
      return result.response.text();
    } else {
      throw new Error(`Unsupported model: ${model}`);
    }
  } catch (error: any) {
    console.error('AI completion error:', error);
    throw new Error(`Failed to generate completion: ${error.message}`);
  }
}
'@

$aiCompletion | Out-File -FilePath "web/lib/ai/completion.ts" -Encoding UTF8

# Generate AI chat generator
$aiChat = @'
import OpenAI from 'openai';
import Anthropic from '@anthropic-ai/sdk';
import { GoogleGenerativeAI } from '@google/generative-ai';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_GEMINI_API_KEY!);

export async function generateChatResponse(
  messages: Array<{ role: string; content: string }>,
  model: string
): Promise<string> {
  const systemPrompt = `You are an expert programming assistant. Help users with coding questions, debugging, code explanations, and best practices. Be concise, accurate, and helpful.`;

  try {
    if (model.startsWith('gpt-')) {
      const response = await openai.chat.completions.create({
        model: model,
        messages: [
          { role: 'system', content: systemPrompt },
          ...messages.map((msg) => ({
            role: msg.role === 'user' ? 'user' : 'assistant',
            content: msg.content,
          })),
        ],
        max_tokens: 2000,
        temperature: 0.7,
      });
      return response.choices[0]?.message?.content || '';
    } else if (model.startsWith('claude-')) {
      const response = await anthropic.messages.create({
        model: model,
        max_tokens: 2000,
        system: systemPrompt,
        messages: messages.map((msg) => ({
          role: msg.role === 'user' ? 'user' : 'assistant',
          content: msg.content,
        })),
      });
      return response.content[0].type === 'text' ? response.content[0].text : '';
    } else if (model.startsWith('gemini-')) {
      const genModel = genAI.getGenerativeModel({ model: model });
      const chat = genModel.startChat({
        history: messages.slice(0, -1).map((msg) => ({
          role: msg.role === 'user' ? 'user' : 'model',
          parts: [{ text: msg.content }],
        })),
      });
      const result = await chat.sendMessage(messages[messages.length - 1].content);
      return result.response.text();
    } else {
      throw new Error(`Unsupported model: ${model}`);
    }
  } catch (error: any) {
    console.error('AI chat error:', error);
    throw new Error(`Failed to generate chat response: ${error.message}`);
  }
}
'@

$aiChat | Out-File -FilePath "web/lib/ai/chat.ts" -Encoding UTF8
Write-Host "✅ Created AI services" -ForegroundColor Green

# Generate projects API
$projectsApi = @'
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
      `SELECT id, name, description, language, is_public, created_at, updated_at, last_executed_at
       FROM projects
       WHERE user_id = :userId
       ORDER BY updated_at DESC`,
      { userId }
    );

    await connection.close();

    const projects = (result.rows || []).map((row: any[]) => ({
      id: row[0],
      name: row[1],
      description: row[2],
      language: row[3],
      isPublic: row[4] === 1,
      createdAt: row[5]?.toISOString() || new Date().toISOString(),
      updatedAt: row[6]?.toISOString() || new Date().toISOString(),
      lastExecutedAt: row[7]?.toISOString() || null,
    }));

    return NextResponse.json(projects);
  } catch (error) {
    console.error('Failed to fetch projects:', error);
    return NextResponse.json(
      { error: 'Failed to fetch projects' },
      { status: 500 }
    );
  }
}

export async function POST(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { name, description, language, isPublic } = await req.json();

    if (!name || !language) {
      return NextResponse.json(
        { error: 'Name and language are required' },
        { status: 400 }
      );
    }

    const connection = await getDbConnection();
    const projectId = `proj_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    await connection.execute(
      `INSERT INTO projects (id, user_id, name, description, language, is_public)
       VALUES (:id, :userId, :name, :description, :language, :isPublic)`,
      {
        id: projectId,
        userId,
        name,
        description: description || null,
        language,
        isPublic: isPublic ? 1 : 0,
      }
    );

    await connection.commit();
    await connection.close();

    return NextResponse.json({ id: projectId, name, description, language, isPublic });
  } catch (error) {
    console.error('Failed to create project:', error);
    return NextResponse.json(
      { error: 'Failed to create project' },
      { status: 500 }
    );
  }
}
'@

$projectsApi | Out-File -FilePath "web/app/api/projects/route.ts" -Encoding UTF8
Write-Host "✅ Created projects API" -ForegroundColor Green

Write-Host "`n✅ Part 5: Backend & AI Services Complete!" -ForegroundColor Green
Write-Host "Next: Run .\part6-deployment.ps1" -ForegroundColor Yellow

