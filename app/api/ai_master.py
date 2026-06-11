"""AI 大师对话 API - DeepSeek V4 Pro 驱动"""
import json
from fastapi import APIRouter, HTTPException
from sse_starlette.sse import EventSourceResponse
from app.models.schemas import AIChatRequest, AIChatResponse, AIEngineAnalysis
from app.ai.deepseek import deepseek_client
from app.ai.prompts import ENGINE_PROMPTS, CROSS_VALIDATION_SYSTEM
from app.engines.bazi import bazi_engine
from app.engines.ziwei import ziwei_engine
from app.engines.astrology import astrology_engine
from app.engines.numerology import numerology_engine
from app.engines.human_design import human_design_engine

router = APIRouter(prefix="/ai", tags=["ai"])


def _get_birth_context(birth_info) -> str:
    """生成命主信息上下文"""
    bi = birth_info
    context_parts = [
        f"出生日期：{bi.year}年{bi.month}月{bi.day}日",
        f"出生时辰：{bi.hour}时",
        f"性别：{'男' if bi.gender.value == 'male' else '女'}",
    ]

    # 八字信息
    try:
        bazi = bazi_engine.calculate(bi.year, bi.month, bi.day, bi.hour, bi.gender.value)
        fp = bazi['four_pillars']
        context_parts.append(
            f"八字：{fp['year']['gan']}{fp['year']['zhi']}年 "
            f"{fp['month']['gan']}{fp['month']['zhi']}月 "
            f"{fp['day']['gan']}{fp['day']['zhi']}日 "
            f"{fp['hour']['gan']}{fp['hour']['zhi']}时"
        )
        context_parts.append(f"日主：{bazi['day_master']}（{bazi['day_master_element']}）")
        context_parts.append(f"格局：{bazi['pattern']}")
        context_parts.append(f"喜用神：{', '.join(bazi['favorable'])}")
        context_parts.append(f"忌神：{', '.join(bazi['unfavorable'])}")
        context_parts.append(f"五行比例：{json.dumps(bazi['five_elements'], ensure_ascii=False)}")
    except Exception:
        pass

    # 占星信息
    try:
        astro = astrology_engine.calculate(
            bi.year, bi.month, bi.day, bi.hour, bi.gender.value,
            bi.birth_place or ""
        )
        context_parts.append(f"太阳星座：{astro['sun_sign']}")
        context_parts.append(f"月亮星座：{astro['moon_sign']}")
        context_parts.append(f"上升星座：{astro['rising_sign']}")
    except Exception:
        pass

    if bi.name:
        context_parts.append(f"姓名：{bi.name}")
    if bi.birth_place:
        context_parts.append(f"出生地：{bi.birth_place}")

    return "\n".join(context_parts)


@router.post("/chat", response_model=AIChatResponse)
async def ai_chat(request: AIChatRequest):
    """AI大师对话（同步，多引擎交叉验证）"""
    birth_ctx = _get_birth_context(request.birth_info)

    # 多引擎并行分析
    analyses = []
    for engine in request.engines:
        engine_name = engine.value
        system_prompt = ENGINE_PROMPTS.get(engine_name)
        if not system_prompt:
            continue

        try:
            response = await deepseek_client.fortune_analysis(
                system_prompt=system_prompt,
                user_question=request.question,
                birth_info=birth_ctx,
                stream=False,
            )
            analyses.append(AIEngineAnalysis(
                engine=engine,
                analysis=response,
            ))
        except Exception as e:
            analyses.append(AIEngineAnalysis(
                engine=engine,
                analysis=f"分析暂时不可用：{str(e)}",
            ))

    # 交叉验证
    analyses_text = "\n\n---\n\n".join([
        f"【{a.engine.value}】\n{a.analysis}" for a in analyses
    ])

    try:
        conclusion = await deepseek_client.chat(
            messages=[
                {"role": "system", "content": CROSS_VALIDATION_SYSTEM},
                {
                    "role": "user",
                    "content": f"命主信息：{birth_ctx}\n\n问题：{request.question}\n\n"
                               f"各引擎分析结果：\n{analyses_text}",
                },
            ],
            temperature=0.5,
        )
    except Exception as e:
        conclusion = "交叉验证暂时不可用，请参考各引擎独立分析结果。"

    # 置信度
    confidence = min(len(analyses) / 3.0, 1.0) if analyses else 0.0

    return AIChatResponse(
        question=request.question,
        analyses=analyses,
        conclusion=conclusion,
        confidence=confidence,
    )


@router.post("/chat/stream")
async def ai_chat_stream(request: AIChatRequest):
    """AI大师对话（流式，SSE 输出）"""
    birth_ctx = _get_birth_context(request.birth_info)

    # 使用第一个引擎的提示词做流式
    engine_name = request.engines[0].value if request.engines else "bazi"
    system_prompt = ENGINE_PROMPTS.get(engine_name, ENGINE_PROMPTS["bazi"])

    async def event_generator():
        stream = deepseek_client.fortune_analysis(
            system_prompt=system_prompt,
            user_question=request.question,
            birth_info=birth_ctx,
            stream=True,
        )
        async for chunk in stream:
            yield {"event": "message", "data": json.dumps({"content": chunk}, ensure_ascii=False)}
        yield {"event": "done", "data": ""}

    return EventSourceResponse(event_generator())


@router.post("/quick-question")
async def quick_question(request: AIChatRequest):
    """快速单引擎回答"""
    birth_ctx = _get_birth_context(request.birth_info)
    engine_name = request.engines[0].value if request.engines else "bazi"
    system_prompt = ENGINE_PROMPTS.get(engine_name, ENGINE_PROMPTS["bazi"])

    try:
        response = await deepseek_client.fortune_analysis(
            system_prompt=system_prompt,
            user_question=request.question,
            birth_info=birth_ctx,
            stream=False,
        )
        return {"engine": engine_name, "analysis": response}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
