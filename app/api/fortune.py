"""运势计算 API"""
from fastapi import APIRouter, HTTPException
from app.models.schemas import (
    DailyFortuneRequest, DailyFortuneResponse,
    ChartRequest, ChartResponse,
    TarotDrawRequest,
)
from app.engines.bazi import bazi_engine
from app.engines.ziwei import ziwei_engine
from app.engines.astrology import astrology_engine
from app.engines.tarot import tarot_engine
from app.engines.numerology import numerology_engine
from app.engines.human_design import human_design_engine

router = APIRouter(prefix="/fortune", tags=["fortune"])


@router.post("/daily", response_model=DailyFortuneResponse)
async def get_daily_fortune(request: DailyFortuneRequest):
    """获取每日运势"""
    bi = request.birth_info
    bazi = bazi_engine.calculate(bi.year, bi.month, bi.day, bi.hour, bi.gender.value)

    scores = bazi_engine.get_daily_fortune(bazi, request.date)
    lucky = bazi_engine.get_lucky_elements(bazi, request.date)

    # AI 建议由 AI 大师端点处理，这里给基础版本
    do_list = [
        f"穿戴{lucky['color']}，增强运势",
        f"面向{lucky['direction']}方向工作",
        f"在{lucky['time']}做重要决定",
    ]
    dont_list = [
        "避免冲动消费",
        "不宜与人争执",
        "注意饮食规律",
    ]

    return DailyFortuneResponse(
        date=request.date or "",
        scores=scores,
        lucky=lucky,
        ai_advice="今日运势平稳，适合规划与沉淀。利用有利时段处理重要事务，保持积极心态。",
        do_list=do_list,
        dont_list=dont_list,
    )


@router.post("/chart", response_model=ChartResponse)
async def get_chart(request: ChartRequest):
    """获取命盘"""
    bi = request.birth_info
    engine_name = request.engine.value

    if engine_name == "bazi":
        data = bazi_engine.calculate(bi.year, bi.month, bi.day, bi.hour, bi.gender.value)
    elif engine_name == "ziwei":
        data = ziwei_engine.calculate(bi.year, bi.month, bi.day, bi.hour, bi.gender.value)
    elif engine_name == "astrology":
        data = astrology_engine.calculate(
            bi.year, bi.month, bi.day, bi.hour, bi.gender.value,
            bi.birth_place or ""
        )
    elif engine_name == "tarot":
        raise HTTPException(status_code=400, detail="塔罗请使用 /fortune/tarot 端点")
    elif engine_name == "numerology":
        data = numerology_engine.calculate(bi.year, bi.month, bi.day, bi.hour, bi.gender.value)
    elif engine_name == "human_design":
        data = human_design_engine.calculate(bi.year, bi.month, bi.day, bi.hour, bi.gender.value)
    else:
        raise HTTPException(status_code=400, detail=f"不支持的引擎: {engine_name}")

    return ChartResponse(engine=request.engine, data=data)


@router.post("/tarot")
async def draw_tarot(request: TarotDrawRequest):
    """塔罗抽牌"""
    result = tarot_engine.draw_cards(request.question, request.spread)
    return result


@router.get("/engines")
async def list_engines():
    """列出所有可用引擎"""
    return {
        "engines": [
            {"id": "bazi", "name": "八字命理", "description": "四柱排盘、五行分析、大运推算"},
            {"id": "ziwei", "name": "紫微斗数", "description": "十二宫排盘、四化飞星"},
            {"id": "astrology", "name": "西方占星", "description": "星盘计算、相位分析"},
            {"id": "tarot", "name": "塔罗牌", "description": "大阿卡纳抽牌、牌阵解读"},
            {"id": "numerology", "name": "数字命理", "description": "生命灵数、命运数分析"},
            {"id": "human_design", "name": "人类图", "description": "类型、权威、通道分析"},
        ]
    }
