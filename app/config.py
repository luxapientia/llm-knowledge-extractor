from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    database_url: str
    openai_api_key: str
    environment: str = "development"
    
    class Config:
        env_file = ".env"


settings = Settings()