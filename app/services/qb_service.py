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
