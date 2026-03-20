import json
from app.agents.base_agent import BaseAgent
from app.agents.prompts import QB_AGENT_SYSTEM_PROMPT
from app.tools.qb.grammar_generator import generate_grammar_questions
from app.tools.qb.passage_generator import generate_passage_with_questions
from app.schemas.qb_schemas import Question, QuestionOption

QB_TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "generate_grammar_questions",
            "description": "Generate grammar MCQ questions. Use when type=grammar.",
            "parameters": {
                "type": "object",
                "properties": {
                    "topic": {"type": "string"},
                    "difficulty": {"type": "string", "enum": ["beginner", "intermediate", "advanced"]},
                    "count": {"type": "integer", "minimum": 1, "maximum": 20},
                },
                "required": ["topic", "difficulty", "count"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "generate_passage_with_questions",
            "description": "Generate a reading passage and comprehension MCQs. Use when type=comprehension.",
            "parameters": {
                "type": "object",
                "properties": {
                    "topic": {"type": "string"},
                    "difficulty": {"type": "string", "enum": ["beginner", "intermediate", "advanced"]},
                    "count": {"type": "integer", "minimum": 1, "maximum": 20},
                },
                "required": ["topic", "difficulty", "count"],
            },
        },
    },
]

TOOL_REGISTRY = {
    "generate_grammar_questions": generate_grammar_questions,
    "generate_passage_with_questions": generate_passage_with_questions,
}


class QuestionBankAgent(BaseAgent):
    async def run(self, topic: str, difficulty: str, count: int, question_type: str) -> list[Question]:
        messages = [
            {"role": "system", "content": QB_AGENT_SYSTEM_PROMPT},
            {"role": "user", "content": f"Generate {count} {question_type} questions on '{topic}' at {difficulty} difficulty."},
        ]

        response = await self._chat_with_tools(messages, tools=QB_TOOLS)
        message = response.choices[0].message

        if message.tool_calls:
            tool_call = message.tool_calls[0]
            tool_name = tool_call.function.name
            tool_args = json.loads(tool_call.function.arguments)

            if tool_name not in TOOL_REGISTRY:
                raise ValueError(f"Unknown tool: {tool_name}")

            tool_result = await TOOL_REGISTRY[tool_name](**tool_args)

            messages.append(message)
            messages.append({
                "role": "tool",
                "tool_call_id": tool_call.id,
                "content": json.dumps({"questions": tool_result}),
            })

            final = await self._chat(messages, json_mode=True)
            raw = json.loads(final.choices[0].message.content or "{}")
        else:
            raw = json.loads(message.content or "{}")

        return self._parse_questions(raw.get("questions", []), topic, difficulty)

    def _parse_questions(self, raw: list[dict], topic: str, difficulty: str) -> list[Question]:
        questions = []
        for q in raw:
            try:
                q.setdefault("topic", topic)
                q.setdefault("difficulty", difficulty)
                q.setdefault("passage", None)
                if isinstance(q.get("options"), dict):
                    q["options"] = QuestionOption(**q["options"])
                questions.append(Question(**q))
            except Exception:
                continue
        return questions
