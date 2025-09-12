import pytest
from app.services.keyword_extractor import KeywordExtractor


class TestKeywordExtractor:
    def test_extract_keywords(self):
        extractor = KeywordExtractor()
        text = "The quick brown fox jumps over the lazy dog. The fox is very clever and smart."
        
        keywords = extractor.extract_keywords(text)
        
        assert len(keywords) <= 3
        assert all(isinstance(keyword, str) for keyword in keywords)
        assert "fox" in keywords  # Most frequent noun
    
    def test_extract_keywords_empty_text(self):
        extractor = KeywordExtractor()
        text = ""
        
        keywords = extractor.extract_keywords(text)
        
        assert keywords == []
    
    def test_extract_keywords_short_text(self):
        extractor = KeywordExtractor()
        text = "Hello world."
        
        keywords = extractor.extract_keywords(text)
        
        assert len(keywords) <= 3
        assert "world" in keywords
    
    def test_calculate_confidence(self):
        extractor = KeywordExtractor()
        text = "The fox is a clever animal. The fox runs fast."
        keywords = ["fox"]
        
        confidence = extractor.calculate_confidence(text, keywords)
        
        assert 0.0 <= confidence <= 1.0
        assert confidence > 0.0  # Should have some confidence since "fox" appears twice
    
    def test_calculate_confidence_no_keywords(self):
        extractor = KeywordExtractor()
        text = "The quick brown fox jumps over the lazy dog."
        keywords = []
        
        confidence = extractor.calculate_confidence(text, keywords)
        
        assert confidence == 0.0