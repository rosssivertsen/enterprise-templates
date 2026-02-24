"""Ollama (local) provider."""
import json
import urllib.request
from .base import BaseLLMProvider


class OllamaProvider(BaseLLMProvider):
    def __init__(self, model: str, base_url: str = "http://localhost:11434"):
        super().__init__(model=model)
        self.base_url = base_url

    def complete(self, prompt: str, system: str = "") -> str:
        payload = {"model": self.model, "prompt": prompt, "stream": False}
        if system:
            payload["system"] = system
        data = json.dumps(payload).encode()
        req = urllib.request.Request(
            f"{self.base_url}/api/generate",
            data=data,
            headers={"Content-Type": "application/json"},
        )
        with urllib.request.urlopen(req) as resp:
            result = json.loads(resp.read())
        return result.get("response", "")
