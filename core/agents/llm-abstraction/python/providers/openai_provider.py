"""OpenAI provider."""
from .base import BaseLLMProvider


class OpenAIProvider(BaseLLMProvider):
    def complete(self, prompt: str, system: str = "") -> str:
        try:
            from openai import OpenAI
        except ImportError:
            raise ImportError("Install openai: pip install openai")

        client = OpenAI(api_key=self.api_key)
        messages = []
        if system:
            messages.append({"role": "system", "content": system})
        messages.append({"role": "user", "content": prompt})
        response = client.chat.completions.create(model=self.model, messages=messages)
        return response.choices[0].message.content
