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
