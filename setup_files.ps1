# ============================================================
# Run this entire block in PowerShell inside question_bank_api/
# ============================================================

# ── app/db/models.py ────────────────────────────────────────
Set-Content -Path "app/db/models.py" -Encoding UTF8 -Value @'
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, JSON, CheckConstraint, Text
from app.db.database import Base


class GrammarQuestion(Base):
    __tablename__ = "grammar_questions"
    __table_args__ = (
        CheckConstraint("correct_answer IN (''a'',''b'',''c'',''d'')", name="ck_grammar_correct_answer"),
    )
    id = Column(Integer, primary_key=True, index=True)
    topic = Column(String(200), index=True, nullable=False)
    difficulty = Column(String(20), index=True, nullable=False)
    question = Column(Text, nullable=False)
    options = Column(JSON, nullable=False)
    correct_answer = Column(String(1), nullable=False)
    explanation = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)


class ComprehensionQuestion(Base):
    __tablename__ = "comprehension_questions"
    __table_args__ = (
        CheckConstraint("correct_answer IN (''a'',''b'',''c'',''d'')", name="ck_comprehension_correct_answer"),
    )
    id = Column(Integer, primary_key=True, index=True)
    topic = Column(String(200), index=True, nullable=False)
    difficulty = Column(String(20), index=True, nullable=False)
    passage = Column(Text, nullable=False)
    question = Column(Text, nullable=False)
    options = Column(JSON, nullable=False)
    correct_answer = Column(String(1), nullable=False)
    explanation = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
'@

# ── app/db/database.py ──────────────────────────────────────
Set-Content -Path "app/db/database.py" -Encoding UTF8 -Value @'
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from app.config.settings import get_settings

settings = get_settings()

engine = create_engine(
    settings.database_url,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20,
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
'@

# ── app/db/repository.py ────────────────────────────────────
Set-Content -Path "app/db/repository.py" -Encoding UTF8 -Value @'
from sqlalchemy.orm import Session
from app.db.models import GrammarQuestion, ComprehensionQuestion


class QuestionRepository:
    def __init__(self, db: Session):
        self.db = db

    def save_questions(self, questions: list[dict], question_type: str) -> int:
        model_class = GrammarQuestion if question_type == "grammar" else ComprehensionQuestion
        for q in questions:
            record = model_class(
                topic=q.get("topic", ""),
                difficulty=q.get("difficulty", ""),
                passage=q.get("passage"),
                question=q.get("question", ""),
                options=q.get("options", {}),
                correct_answer=q.get("correct_answer", "a"),
                explanation=q.get("explanation"),
            )
            self.db.add(record)
        self.db.commit()
        return len(questions)

    def get_by_topic(self, topic: str, question_type: str, limit: int = 20) -> list:
        model_class = GrammarQuestion if question_type == "grammar" else ComprehensionQuestion
        return (
            self.db.query(model_class)
            .filter(model_class.topic.ilike(f"%{topic}%"))
            .order_by(model_class.created_at.desc())
            .limit(limit)
            .all()
        )
'@

# ── app/config/settings.py ──────────────────────────────────
Set-Content -Path "app/config/settings.py" -Encoding UTF8 -Value @'
from pydantic_settings import BaseSettings, SettingsConfigDict
from functools import lru_cache


class Settings(BaseSettings):
    openai_api_key: str
    openai_model: str = "gpt-4o-mini"
    openai_max_tokens: int = 2000
    openai_temperature: float = 0.4
    database_url: str
    api_secret_key: str
    environment: str = "development"
    app_title: str = "Question Bank API"
    app_version: str = "1.0.0"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )


@lru_cache()
def get_settings() -> Settings:
    return Settings()
'@

# ── app/config/__init__.py ──────────────────────────────────
Set-Content -Path "app/config/__init__.py" -Encoding UTF8 -Value ""

# ── app/__init__.py ─────────────────────────────────────────
Set-Content -Path "app/__init__.py" -Encoding UTF8 -Value ""

# ── app/db/__init__.py ──────────────────────────────────────
Set-Content -Path "app/db/__init__.py" -Encoding UTF8 -Value ""

