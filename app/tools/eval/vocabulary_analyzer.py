import json
from openai import AsyncOpenAI
from app.config.settings import get_settings
from app.agents.prompts import VOCABULARY_TOOL_PROMPT
from app.schemas.eval_schemas import VocabularyAnalysisResult

settings = get_settings()
_client = AsyncOpenAI(api_key=settings.openai_api_key)


async def analyze_vocabulary(text: str) -> VocabularyAnalysisResult:
    words = text.lower().split()
    unique_words = set(w.strip(".,!?;:") for w in words)
    ttr = round(len(unique_words) / max(len(words), 1), 4)

    prompt = VOCABULARY_TOOL_PROMPT.format(text=text, ttr=ttr)
    response = await _client.chat.completions.create(
        model=settings.openai_model,
        messages=[
            {"role": "system", "content": 'You are a vocabulary expert. Return valid JSON only. vocabulary_level must be "Basic", "Intermediate", or "Advanced".'},
            {"role": "user", "content": prompt},
        ],
        max_tokens=800,
        temperature=0.3,
        response_format={"type": "json_object"},
    )
    data = json.loads(response.choices[0].message.content or "{}")
    data["unique_word_ratio"] = ttr
    return VocabularyAnalysisResult(**data)
