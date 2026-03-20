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
