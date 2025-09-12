from pydantic import BaseModel
from typing import List, Optional
from app.models import Sentiment


class AnalysisRequest(BaseModel):
    text: str


class AnalysisResponse(BaseModel):
    id: int
    title: Optional[str]
    topics: List[str]
    sentiment: Sentiment
    keywords: List[str]
    confidence_score: float
    created_at: str


class ErrorResponse(BaseModel):
    error: str