# ── app/schemas/__init__.py ─────────────────────────────────
Set-Content -Path "app/schemas/__init__.py" -Encoding UTF8 -Value ""

# ── app/services/__init__.py ────────────────────────────────
Set-Content -Path "app/services/__init__.py" -Encoding UTF8 -Value ""

# ── app/agents/__init__.py ──────────────────────────────────
Set-Content -Path "app/agents/__init__.py" -Encoding UTF8 -Value ""

# ── app/tools/__init__.py ───────────────────────────────────
Set-Content -Path "app/tools/__init__.py" -Encoding UTF8 -Value ""

# ── app/tools/qb/__init__.py ────────────────────────────────
Set-Content -Path "app/tools/qb/__init__.py" -Encoding UTF8 -Value ""

# ── app/tools/eval/__init__.py ──────────────────────────────
Set-Content -Path "app/tools/eval/__init__.py" -Encoding UTF8 -Value ""

# ── app/api/__init__.py ─────────────────────────────────────
Set-Content -Path "app/api/__init__.py" -Encoding UTF8 -Value ""

# ── app/api/v1/__init__.py ──────────────────────────────────
Set-Content -Path "app/api/v1/__init__.py" -Encoding UTF8 -Value ""

# ── app/api/v1/admin/__init__.py ────────────────────────────
Set-Content -Path "app/api/v1/admin/__init__.py" -Encoding UTF8 -Value ""

# ── app/api/v1/evaluation/__init__.py ───────────────────────
Set-Content -Path "app/api/v1/evaluation/__init__.py" -Encoding UTF8 -Value ""

# ── app/api/dependencies/__init__.py ────────────────────────
Set-Content -Path "app/api/dependencies/__init__.py" -Encoding UTF8 -Value ""

# ── .env ────────────────────────────────────────────────────
Set-Content -Path ".env" -Encoding UTF8 -Value @'
OPENAI_API_KEY=sk-your-key-here
OPENAI_MODEL=gpt-4o-mini
OPENAI_MAX_TOKENS=2000
OPENAI_TEMPERATURE=0.4
DATABASE_URL=postgresql://user:password@localhost:5432/qb_db
API_SECRET_KEY=mysecretkey123
ENVIRONMENT=development
'@

# ── app/schemas/qb_schemas.py ───────────────────────────────
Set-Content -Path "app/schemas/qb_schemas.py" -Encoding UTF8 -Value @'
from pydantic import BaseModel, Field
from typing import Literal, Optional


class GenerateQuestionsRequest(BaseModel):
    type: Literal["grammar", "comprehension"]
    topic: str = Field(..., min_length=2, max_length=200)
    difficulty: Literal["beginner", "intermediate", "advanced"]
    count: int = Field(default=5, ge=1, le=20)


class QuestionOption(BaseModel):
    a: str
    b: str
    c: str
    d: str


class Question(BaseModel):
    topic: str
    difficulty: str
    passage: Optional[str] = None
    question: str
    options: QuestionOption
    correct_answer: Literal["a", "b", "c", "d"]
    explanation: str


class GenerateQuestionsResponse(BaseModel):
    message: str
    type: str
    topic: str
    difficulty: str
    count: int
    questions: list[Question]
'@

# ── app/schemas/eval_schemas.py ─────────────────────────────
Set-Content -Path "app/schemas/eval_schemas.py" -Encoding UTF8 -Value @'
from pydantic import BaseModel, Field
from typing import Literal, Optional


class GrammarEvalResult(BaseModel):
    accuracy_score: float = Field(..., ge=0, le=100)
    error_count: int
    error_types: list[str]
    corrected_text: str
    feedback: str


class PronunciationEvalResult(BaseModel):
    pronunciation_score: float = Field(..., ge=0, le=100)
    fluency_score: float = Field(..., ge=0, le=100)
    mispronounced_words: list[str]
    feedback: str


class ReadingEvalResult(BaseModel):
    reading_speed_wpm: float
    classification: Literal["Good", "Average", "Bad"]
    accuracy_score: float = Field(..., ge=0, le=100)
    overall_score: float = Field(..., ge=0, le=100)
    feedback: str
    recommendations: str


