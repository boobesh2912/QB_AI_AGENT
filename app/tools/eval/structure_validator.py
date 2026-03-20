import json
from openai import AsyncOpenAI
from app.config.settings import get_settings
from app.agents.prompts import STRUCTURE_TOOL_PROMPT
from app.schemas.eval_schemas import StructureValidationResult

settings = get_settings()
_client = AsyncOpenAI(api_key=settings.openai_api_key)


async def validate_structure(text: str) -> StructureValidationResult:
    sentences = [s.strip() for s in text.split(".") if s.strip()]
    sentence_count = len(sentences)
    avg_len = round(sum(len(s.split()) for s in sentences) / max(sentence_count, 1), 1)

    prompt = STRUCTURE_TOOL_PROMPT.format(text=text, sentence_count=sentence_count, avg_len=avg_len)
    response = await _client.chat.completions.create(
        model=settings.openai_model,
        messages=[
            {"role": "system", "content": "You are a writing structure expert. Return valid JSON only. is_coherent must be boolean."},
            {"role": "user", "content": prompt},
        ],
        max_tokens=800,
        temperature=0.2,
        response_format={"type": "json_object"},
    )
    data = json.loads(response.choices[0].message.content or "{}")
    data["sentence_count"] = sentence_count
    data["avg_sentence_length"] = avg_len
    return StructureValidationResult(**data)
