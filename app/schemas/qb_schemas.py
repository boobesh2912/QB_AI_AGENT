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
