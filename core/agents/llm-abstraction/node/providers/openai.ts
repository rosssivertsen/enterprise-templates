import type { LLMProvider } from '../llm-client.js';

export class OpenAIProvider implements LLMProvider {
  constructor(private model: string, private apiKey: string) {}

  async complete(prompt: string, system?: string): Promise<string> {
    let OpenAI;
    try {
      OpenAI = (await import('openai')).default;
    } catch {
      throw new Error('Install openai: npm install openai');
    }
    const client = new OpenAI({ apiKey: this.apiKey });
    const messages: any[] = [];
    if (system) messages.push({ role: 'system', content: system });
    messages.push({ role: 'user', content: prompt });
    const response = await client.chat.completions.create({ model: this.model, messages });
    return response.choices[0].message.content || '';
  }
}
