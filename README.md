# Question Bank API

An AI-powered FastAPI backend for generating English language questions and evaluating candidate responses. Built with an agent-tool architecture using OpenAI function calling, PostgreSQL for persistence, and async concurrency for evaluation pipelines.

---

## Project Structure

```
question_bank_api/
├── app/
│   ├── agents/
│   │   ├── base_agent.py          # Abstract base with _chat and _chat_with_tools
│   │   ├── qb_agent.py            # Admin agent — question generation via tool calls
│   │   ├── eval_agent.py          # Evaluation agent — runs all 5 eval tools concurrently
│   │   └── prompts.py             # All system and tool prompts
│   ├── api/
│   │   ├── dependencies/
│   │   │   └── auth.py            # X-API-Key header authentication
│   │   └── v1/
│   │       ├── admin/
│   │       │   └── qb_router.py   # POST /api/v1/admin/qb/generate
│   │       ├── evaluation/
│   │       │   └── eval_router.py # POST /api/v1/evaluation/*
│   │       └── router.py          # Root v1 router
│   ├── config/
│   │   └── settings.py            # Pydantic settings with lru_cache
│   ├── db/
│   │   ├── database.py            # SQLAlchemy engine + session + get_db
│   │   ├── models.py              # GrammarQuestion, ComprehensionQuestion ORM models
│   │   └── repository.py         # DB read/write layer
│   ├── schemas/
│   │   ├── qb_schemas.py          # Request/response models for question bank
│   │   └── eval_schemas.py        # Request/response models for evaluation
│   ├── services/
│   │   ├── qb_service.py          # Orchestrates agent + repo for QB flow
│   │   └── eval_service.py        # Delegates to evaluation agent
│   ├── tools/
│   │   ├── qb/
│   │   │   ├── grammar_generator.py    # Generates grammar MCQs
│   │   │   └── passage_generator.py   # Generates reading passages + MCQs
│   │   └── eval/
│   │       ├── grammar_evaluator.py       # Grammar accuracy scoring
│   │       ├── pronunciation_evaluator.py # Pronunciation + fluency scoring
│   │       ├── reading_evaluator.py       # WPM + Good/Average/Bad classification
│   │       ├── vocabulary_analyzer.py     # TTR + richness scoring
│   │       └── structure_validator.py    # Sentence structure + coherence
│   └── main.py                    # App factory, CORS, lifespan, health route
├── alembic/                       # DB migrations setup
├── .env.example
├── pyproject.toml
└── README.md
```

---

## Setup

### Prerequisites

- Python 3.11+
- PostgreSQL running locally (or a connection URL)
- `uv` package manager (or `pip`)

### Installation

```bash
# Clone and enter the project
git clone https://github.com/boobesh2912/QB_AI_AGENT
cd QB_AI_AGENT

# Install dependencies
uv sync

# Copy and fill in environment variables
cp .env.example .env
```

### Environment Variables

```env
OPENAI_API_KEY=sk-your-key-here
OPENAI_MODEL=gpt-4o-mini
OPENAI_MAX_TOKENS=2000
OPENAI_TEMPERATURE=0.4

DATABASE_URL=postgresql://user:password@localhost:5432/qb_db

API_SECRET_KEY=your-secret-key-here
ENVIRONMENT=development
```

### Running the Server

```bash
uv run uvicorn app.main:app --reload
```

Tables are created automatically on startup via `Base.metadata.create_all`. No manual migration needed for initial setup.

Visit `http://localhost:8000/docs` for the interactive Swagger UI.

---

## API Reference

### Health Check

```
GET /health
```

Returns `{ "status": "ok", "version": "1.0.0" }`.

---

### Admin — Question Bank

#### Generate Questions

```
POST /api/v1/admin/qb/generate
```

**Headers**

```
X-API-Key: your-secret-key-here
Content-Type: application/json
```

**Request Body**

```json
{
  "type": "grammar",
  "topic": "tenses",
  "difficulty": "intermediate",
  "count": 5
}
```

| Field | Type | Options |
|---|---|---|
| `type` | string | `grammar`, `comprehension` |
| `topic` | string | Any topic string (2–200 chars) |
| `difficulty` | string | `beginner`, `intermediate`, `advanced` |
| `count` | integer | 1–20 (default: 5) |

**Response**

```json
{
  "message": "Successfully generated 5 grammar questions on 'tenses'.",
  "type": "grammar",
  "topic": "tenses",
  "difficulty": "intermediate",
  "count": 5,
  "questions": [
    {
      "topic": "tenses",
      "difficulty": "intermediate",
      "passage": null,
      "question": "Which sentence uses the present perfect correctly?",
      "options": {
        "a": "She has went to the store.",
        "b": "She have gone to the store.",
        "c": "She has gone to the store.",
        "d": "She had go to the store."
      },
      "correct_answer": "c",
      "explanation": "Present perfect uses 'has/have' + past participle. 'Gone' is the past participle of 'go'."
    }
  ]
}
```

