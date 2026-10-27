"""Anthropic (Claude) provider."""
from .base import BaseLLMProvider


class AnthropicProvider(BaseLLMProvider):
    def complete(self, prompt: str, system: str = "") -> str:
        try:
            import anthropic
        except ImportError:
            raise ImportError("Install anthropic: pip install anthropic")

        client = anthropic.Anthropic(api_key=self.api_key)
        messages = [{"role": "user", "content": prompt}]
        # Current Claude models think before answering, so leave room for both.
        kwargs = {"model": self.model, "max_tokens": 16000, "messages": messages}
        if system:
            kwargs["system"] = system
        response = client.messages.create(**kwargs)
        if response.stop_reason == "refusal":
            raise RuntimeError(f"Model declined the request: {response.stop_details}")
        # The response can start with a thinking block; return the text blocks only.
        text = "".join(b.text for b in response.content if b.type == "text")
        if not text:
            raise RuntimeError(f"No text in response (stop_reason={response.stop_reason})")
        return text
