import type { LLMProvider } from '../llm-client.js';

export class OllamaProvider implements LLMProvider {
  private baseUrl: string;
  constructor(private model: string, baseUrl: string = 'http://localhost:11434') {
    this.baseUrl = baseUrl;
  }

  async complete(prompt: string, system?: string): Promise<string> {
    const payload: any = { model: this.model, prompt, stream: false };
    if (system) payload.system = system;
    const response = await fetch(`${this.baseUrl}/api/generate`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const result = await response.json();
    return result.response || '';
  }
}
