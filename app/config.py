from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    """应用配置"""

    # 应用
    APP_NAME: str = "Fortune AI"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    # DeepSeek API
    DEEPSEEK_API_KEY: str = "sk-f6badb5d14214b81afd4c3094685cb1f"
    DEEPSEEK_BASE_URL: str = "https://api.deepseek.com"
    DEEPSEEK_MODEL: str = "deepseek-chat"

    # CORS
    CORS_ORIGINS: str = "*"

    # 数据库
    DATABASE_URL: str = "sqlite:///./fortune_ai.db"

    # Redis
    REDIS_URL: str = "redis://localhost:6379"

    model_config = {"env_file": ".env", "extra": "ignore"}


settings = Settings()
