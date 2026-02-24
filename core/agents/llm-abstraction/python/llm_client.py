"""Provider-agnostic LLM client. Reads config from .enterprise.yml."""

import os
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None


def _parse_yaml_simple(path: str) -> dict:
    """Minimal YAML parser for .enterprise.yml when PyYAML is not installed."""
    config = {}
    current_section = None
    current_subsection = None
    with open(path) as f:
        for line in f:
            stripped = line.strip()
            if not stripped or stripped.startswith("#"):
                continue
            if not line.startswith(" ") and stripped.endswith(":"):
                current_section = stripped[:-1]
                config[current_section] = {}
                current_subsection = None
            elif line.startswith("  ") and not line.startswith("    ") and stripped.endswith(":"):
                current_subsection = stripped[:-1]
                if current_section:
                    config[current_section][current_subsection] = {}
            elif ":" in stripped and current_section:
                key, _, value = stripped.partition(":")
                value = value.strip().strip('"').strip("'")
                if value.lower() == "true":
                    value = True
                elif value.lower() == "false":
                    value = False
                elif value.isdigit():
                    value = int(value)
                if current_subsection and current_section:
                    config[current_section].get(current_subsection, {})[key.strip()] = value
                elif current_section:
                    config[current_section][key.strip()] = value
    return config


def load_config(config_path: str = None) -> dict:
    """Load .enterprise.yml configuration."""
    if config_path is None:
        config_path = str(Path.cwd() / ".enterprise.yml")
    if not Path(config_path).exists():
        raise FileNotFoundError(f".enterprise.yml not found at {config_path}")
    if yaml:
        with open(config_path) as f:
            return yaml.safe_load(f)
    return _parse_yaml_simple(config_path)


def get_agent_config(role: str = "default", config_path: str = None) -> dict:
    """Get LLM config for a specific agent role."""
    config = load_config(config_path)
    agents = config.get("agents", {})
    if role != "default" and role in agents:
        return agents[role]
    return agents.get("default", {})


def get_client(role: str = "default", config_path: str = None):
    """Return an LLM client configured for the specified agent role."""
    agent_config = get_agent_config(role, config_path)
    provider = agent_config.get("provider", "anthropic")
    model = agent_config.get("model", "claude-sonnet-4-20250514")
    api_key_env = agent_config.get("api_key_env", "LLM_API_KEY")
    api_key = os.getenv(api_key_env, "") if api_key_env else None

    if provider == "anthropic":
        from .providers.anthropic_provider import AnthropicProvider
        return AnthropicProvider(model=model, api_key=api_key)
    elif provider == "openai":
        from .providers.openai_provider import OpenAIProvider
        return OpenAIProvider(model=model, api_key=api_key)
    elif provider == "ollama":
        from .providers.ollama_provider import OllamaProvider
        return OllamaProvider(model=model)
    else:
        raise ValueError(f"Unknown LLM provider: {provider}. Supported: anthropic, openai, ollama")