class VocabularyAnalysisResult(BaseModel):
    richness_score: float = Field(..., ge=0, le=100)
    unique_word_ratio: float
    advanced_word_count: int
    common_word_count: int
    vocabulary_level: Literal["Basic", "Intermediate", "Advanced"]
    suggestions: list[str]


class StructureValidationResult(BaseModel):
    structure_score: float = Field(..., ge=0, le=100)
    sentence_count: int
    avg_sentence_length: float
    issues: list[str]
    is_coherent: bool
    feedback: str


class EvaluationRequest(BaseModel):
    original_text: str = Field(..., min_length=10)
    candidate_text: str = Field(..., min_length=1)
    audio_duration_seconds: Optional[float] = None
    evaluation_types: list[
        Literal["grammar", "pronunciation", "reading", "vocabulary", "structure"]
    ] = Field(default=["grammar"])


class EvaluationResponse(BaseModel):
    grammar: Optional[GrammarEvalResult] = None
    pronunciation: Optional[PronunciationEvalResult] = None
    reading: Optional[ReadingEvalResult] = None
    vocabulary: Optional[VocabularyAnalysisResult] = None
    structure: Optional[StructureValidationResult] = None
    overall_summary: str
'@

# ── app/agents/prompts.py ───────────────────────────────────
Set-Content -Path "app/agents/prompts.py" -Encoding UTF8 -Value @'
QB_AGENT_SYSTEM_PROMPT = """You are an expert English language question bank generator.
Generate high-quality MCQ questions. Return ONLY valid JSON.

Format:
{
  "questions": [
    {
      "topic": "string",
      "difficulty": "string",
      "passage": null,
      "question": "string",
      "options": {"a": "string", "b": "string", "c": "string", "d": "string"},
      "correct_answer": "a|b|c|d",
      "explanation": "string"
    }
  ]
}

TOOL ROUTING:
- type=grammar       -> call generate_grammar_questions ONCE
- type=comprehension -> call generate_passage_with_questions ONCE
- Never call a tool more than once
- No markdown, no preamble, return JSON only
"""

EVALUATION_AGENT_SYSTEM_PROMPT = """You are an expert English language assessment evaluator.
Evaluate candidate text and provide structured feedback.
Always respond with valid JSON only.
"""

GRAMMAR_QUESTION_TOOL_PROMPT = """Generate {count} grammar MCQ questions.
Topic: {topic}
Difficulty: {difficulty}

Return ONLY valid JSON:
{{
  "questions": [
    {{
      "topic": "{topic}",
      "difficulty": "{difficulty}",
      "passage": null,
      "question": "string",
      "options": {{"a": "string", "b": "string", "c": "string", "d": "string"}},
      "correct_answer": "a|b|c|d",
      "explanation": "string"
    }}
  ]
}}
"""

PASSAGE_TOOL_PROMPT = """Generate one reading passage (120-180 words) and {count} MCQ questions based on it.
Topic: {topic}
Difficulty: {difficulty}

Return ONLY valid JSON:
{{
  "questions": [
    {{
      "topic": "{topic}",
      "difficulty": "{difficulty}",
      "passage": "full passage text here",
      "question": "string",
      "options": {{"a": "string", "b": "string", "c": "string", "d": "string"}},
      "correct_answer": "a|b|c|d",
      "explanation": "string"
    }}
  ]
}}
"""

GRAMMAR_TOOL_PROMPT = """Compare candidate text against original for grammar errors.
Original:  {original}
Candidate: {candidate}

Return ONLY valid JSON:
{{
  "accuracy_score": 0.0,
  "error_count": 0,
  "error_types": [],
  "corrected_text": "string",
  "feedback": "string"
}}
"""

READING_TOOL_PROMPT = """Evaluate reading performance.
Original: {original}
Transcribed: {transcribed}
WPM: {wpm}
Expected range: {min_wpm}-{max_wpm}

Classify as Good (WPM in range AND accuracy>=85%), Average (70-84%), Bad (<70% or far outside range).

Return ONLY valid JSON:
{{
  "classification": "Good|Average|Bad",
  "overall_score": 0.0,
  "feedback": "string",
  "recommendations": "string"
}}
"""

