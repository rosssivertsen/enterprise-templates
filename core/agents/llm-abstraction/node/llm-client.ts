import { readFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';

export interface LLMConfig {
  provider: string;
  model: string;
  apiKeyEnv: string;
}

export interface LLMProvider {
  complete(prompt: string, system?: string): Promise<string>;
}

export function loadConfig(configPath?: string): Record<string, any> {
  const path = configPath || join(process.cwd(), '.enterprise.yml');
  if (!existsSync(path)) {
    throw new Error(`.enterprise.yml not found at ${path}`);
  }
  // Simple YAML parsing for flat config
  const content = readFileSync(path, 'utf-8');
  const config: Record<string, any> = {};
  let section = '';
  let subsection = '';
  for (const line of content.split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    if (!line.startsWith(' ') && trimmed.endsWith(':')) {
      section = trimmed.slice(0, -1);
      config[section] = {};
      subsection = '';
    } else if (line.startsWith('  ') && !line.startsWith('    ') && trimmed.endsWith(':')) {
      subsection = trimmed.slice(0, -1);
      config[section][subsection] = {};
    } else if (trimmed.includes(':')) {
      const [key, ...rest] = trimmed.split(':');
      let value: any = rest.join(':').trim().replace(/^["']|["']$/g, '');
      if (value === 'true') value = true;
      else if (value === 'false') value = false;
      else if (/^\d+$/.test(value)) value = parseInt(value, 10);
      if (subsection && section) {
        config[section][subsection][key.trim()] = value;
      } else if (section) {
        config[section][key.trim()] = value;
      }
    }
  }
  return config;
}

export function getAgentConfig(role: string = 'default', configPath?: string): LLMConfig {
  const config = loadConfig(configPath);
  const agents = config.agents || {};
  const roleConfig = role !== 'default' && agents[role] ? agents[role] : agents.default || {};
  return {
    provider: roleConfig.provider || 'anthropic',
    model: roleConfig.model || 'claude-sonnet-4-20250514',
    apiKeyEnv: roleConfig.api_key_env || 'LLM_API_KEY',
  };
}

export async function getClient(role: string = 'default', configPath?: string): Promise<LLMProvider> {
  const config = getAgentConfig(role, configPath);
  const apiKey = config.apiKeyEnv ? process.env[config.apiKeyEnv] || '' : '';

  switch (config.provider) {
    case 'anthropic': {
      const { AnthropicProvider } = await import('./providers/anthropic.js');
      return new AnthropicProvider(config.model, apiKey);
    }
    case 'openai': {
      const { OpenAIProvider } = await import('./providers/openai.js');
      return new OpenAIProvider(config.model, apiKey);
    }
    case 'ollama': {
      const { OllamaProvider } = await import('./providers/ollama.js');
      return new OllamaProvider(config.model);
    }
    default:
      throw new Error(`Unknown LLM provider: ${config.provider}. Supported: anthropic, openai, ollama`);
  }
}
