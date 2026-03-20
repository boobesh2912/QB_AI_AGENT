from fastapi import APIRouter
from app.api.v1.admin.qb_router import router as admin_qb_router
from app.api.v1.evaluation.eval_router import router as eval_router

api_v1_router = APIRouter()
api_v1_router.include_router(admin_qb_router, prefix="/admin/qb", tags=["Admin â€” Question Bank"])
api_v1_router.include_router(eval_router, prefix="/evaluation", tags=["Evaluation"])
