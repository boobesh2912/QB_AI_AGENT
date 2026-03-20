import json
from openai import AsyncOpenAI
from app.config.settings import get_settings
from app.agents.prompts import PRONUNCIATION_TOOL_PROMPT
from app.schemas.eval_schemas import PronunciationEvalResult

settings = get_settings()
_client = AsyncOpenAI(api_key=settings.openai_api_key)


async def evaluate_pronunciation(original: str, transcribed: str, duration: float) -> PronunciationEvalResult:
    original_words = set(w.lower().strip(".,!?") for w in original.split())
    transcribed_words = set(w.lower().strip(".,!?") for w in transcribed.split())
    likely_mispronounced = list(original_words - transcribed_words)[:10]

    prompt = PRONUNCIATION_TOOL_PROMPT.format(original=original, transcribed=transcribed, duration=duration)
    response = await _client.chat.completions.create(
        model=settings.openai_model,
        messages=[
            {"role": "system", "content": "You are a pronunciation expert. Return valid JSON only."},
            {"role": "user", "content": prompt},
        ],
        max_tokens=700,
        temperature=0.2,
        response_format={"type": "json_object"},
    )
    data = json.loads(response.choices[0].message.content or "{}")
    if not data.get("mispronounced_words"):
        data["mispronounced_words"] = likely_mispronounced
    return PronunciationEvalResult(**data)
