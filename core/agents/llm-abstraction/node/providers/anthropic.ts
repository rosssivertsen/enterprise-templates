import type { LLMProvider } from '../llm-client.js';

export class AnthropicProvider implements LLMProvider {
  constructor(private model: string, private apiKey: string) {}

  async complete(prompt: string, system?: string): Promise<string> {
    let Anthropic;
    try {
      Anthropic = (await import('@anthropic-ai/sdk')).default;
    } catch {
      throw new Error('Install @anthropic-ai/sdk: npm install @anthropic-ai/sdk');
    }
    const client = new Anthropic({ apiKey: this.apiKey });
    const params: any = {
      model: this.model,
      max_tokens: 4096,
      messages: [{ role: 'user', content: prompt }],
    };
    if (system) params.system = system;
    const response = await client.messages.create(params);
    return (response.content[0] as any).text;
  }
}
