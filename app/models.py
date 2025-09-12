from sqlmodel import SQLModel, Field
from sqlalchemy import Column, JSON
from typing import List, Optional
from enum import Enum
from datetime import datetime


class Sentiment(str, Enum):
    POSITIVE = "positive"
    NEUTRAL = "neutral"
    NEGATIVE = "negative"


class AnalysisResult(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    title: Optional[str] = Field(default=None)
    topics: List[str] = Field(default_factory=list, sa_column=Column(JSON))
    sentiment: Sentiment
    keywords: List[str] = Field(default_factory=list, sa_column=Column(JSON))
    confidence_score: float = Field(default=0.0)
    raw_text: str
    created_at: datetime = Field(default_factory=datetime.utcnow)