For `type: comprehension`, each question will also include a `passage` field with the reading text (120–180 words). All questions are saved to PostgreSQL after generation.

---

### Evaluation

All evaluation endpoints share the same request body shape:

```json
{
  "original_text": "The quick brown fox jumps over the lazy dog.",
  "candidate_text": "The quick brown fox jump over the lazy dog.",
  "audio_duration_seconds": 4.2,
  "evaluation_types": ["grammar", "reading"]
}
```

| Field | Required | Description |
|---|---|---|
| `original_text` | Yes | The reference/prompt text (min 10 chars) |
| `candidate_text` | Yes | The candidate's response |
| `audio_duration_seconds` | No | Used for WPM and pronunciation scoring |
| `evaluation_types` | No | Defaults to `["grammar"]` |

#### Run Specific Evaluations

```
POST /api/v1/evaluation/
```

Runs whichever tools are listed in `evaluation_types`.

#### Grammar Only

```
POST /api/v1/evaluation/grammar
```

Ignores `evaluation_types` — always runs grammar evaluation only.

#### Reading Only

```
POST /api/v1/evaluation/reading
```

Ignores `evaluation_types` — always runs reading evaluation only.

#### Full Evaluation (All 5 Tools)

```
POST /api/v1/evaluation/full
```

Ignores `evaluation_types` — runs all 5 tools concurrently.

**Response**

```json
{
  "grammar": {
    "accuracy_score": 85.0,
    "error_count": 1,
    "error_types": ["subject-verb agreement"],
    "corrected_text": "The quick brown fox jumps over the lazy dog.",
    "feedback": "One subject-verb agreement error found."
  },
  "pronunciation": null,
  "reading": {
    "reading_speed_wpm": 142.5,
    "classification": "Good",
    "accuracy_score": 95.2,
    "overall_score": 90.0,
    "feedback": "Good reading pace with high accuracy.",
    "recommendations": "Maintain current pace."
  },
  "vocabulary": null,
  "structure": null,
  "overall_summary": "The candidate demonstrated strong reading fluency with one grammar error..."
}
```

Fields not requested are returned as `null`. If an individual tool fails, it also returns `null` — the other results are still returned.

---

## Agents & Tools

### Admin Agent (`QuestionBankAgent`)

Uses OpenAI function calling to route between two tools:

| Tool | Trigger | Output |
|---|---|---|
| `generate_grammar_questions` | `type = grammar` | MCQ list with options a/b/c/d and explanations |
| `generate_passage_with_questions` | `type = comprehension` | 120–180 word passage + MCQ list |

The agent sends a tool call, executes the matching function, then sends the result back to the model for final JSON formatting before parsing into Pydantic models.

### Evaluation Agent (`EvaluationAgent`)

Runs all requested tools **concurrently** using `asyncio.gather`. Each tool does partial computation locally (WPM, TTR, sentence count) before making its LLM call — reducing latency and improving output quality.

| Tool | Local Pre-computation | LLM Output |
|---|---|---|
| Grammar Evaluator | — | accuracy_score, error_types, corrected_text |
| Pronunciation Evaluator | Word diff (set subtraction) | pronunciation_score, fluency_score |
| Reading Evaluator | WPM via word count ÷ duration, accuracy via SequenceMatcher | Good / Average / Bad classification |
| Vocabulary Analyzer | TTR (type-token ratio) | richness_score, vocabulary_level |
| Structure Validator | sentence_count, avg_sentence_length | structure_score, is_coherent, issues |

After all tools complete, a final LLM call generates the plain-text `overall_summary`.

---

## Database

Two tables are created automatically:

- `grammar_questions` — stores grammar MCQs with a check constraint on `correct_answer IN ('a','b','c','d')`
- `comprehension_questions` — same structure with an additional `passage` (TEXT) column

Both include `created_at` and `updated_at` timestamps. The repository exposes `save_questions` and `get_by_topic` methods.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | FastAPI 0.115+ |
| AI | OpenAI Python SDK (async), GPT-4o-mini |
| Database | PostgreSQL + SQLAlchemy 2.0 |
| Migrations | Alembic |
| Validation | Pydantic v2 + pydantic-settings |
| Server | Uvicorn (standard) |
| Package Manager | uv |

---

## Notes

- The `X-API-Key` header is required for all `/admin/qb` routes. Pass the value from `API_SECRET_KEY` in your `.env`.
- For evaluation endpoints, `audio_duration_seconds` is needed for accurate WPM and pronunciation scoring. If omitted, it defaults to `0.0` and those scores will be less meaningful.
- All prompts are centralized in `app/agents/prompts.py` — update them there to tune model behaviour without touching agent or tool logic.
