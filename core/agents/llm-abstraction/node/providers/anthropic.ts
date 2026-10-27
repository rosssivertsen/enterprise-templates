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
    // Current Claude models think before answering, so leave room for both.
    const params: any = {
      model: this.model,
      max_tokens: 16000,
      messages: [{ role: 'user', content: prompt }],
    };
    if (system) params.system = system;
    const response = await client.messages.create(params);
    if (response.stop_reason === 'refusal') {
      throw new Error(`Model declined the request: ${JSON.stringify((response as any).stop_details)}`);
    }
    // The response can start with a thinking block; return the text blocks only.
    const text = response.content
      .filter((b: any) => b.type === 'text')
      .map((b: any) => b.text)
      .join('');
    if (!text) throw new Error(`No text in response (stop_reason=${response.stop_reason})`);
    return text;
  }
}
