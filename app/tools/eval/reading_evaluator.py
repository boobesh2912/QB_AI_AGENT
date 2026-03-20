import json
from difflib import SequenceMatcher
from openai import AsyncOpenAI
from app.config.settings import get_settings
from app.agents.prompts import READING_TOOL_PROMPT
from app.schemas.eval_schemas import ReadingEvalResult

settings = get_settings()
_client = AsyncOpenAI(api_key=settings.openai_api_key)
MIN_WPM, MAX_WPM = 130, 170


async def evaluate_reading(original: str, transcribed: str, duration: float) -> ReadingEvalResult:
    word_count = len(transcribed.split())
    duration_minutes = max(duration / 60, 0.001)
    wpm = round(word_count / duration_minutes, 2)
    accuracy = round(SequenceMatcher(None, original.lower(), transcribed.lower()).ratio() * 100, 2)

    prompt = READING_TOOL_PROMPT.format(original=original, transcribed=transcribed,
                                        wpm=wpm, min_wpm=MIN_WPM, max_wpm=MAX_WPM)
    response = await _client.chat.completions.create(
        model=settings.openai_model,
        messages=[
            {"role": "system", "content": 'You are a reading expert. Return valid JSON only. classification must be "Good", "Average", or "Bad".'},
            {"role": "user", "content": prompt},
        ],
        max_tokens=800,
        temperature=0.2,
        response_format={"type": "json_object"},
    )
    data = json.loads(response.choices[0].message.content or "{}")
    data["reading_speed_wpm"] = wpm
    data["accuracy_score"] = accuracy
    return ReadingEvalResult(**data)
