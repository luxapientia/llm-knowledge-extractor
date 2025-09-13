import pytest
from app.services.keyword_extractor import KeywordExtractor


class TestKeywordExtractor:
    def test_extract_keywords(self):
        """Test basic keyword extraction"""
        extractor = KeywordExtractor()
        text = "The product quality is excellent and the service is great."

        keywords = extractor.extract_keywords(text)

        assert isinstance(keywords, list)
        assert len(keywords) <= 3
        assert all(isinstance(keyword, str) for keyword in keywords)

    def test_calculate_confidence(self):
        """Test confidence calculation"""
        extractor = KeywordExtractor()
        text = "The product quality is excellent."
        keywords = ["product", "quality"]

        confidence = extractor.calculate_confidence(text, keywords)

        assert isinstance(confidence, float)
        assert 0.0 <= confidence <= 1.0