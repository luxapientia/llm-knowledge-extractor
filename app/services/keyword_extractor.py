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
        if not keywords or not text.strip():
            return 0.0

        doc = self.nlp(text)
        tokens = [token.lemma_.lower() for token in doc if token.is_alpha and len(token.text) > 2]

        if not tokens:
            return 0.0

        # Count actual keyword occurrences in tokens (not substrings)
        keyword_occurrences = sum(tokens.count(keyword.lower()) for keyword in keywords)

        # Base confidence: keyword density
        keyword_density = keyword_occurrences / len(tokens)

        # Bonus factors to improve confidence scoring:
        # 1. Multiple different keywords found (diversity bonus)
        unique_keywords_found = len([kw for kw in keywords if kw.lower() in tokens])
        diversity_bonus = unique_keywords_found / len(keywords)

        # 2. Repeated keyword usage (frequency bonus)
        frequency_bonus = min(keyword_occurrences / len(keywords), 1.0)

        # Combine factors: base density + bonuses, capped at 1.0
        confidence = keyword_density + (diversity_bonus * 0.3) + (frequency_bonus * 0.2)

        return min(confidence, 1.0)


keyword_extractor = KeywordExtractor()