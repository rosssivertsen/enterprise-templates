"""Base provider interface."""
from abc import ABC, abstractmethod


class BaseLLMProvider(ABC):
    def __init__(self, model: str, api_key: str = None):
        self.model = model
        self.api_key = api_key

    @abstractmethod
    def complete(self, prompt: str, system: str = "") -> str:
        """Send a prompt to the LLM and return the response text."""
        pass

    def __repr__(self):
        return f"{self.__class__.__name__}(model={self.model!r})"
