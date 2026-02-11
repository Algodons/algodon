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
