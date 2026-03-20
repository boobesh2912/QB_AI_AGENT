from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
from app.config.settings import get_settings
from app.api.v1.router import api_v1_router
from app.db.database import engine, Base

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    yield


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.app_title,
        version=settings.app_version,
        description="AI-powered Question Bank and Evaluation API",
        lifespan=lifespan,
    )
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.include_router(api_v1_router, prefix="/api/v1")

    @app.exception_handler(Exception)
    async def global_exception_handler(request, exc: Exception):
        return JSONResponse(status_code=500, content={"detail": str(exc), "type": type(exc).__name__})

    @app.get("/health", tags=["Health"])
    async def root_health():
        return {"status": "ok", "version": settings.app_version}

    return app


app = create_app()
