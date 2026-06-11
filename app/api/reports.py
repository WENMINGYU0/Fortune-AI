"""报告生成 API"""
from fastapi import APIRouter
from app.models.schemas import ReportRequest, ReportResponse
from app.engines.bazi import bazi_engine
from app.engines.ziwei import ziwei_engine
from app.engines.astrology import astrology_engine
from app.engines.numerology import numerology_engine
from app.ai.deepseek import deepseek_client
from app.ai.prompts import ENGINE_PROMPTS

router = APIRouter(prefix="/reports", tags=["reports"])

REPORT_CONFIG = {
    "full": {
        "title": "完整人生分析报告",
        "pages": 50,
        "price": 299,
        "engines": ["bazi", "ziwei", "astrology", "numerology"],
        "sections": [
            "人格特质总论", "八字命局详解", "紫微命盘解读",
            "占星星盘分析", "事业财富分析", "感情婚姻分析",
            "健康提醒", "流年运势", "趋吉避凶建议",
        ],
    },
    "personality": {
        "title": "人格特质分析报告",
        "pages": 35,
        "price": 99,
        "engines": ["bazi", "numerology"],
        "sections": ["人格核心", "天赋优势", "潜在挑战", "成长方向"],
    },
    "wealth": {
        "title": "财富运势分析报告",
        "pages": 40,
        "price": 128,
        "engines": ["bazi", "ziwei"],
        "sections": ["财富格局", "正财偏财", "投资时机", "理财建议"],
    },
    "marriage": {
        "title": "婚姻感情分析报告",
        "pages": 38,
        "price": 128,
        "engines": ["bazi", "ziwei", "astrology"],
        "sections": ["感情格局", "正缘特征", "婚姻时机", "相处建议"],
    },
    "yearly": {
        "title": "流年运势分析报告",
        "pages": 60,
        "price": 168,
        "engines": ["bazi", "ziwei", "astrology"],
        "sections": ["年运总论", "月运详析", "关键日期", "趋吉建议"],
    },
}


@router.get("/types")
async def list_report_types():
    """列出所有报告类型"""
    return {
        "reports": [
            {
                "id": k,
                "title": v["title"],
                "pages": v["pages"],
                "price": v["price"],
                "sections": v["sections"],
            }
            for k, v in REPORT_CONFIG.items()
        ]
    }


@router.post("/generate")
async def generate_report(request: ReportRequest):
    """生成报告（异步，返回报告结构）"""
    bi = request.birth_info
    report_type = request.report_type.value
    config = REPORT_CONFIG.get(report_type)
    if not config:
        return {"error": "不支持的报告类型"}

    # 基础命盘数据
    chart_data = {}
    if "bazi" in config["engines"]:
        chart_data["bazi"] = bazi_engine.calculate(
            bi.year, bi.month, bi.day, bi.hour, bi.gender.value
        )
    if "ziwei" in config["engines"]:
        chart_data["ziwei"] = ziwei_engine.calculate(
            bi.year, bi.month, bi.day, bi.hour, bi.gender.value
        )
    if "astrology" in config["engines"]:
        chart_data["astrology"] = astrology_engine.calculate(
            bi.year, bi.month, bi.day, bi.hour, bi.gender.value,
            bi.birth_place or ""
        )
    if "numerology" in config["engines"]:
        chart_data["numerology"] = numerology_engine.calculate(
            bi.year, bi.month, bi.day, bi.hour, bi.gender.value
        )

    # 报告结构（实际生产中由 AI 生成各章节内容）
    sections = []
    for i, section_name in enumerate(config["sections"]):
        sections.append({
            "id": i + 1,
            "title": section_name,
            "status": "pending",
            "chart_data_available": True,
        })

    return ReportResponse(
        report_type=request.report_type,
        title=config["title"],
        sections=sections,
        total_pages=config["pages"],
    )
