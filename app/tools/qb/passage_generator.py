import json
from openai import AsyncOpenAI
from app.config.settings import get_settings
from app.agents.prompts import PASSAGE_TOOL_PROMPT

settings = get_settings()
_client = AsyncOpenAI(api_key=settings.openai_api_key)


async def generate_passage_with_questions(topic: str, difficulty: str, count: int) -> list[dict]:
    prompt = PASSAGE_TOOL_PROMPT.format(topic=topic, difficulty=difficulty, count=count)
    response = await _client.chat.completions.create(
        model=settings.openai_model,
        messages=[
            {"role": "system", "content": "You are an expert comprehension question writer. Return valid JSON only."},
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
        if not q.get("passage"):
            q["passage"] = f"[Passage generation failed for topic: {topic}]"
    return questions
