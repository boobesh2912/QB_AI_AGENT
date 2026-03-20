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
