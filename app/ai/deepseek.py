"""DeepSeek AI 客户端 - 支持流式输出"""
import httpx
import json
import asyncio
from typing import AsyncGenerator, Optional, List, Dict, Any

from app.config import settings


class DeepSeekClient:
    """DeepSeek V4 Pro API 客户端"""

    def __init__(self):
        self.api_key = settings.DEEPSEEK_API_KEY
        self.base_url = settings.DEEPSEEK_BASE_URL
        self.model = settings.DEEPSEEK_MODEL
        self.client = httpx.AsyncClient(
            base_url=self.base_url,
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json",
            },
            timeout=httpx.Timeout(120.0, connect=10.0),
        )

    async def chat(
        self,
        messages: List[Dict[str, str]],
        temperature: float = 0.7,
        max_tokens: int = 4096,
    ) -> str:
        """同步对话"""
        response = await self.client.post(
            "/v1/chat/completions",
            json={
                "model": self.model,
                "messages": messages,
                "temperature": temperature,
                "max_tokens": max_tokens,
            },
        )
        response.raise_for_status()
        data = response.json()
        return data["choices"][0]["message"]["content"]

    async def chat_stream(
        self,
        messages: List[Dict[str, str]],
        temperature: float = 0.7,
        max_tokens: int = 4096,
    ) -> AsyncGenerator[str, None]:
        """流式对话 - SSE 输出"""
        async with self.client.stream(
            "POST",
            "/v1/chat/completions",
            json={
                "model": self.model,
                "messages": messages,
                "temperature": temperature,
                "max_tokens": max_tokens,
                "stream": True,
            },
        ) as response:
            response.raise_for_status()
            async for line in response.aiter_lines():
                if line.startswith("data: "):
                    data_str = line[6:]
                    if data_str.strip() == "[DONE]":
                        break
                    try:
                        data = json.loads(data_str)
                        delta = data["choices"][0].get("delta", {})
                        content = delta.get("content", "")
                        if content:
                            yield content
                    except json.JSONDecodeError:
                        continue

    async def fortune_analysis(
        self,
        system_prompt: str,
        user_question: str,
        birth_info: str,
        stream: bool = False,
    ) -> Any:
        """命理分析专用接口"""
        messages = [
            {"role": "system", "content": system_prompt},
            {
                "role": "user",
                "content": f"命主信息：{birth_info}\n\n问题：{user_question}",
            },
        ]

        if stream:
            return self.chat_stream(messages)
        return await self.chat(messages)

    async def close(self):
        """关闭客户端"""
        await self.client.aclose()


# 全局单例
deepseek_client = DeepSeekClient()
