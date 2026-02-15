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