VOCABULARY_TOOL_PROMPT = """Analyze vocabulary richness.
Text: {text}
Pre-calculated TTR: {ttr}

Return ONLY valid JSON:
{{
  "richness_score": 0.0,
  "unique_word_ratio": {ttr},
  "advanced_word_count": 0,
  "common_word_count": 0,
  "vocabulary_level": "Basic|Intermediate|Advanced",
  "suggestions": []
}}
"""

STRUCTURE_TOOL_PROMPT = """Validate sentence and paragraph structure.
Text: {text}
Sentence count: {sentence_count}
Avg length: {avg_len}

Return ONLY valid JSON:
{{
  "structure_score": 0.0,
  "sentence_count": {sentence_count},
  "avg_sentence_length": {avg_len},
  "issues": [],
  "is_coherent": true,
  "feedback": "string"
}}
"""

PRONUNCIATION_TOOL_PROMPT = """Evaluate pronunciation from transcription differences.
Original: {original}
Transcribed: {transcribed}
Duration: {duration}s

Return ONLY valid JSON:
{{
  "pronunciation_score": 0.0,
  "fluency_score": 0.0,
  "mispronounced_words": [],
  "feedback": "string"
}}
"""
'@

# ── app/agents/base_agent.py ────────────────────────────────
Set-Content -Path "app/agents/base_agent.py" -Encoding UTF8 -Value @'
from abc import ABC, abstractmethod
from openai import AsyncOpenAI
from app.config.settings import get_settings


class BaseAgent(ABC):
    def __init__(self):
        settings = get_settings()
        self.client = AsyncOpenAI(api_key=settings.openai_api_key)
        self.model = settings.openai_model
        self.max_tokens = settings.openai_max_tokens
        self.temperature = settings.openai_temperature

    @abstractmethod
    async def run(self, **kwargs):
        ...

    async def _chat(self, messages: list[dict], temperature: float = None,
                    max_tokens: int = None, json_mode: bool = False):
        kwargs = {
            "model": self.model,
            "messages": messages,
            "max_tokens": max_tokens or self.max_tokens,
            "temperature": temperature or self.temperature,
        }
        if json_mode:
            kwargs["response_format"] = {"type": "json_object"}
        return await self.client.chat.completions.create(**kwargs)

    async def _chat_with_tools(self, messages: list[dict], tools: list[dict],
                                tool_choice: str = "auto"):
        return await self.client.chat.completions.create(
            model=self.model,
            messages=messages,
            tools=tools,
            tool_choice=tool_choice,
            max_tokens=self.max_tokens,
            temperature=self.temperature,
        )
'@

# ── app/agents/qb_agent.py ──────────────────────────────────
Set-Content -Path "app/agents/qb_agent.py" -Encoding UTF8 -Value @'
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
'@

# ── app/agents/eval_agent.py ────────────────────────────────
Set-Content -Path "app/agents/eval_agent.py" -Encoding UTF8 -Value @'
import json
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
                  evaluation_types: list[str], audio_duration_seconds: float = None) -> EvaluationResponse:

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
                {"role": "system", "content": EVALUATION_AGENT_SYSTEM_PROMPT},
                {"role": "user", "content": f"Results:\n{json.dumps(serializable, indent=2)}\n\nWrite a 2-3 sentence overall assessment."},
            ],
            temperature=0.3,
        )
        return response.choices[0].message.content or "Evaluation completed."
'@

# ── app/tools/qb/grammar_generator.py ───────────────────────
Set-Content -Path "app/tools/qb/grammar_generator.py" -Encoding UTF8 -Value @'
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
'@

# ── app/tools/qb/passage_generator.py ───────────────────────
Set-Content -Path "app/tools/qb/passage_generator.py" -Encoding UTF8 -Value @'
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
'@

# ── app/tools/eval/grammar_evaluator.py ─────────────────────
Set-Content -Path "app/tools/eval/grammar_evaluator.py" -Encoding UTF8 -Value @'
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
'@

# ── app/tools/eval/pronunciation_evaluator.py ───────────────
Set-Content -Path "app/tools/eval/pronunciation_evaluator.py" -Encoding UTF8 -Value @'
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
'@

