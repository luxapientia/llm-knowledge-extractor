from typing import Dict, Any
from app.services.openai_service import openai_service
from app.services.keyword_extractor import keyword_extractor
from app.models import Sentiment


class AnalysisService:
    def analyze_text(self, text: str) -> Dict[str, Any]:
        if not text.strip():
            raise ValueError("Empty input")

        try:
            llm_result = openai_service.analyze_text(text)
        except Exception as e:
            raise Exception("LLM request failed")

        keywords = keyword_extractor.extract_keywords(text)
        confidence_score = keyword_extractor.calculate_confidence(text, keywords)

        return {
            "title": llm_result.get("title"),
            "topics": llm_result.get("topics", []),
            "sentiment": llm_result.get("sentiment", Sentiment.NEUTRAL),
            "keywords": keywords,
            "confidence_score": confidence_score,
            "raw_text": text
        }


analysis_service = AnalysisService()