from abc import ABC, abstractmethod
from openai import AsyncOpenAI
from app.config.settings import get_settings


class BaseAgent(ABC):
    def __init__(self):
        settings = get_settings()
        self.client = AsyncOpenAI(api_key=settings.openai_api_key)
        self.model = settings.openai_model
        self.max_tokens = settings.openai_max_tokens
        self.temperature = settings.openai_temperature

    @abstractmethod
    async def run(self, **kwargs):
        ...

    async def _chat(self, messages: list[dict], temperature: float = None,
                    max_tokens: int = None, json_mode: bool = False):
        kwargs = {
            "model": self.model,
            "messages": messages,
            "max_tokens": max_tokens or self.max_tokens,
            "temperature": temperature or self.temperature,
        }
        if json_mode:
            kwargs["response_format"] = {"type": "json_object"}
        return await self.client.chat.completions.create(**kwargs)

    async def _chat_with_tools(self, messages: list[dict], tools: list[dict],
                                tool_choice: str = "auto"):
        return await self.client.chat.completions.create(
            model=self.model,
            messages=messages,
            tools=tools,
            tool_choice=tool_choice,
            max_tokens=self.max_tokens,
            temperature=self.temperature,
        )