# ── app/tools/eval/reading_evaluator.py ─────────────────────
Set-Content -Path "app/tools/eval/reading_evaluator.py" -Encoding UTF8 -Value @'
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
'@

# ── app/tools/eval/vocabulary_analyzer.py ───────────────────
Set-Content -Path "app/tools/eval/vocabulary_analyzer.py" -Encoding UTF8 -Value @'
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
'@

# ── app/tools/eval/structure_validator.py ───────────────────
Set-Content -Path "app/tools/eval/structure_validator.py" -Encoding UTF8 -Value @'
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
'@

# ── app/services/qb_service.py ──────────────────────────────
Set-Content -Path "app/services/qb_service.py" -Encoding UTF8 -Value @'
from fastapi import Depends
from sqlalchemy.orm import Session
from app.agents.qb_agent import QuestionBankAgent
from app.schemas.qb_schemas import GenerateQuestionsRequest, GenerateQuestionsResponse
from app.db.repository import QuestionRepository
from app.db.database import get_db


class QuestionBankService:
    def __init__(self, db: Session = Depends(get_db)):
        self.db = db
        self.agent = QuestionBankAgent()
        self.repo = QuestionRepository(db)

    async def generate_and_save(self, request: GenerateQuestionsRequest) -> GenerateQuestionsResponse:
        questions = await self.agent.run(
            topic=request.topic,
            difficulty=request.difficulty,
            count=request.count,
            question_type=request.type,
        )
        if not questions:
            raise ValueError("Agent returned no questions. Try rephrasing the topic.")

        self.repo.save_questions(
            questions=[q.model_dump() for q in questions],
            question_type=request.type,
        )

        return GenerateQuestionsResponse(
            message=f"Successfully generated {len(questions)} {request.type} questions on '{request.topic}'.",
            type=request.type,
            topic=request.topic,
            difficulty=request.difficulty,
            count=len(questions),
            questions=questions,
        )
'@

# ── app/services/eval_service.py ────────────────────────────
Set-Content -Path "app/services/eval_service.py" -Encoding UTF8 -Value @'
from app.agents.eval_agent import EvaluationAgent
from app.schemas.eval_schemas import EvaluationRequest, EvaluationResponse


class EvaluationService:
    def __init__(self):
        self.agent = EvaluationAgent()

    async def evaluate(self, request: EvaluationRequest) -> EvaluationResponse:
        return await self.agent.run(
            original_text=request.original_text,
            candidate_text=request.candidate_text,
            evaluation_types=request.evaluation_types,
            audio_duration_seconds=request.audio_duration_seconds,
        )
'@

# ── app/api/dependencies/auth.py ────────────────────────────
Set-Content -Path "app/api/dependencies/auth.py" -Encoding UTF8 -Value @'
from fastapi import Security, HTTPException, status
from fastapi.security import APIKeyHeader
from app.config.settings import get_settings

api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)


async def require_api_key(key: str = Security(api_key_header)) -> str:
    settings = get_settings()
    if not key or key != settings.api_secret_key:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid or missing API key. Pass it in the X-API-Key header.",
        )
    return key
'@

# ── app/api/v1/admin/qb_router.py ───────────────────────────
Set-Content -Path "app/api/v1/admin/qb_router.py" -Encoding UTF8 -Value @'
from fastapi import APIRouter, Depends, HTTPException, status
from app.schemas.qb_schemas import GenerateQuestionsRequest, GenerateQuestionsResponse
from app.services.qb_service import QuestionBankService
from app.api.dependencies.auth import require_api_key

router = APIRouter()


@router.get("/health")
async def health():
    return {"status": "ok", "service": "admin-question-bank"}


@router.post(
    "/generate",
    response_model=GenerateQuestionsResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_api_key)],
    summary="Generate grammar or comprehension questions via AI agent",
)
async def generate_questions(
    request: GenerateQuestionsRequest,
    service: QuestionBankService = Depends(QuestionBankService),
):
    try:
        return await service.generate_and_save(request)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Agent error: {str(exc)}")
'@

# ── app/api/v1/evaluation/eval_router.py ────────────────────
Set-Content -Path "app/api/v1/evaluation/eval_router.py" -Encoding UTF8 -Value @'
from fastapi import APIRouter, Depends, HTTPException
from app.schemas.eval_schemas import EvaluationRequest, EvaluationResponse
from app.services.eval_service import EvaluationService

