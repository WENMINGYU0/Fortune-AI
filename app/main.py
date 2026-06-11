"""FastAPI 主入口"""
import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

from app.config import settings
from app.api.fortune import router as fortune_router
from app.api.ai_master import router as ai_router
from app.api.reports import router as reports_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期"""
    print(f"🔮 {settings.APP_NAME} v{settings.APP_VERSION} 启动中...")
    print(f"🤖 DeepSeek Model: {settings.DEEPSEEK_MODEL}")
    print(f"🌐 API Docs: http://{settings.HOST}:{settings.PORT}/docs")
    yield
    # 清理
    from app.ai.deepseek import deepseek_client
    await deepseek_client.close()
    print(f"🔮 {settings.APP_NAME} 已关闭")


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="AI 命理咨询平台 - 融合东方命理 + 西方占星 + AI 智能分析",
    lifespan=lifespan,
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS.split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# API 路由
app.include_router(fortune_router, prefix="/api/v1")
app.include_router(ai_router, prefix="/api/v1")
app.include_router(reports_router, prefix="/api/v1")


# 静态文件
app.mount("/static", StaticFiles(directory="static"), name="static")


@app.get("/")
async def serve_frontend():
    """提供前端页面"""
    return FileResponse("static/index.html")


@app.get("/health")
async def health_check():
    """健康检查"""
    return {
        "status": "ok",
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "ai_model": settings.DEEPSEEK_MODEL,
    }
