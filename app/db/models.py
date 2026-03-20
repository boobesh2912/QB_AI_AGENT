from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, JSON, CheckConstraint, Text
from app.db.database import Base


class GrammarQuestion(Base):
    __tablename__ = "grammar_questions"
    __table_args__ = (
        CheckConstraint("correct_answer IN ('a','b','c','d')", name="ck_grammar_correct_answer"),
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
        CheckConstraint("correct_answer IN ('a','b','c','d')", name="ck_comprehension_correct_answer"),
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
