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
