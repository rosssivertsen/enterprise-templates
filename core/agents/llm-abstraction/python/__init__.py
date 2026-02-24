"""LLM abstraction layer — provider-agnostic client."""
from .llm_client import get_client, get_agent_config, load_config

__all__ = ["get_client", "get_agent_config", "load_config"]
