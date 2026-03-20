import json
from openai import AsyncOpenAI
from app.config.settings import get_settings
from app.agents.prompts import GRAMMAR_QUESTION_TOOL_PROMPT

settings = get_settings()
_client = AsyncOpenAI(api_key=settings.openai_api_key)


async def generate_grammar_questions(topic: str, difficulty: str, count: int) -> list[dict]:
    prompt = GRAMMAR_QUESTION_TOOL_PROMPT.format(topic=topic, difficulty=difficulty, count=count)
    response = await _client.chat.completions.create(
        model=settings.openai_model,
        messages=[
            {"role": "system", "content": "You are an expert grammar question writer. Return valid JSON only."},
            {"role": "user", "content": prompt},
        ],
        max_tokens=settings.openai_max_tokens,
        temperature=0.5,
        response_format={"type": "json_object"},
    )
    data = json.loads(response.choices[0].message.content or "{}")
    questions = data.get("questions", [])
    for q in questions:
        q.setdefault("topic", topic)
        q.setdefault("difficulty", difficulty)
        q.setdefault("passage", None)
    return questions
