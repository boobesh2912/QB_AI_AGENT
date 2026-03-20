import json
from openai import AsyncOpenAI
from app.config.settings import get_settings
from app.agents.prompts import GRAMMAR_TOOL_PROMPT
from app.schemas.eval_schemas import GrammarEvalResult

settings = get_settings()
_client = AsyncOpenAI(api_key=settings.openai_api_key)


async def evaluate_grammar(original: str, candidate: str) -> GrammarEvalResult:
    prompt = GRAMMAR_TOOL_PROMPT.format(original=original, candidate=candidate)
    response = await _client.chat.completions.create(
        model=settings.openai_model,
        messages=[
            {"role": "system", "content": "You are a grammar expert. Return valid JSON only. accuracy_score must be float 0-100."},
            {"role": "user", "content": prompt},
        ],
        max_tokens=1000,
        temperature=0.2,
        response_format={"type": "json_object"},
    )
    data = json.loads(response.choices[0].message.content or "{}")
    return GrammarEvalResult(**data)
