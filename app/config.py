from pydantic_settings import BaseSettings
from pydantic import ConfigDict
from typing import Optional


class Settings(BaseSettings):
    model_config = ConfigDict(env_file=".env")
    
    database_url: str
    openai_api_key: str
    environment: str = "development"


settings = Settings()