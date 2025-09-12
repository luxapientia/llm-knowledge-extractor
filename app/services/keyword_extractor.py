import spacy
from typing import List, Tuple
from collections import Counter


class KeywordExtractor:
    def __init__(self):
        self.nlp = spacy.load("en_core_web_sm")
    
    def extract_keywords(self, text: str) -> List[str]:
        doc = self.nlp(text)
        nouns = [token.lemma_.lower() for token in doc if token.pos_ == "NOUN" and len(token.text) > 2]
        noun_counts = Counter(nouns)
        return [noun for noun, _ in noun_counts.most_common(3)]
    
    def calculate_confidence(self, text: str, keywords: List[str]) -> float:
        doc = self.nlp(text)
        total_words = len([token for token in doc if token.is_alpha])
        keyword_occurrences = sum(text.lower().count(keyword.lower()) for keyword in keywords)
        return min(keyword_occurrences / total_words if total_words > 0 else 0, 1.0)


keyword_extractor = KeywordExtractor()