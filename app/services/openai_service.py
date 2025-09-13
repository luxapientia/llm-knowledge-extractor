import openai
from typing import Dict, Any, Optional
from app.config import settings
from app.models import Sentiment


class OpenAIService:
    def __init__(self):
        openai.api_key = settings.openai_api_key
        self.client = openai.OpenAI(api_key=settings.openai_api_key)

    def analyze_text(self, text: str) -> Dict[str, Any]:
        try:
            response = self.client.chat.completions.create(
                model="gpt-4.1",
                messages=[
                    {
                        "role": "system",
                        "content": "You are a text analysis expert. Extract structured data from the given text."
                    },
                    {
                        "role": "user",
                        "content": f"Analyze this text and extract: title (if available), exactly 3 topics, and sentiment (positive/neutral/negative):\n\n{text}"
                    }
                ],
                functions=[
                    {
                        "name": "extract_analysis",
                        "description": "Extract structured analysis from text",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "title": {
                                    "type": "string",
                                    "description": "Concise title of the text. If none is obvious, generate a short descriptive headline."
                                },
                                "topics": {
                                    "type": "array",
                                    "items": {"type": "string"},
                                    "minItems": 3,
                                    "maxItems": 3,
                                    "description": "Exactly 3 key topics from the text"
                                },
                                "sentiment": {
                                    "type": "string",
                                    "enum": ["positive", "neutral", "negative"],
                                    "description": "Overall sentiment of the text"
                                }
                            },
                            "required": ["topics", "sentiment"]
                        }
                    }
                ],
                function_call={"name": "extract_analysis"}
            )

            function_call = response.choices[0].message.function_call
            if function_call and function_call.name == "extract_analysis":
                import json
                result = json.loads(function_call.arguments)
                return {
                    "title": result.get("title"),
                    "topics": result.get("topics", []),
                    "sentiment": Sentiment(result.get("sentiment", "neutral"))
                }

            raise Exception("No function call returned")

        except Exception as e:
            raise Exception(f"LLM request failed: {str(e)}")


openai_service = OpenAIService()