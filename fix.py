# fix.py - fix overall_summary to return plain text

agent_content = """import json
import asyncio
from app.agents.base_agent import BaseAgent
from app.agents.prompts import EVALUATION_AGENT_SYSTEM_PROMPT
from app.tools.eval.grammar_evaluator import evaluate_grammar
from app.tools.eval.pronunciation_evaluator import evaluate_pronunciation
from app.tools.eval.reading_evaluator import evaluate_reading
from app.tools.eval.vocabulary_analyzer import analyze_vocabulary
from app.tools.eval.structure_validator import validate_structure
from app.schemas.eval_schemas import EvaluationResponse


class EvaluationAgent(BaseAgent):
    async def run(self, original_text: str, candidate_text: str,
                  evaluation_types: list, audio_duration_seconds: float = None) -> EvaluationResponse:

        tasks = {}
        if "grammar" in evaluation_types:
            tasks["grammar"] = evaluate_grammar(original=original_text, candidate=candidate_text)
        if "pronunciation" in evaluation_types:
            tasks["pronunciation"] = evaluate_pronunciation(
                original=original_text, transcribed=candidate_text, duration=audio_duration_seconds or 0.0)
        if "reading" in evaluation_types:
            tasks["reading"] = evaluate_reading(
                original=original_text, transcribed=candidate_text, duration=audio_duration_seconds or 0.0)
        if "vocabulary" in evaluation_types:
            tasks["vocabulary"] = analyze_vocabulary(text=candidate_text)
        if "structure" in evaluation_types:
            tasks["structure"] = validate_structure(text=candidate_text)

        keys = list(tasks.keys())
        results = await asyncio.gather(*tasks.values(), return_exceptions=True)

        result_map = {}
        for key, result in zip(keys, results):
            result_map[key] = None if isinstance(result, Exception) else result

        summary = await self._generate_summary(result_map)

        return EvaluationResponse(
            grammar=result_map.get("grammar"),
            pronunciation=result_map.get("pronunciation"),
            reading=result_map.get("reading"),
            vocabulary=result_map.get("vocabulary"),
            structure=result_map.get("structure"),
            overall_summary=summary,
        )

    async def _generate_summary(self, results: dict) -> str:
        serializable = {
            k: (v.model_dump() if hasattr(v, "model_dump") else str(v))
            for k, v in results.items() if v is not None
        }
        response = await self._chat(
            messages=[
                {
                    "role": "system",
                    "content": (
                        "You are an English language assessment expert. "
                        "Write a plain text summary only. "
                        "Do NOT return JSON. Do NOT use curly braces. "
                        "Write 2-3 sentences as normal English text."
                    )
                },
                {
                    "role": "user",
                    "content": (
                        f"Results:\\n{json.dumps(serializable, indent=2)}\\n\\n"
                        "Write a 2-3 sentence overall assessment in plain English. "
                        "No JSON, no brackets, just plain sentences."
                    )
                },
            ],
            temperature=0.3,
        )
        content = response.choices[0].message.content or "Evaluation completed."
        # Strip JSON if LLM still returns it
        content = content.strip()
        if content.startswith("{"):
            try:
                parsed = json.loads(content)
                for key in ["overall_assessment", "summary", "assessment"]:
                    if key in parsed:
                        return parsed[key]
            except Exception:
                pass
        return content
"""

with open("app/agents/eval_agent.py", "w", encoding="utf-8", newline="\n") as f:
    f.write(agent_content)
print("eval_agent.py fixed - summary will now return plain text")