router = APIRouter()


@router.post("/", response_model=EvaluationResponse, summary="Run evaluation tools")
async def evaluate(request: EvaluationRequest, service: EvaluationService = Depends(EvaluationService)):
    try:
        return await service.evaluate(request)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/grammar", response_model=EvaluationResponse, summary="Grammar evaluation only")
async def evaluate_grammar(request: EvaluationRequest, service: EvaluationService = Depends(EvaluationService)):
    request.evaluation_types = ["grammar"]
    return await service.evaluate(request)


@router.post("/reading", response_model=EvaluationResponse, summary="Reading classification: Good/Average/Bad")
async def evaluate_reading(request: EvaluationRequest, service: EvaluationService = Depends(EvaluationService)):
    request.evaluation_types = ["reading"]
    return await service.evaluate(request)


@router.post("/full", response_model=EvaluationResponse, summary="Run all 5 evaluation tools")
async def evaluate_full(request: EvaluationRequest, service: EvaluationService = Depends(EvaluationService)):
    request.evaluation_types = ["grammar", "pronunciation", "reading", "vocabulary", "structure"]
    return await service.evaluate(request)
'@

# ── app/api/v1/router.py ────────────────────────────────────
Set-Content -Path "app/api/v1/router.py" -Encoding UTF8 -Value @'
from fastapi import APIRouter
from app.api.v1.admin.qb_router import router as admin_qb_router
from app.api.v1.evaluation.eval_router import router as eval_router

api_v1_router = APIRouter()
api_v1_router.include_router(admin_qb_router, prefix="/admin/qb", tags=["Admin — Question Bank"])
api_v1_router.include_router(eval_router, prefix="/evaluation", tags=["Evaluation"])
'@

# ── app/main.py ─────────────────────────────────────────────
Set-Content -Path "app/main.py" -Encoding UTF8 -Value @'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
from app.config.settings import get_settings
from app.api.v1.router import api_v1_router
from app.db.database import engine, Base

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    yield


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.app_title,
        version=settings.app_version,
        description="AI-powered Question Bank and Evaluation API",
        lifespan=lifespan,
    )
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.include_router(api_v1_router, prefix="/api/v1")

    @app.exception_handler(Exception)
    async def global_exception_handler(request, exc: Exception):
        return JSONResponse(status_code=500, content={"detail": str(exc), "type": type(exc).__name__})

    @app.get("/health", tags=["Health"])
    async def root_health():
        return {"status": "ok", "version": settings.app_version}

    return app


app = create_app()
'@

# ── pyproject.toml ───────────────────────────────────────────
Set-Content -Path "pyproject.toml" -Encoding UTF8 -Value @'
[project]
name = "question-bank-api"
version = "1.0.0"
description = "AI-powered Question Bank and Evaluation API"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.115.0",
    "uvicorn[standard]>=0.30.0",
    "openai>=1.40.0",
    "pydantic>=2.7.0",
    "pydantic-settings>=2.3.0",
    "sqlalchemy>=2.0.0",
    "psycopg2-binary>=2.9.0",
    "alembic>=1.13.0",
    "python-dotenv>=1.0.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
'@

# ── .env (update with your real key) ────────────────────────
Set-Content -Path ".env" -Encoding UTF8 -Value @'
OPENAI_API_KEY=sk-your-real-key-here
OPENAI_MODEL=gpt-4o-mini
OPENAI_MAX_TOKENS=2000
OPENAI_TEMPERATURE=0.4
DATABASE_URL=postgresql://user:password@localhost:5432/qb_db
API_SECRET_KEY=mysecretkey123
ENVIRONMENT=development
'@

Write-Host "`n✅ All files written with content!" -ForegroundColor Green
Write-Host "👉 Now edit .env with your real OPENAI_API_KEY and DATABASE_URL" -ForegroundColor Yellow
Write-Host "👉 Then run: uv sync" -ForegroundColor Cyan
Write-Host "👉 Then run: uv run uvicorn app.main:app --reload" -ForegroundColor Cyan