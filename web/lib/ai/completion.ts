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
