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
