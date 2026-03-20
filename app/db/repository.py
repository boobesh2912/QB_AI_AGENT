from sqlalchemy.orm import Session
from app.db.models import GrammarQuestion, ComprehensionQuestion


class QuestionRepository:
    def __init__(self, db: Session):
        self.db = db

    def save_questions(self, questions: list[dict], question_type: str) -> int:
        for q in questions:
            if question_type == "grammar":
                record = GrammarQuestion(
                    topic=q.get("topic", ""),
                    difficulty=q.get("difficulty", ""),
                    question=q.get("question", ""),
                    options=q.get("options", {}),
                    correct_answer=q.get("correct_answer", "a"),
                    explanation=q.get("explanation"),
                )
            else:
                record = ComprehensionQuestion(
                    topic=q.get("topic", ""),
                    difficulty=q.get("difficulty", ""),
                    passage=q.get("passage", ""),
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
