"""Fortune AI Pydantic 数据模型"""
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from enum import Enum


# ========== 枚举 ==========

class Gender(str, Enum):
    male = "male"
    female = "female"


class FortuneEngine(str, Enum):
    bazi = "bazi"
    ziwei = "ziwei"
    astrology = "astrology"
    tarot = "tarot"
    numerology = "numerology"
    human_design = "human_design"


class ReportType(str, Enum):
    full = "full"
    personality = "personality"
    wealth = "wealth"
    marriage = "marriage"
    yearly = "yearly"


# ========== 请求模型 ==========

class BirthInfo(BaseModel):
    """出生信息"""
    year: int = Field(..., description="出生年")
    month: int = Field(..., ge=1, le=12, description="出生月")
    day: int = Field(..., ge=1, le=31, description="出生日")
    hour: int = Field(..., ge=0, le=23, description="出生时(24h)")
    gender: Gender = Field(..., description="性别")
    name: Optional[str] = Field(None, description="姓名")
    birth_place: Optional[str] = Field(None, description="出生地")


class DailyFortuneRequest(BaseModel):
    """每日运势请求"""
    birth_info: BirthInfo
    date: Optional[str] = Field(None, description="查询日期 YYYY-MM-DD")


class ChartRequest(BaseModel):
    """命盘请求"""
    birth_info: BirthInfo
    engine: FortuneEngine = Field(..., description="命理引擎")


class AIChatRequest(BaseModel):
    """AI大师对话请求"""
    birth_info: BirthInfo
    question: str = Field(..., min_length=1, description="用户问题")
    engines: List[FortuneEngine] = Field(
        default=[FortuneEngine.bazi, FortuneEngine.ziwei, FortuneEngine.astrology],
        description="使用的命理引擎列表"
    )
    conversation_id: Optional[str] = Field(None, description="对话ID")


class TarotDrawRequest(BaseModel):
    """塔罗抽牌请求"""
    question: str = Field(..., description="问题")
    spread: str = Field(default="three_card", description="牌阵: three_card, celtic_cross")


class ReportRequest(BaseModel):
    """报告请求"""
    birth_info: BirthInfo
    report_type: ReportType = Field(..., description="报告类型")


# ========== 响应模型 ==========

class FortuneScore(BaseModel):
    """运势评分"""
    overall: int = Field(..., ge=0, le=100)
    career: int = Field(..., ge=0, le=100)
    love: int = Field(..., ge=0, le=100)
    wealth: int = Field(..., ge=0, le=100)
    health: int = Field(..., ge=0, le=100)


class LuckyElements(BaseModel):
    """幸运要素"""
    number: str
    color: str
    direction: str
    time: str


class DailyFortuneResponse(BaseModel):
    """每日运势响应"""
    date: str
    scores: FortuneScore
    lucky: LuckyElements
    ai_advice: str
    do_list: List[str]
    dont_list: List[str]


class BaZiChart(BaseModel):
    """八字排盘"""
    four_pillars: Dict[str, Any]
    five_elements: Dict[str, float]
    day_master: str
    pattern: str
    favorable: List[str]
    unfavorable: List[str]
    major_cycles: List[Dict[str, Any]]


class ZiWeiChart(BaseModel):
    """紫微斗数盘"""
    palaces: List[Dict[str, Any]]
    life_palace: Dict[str, Any]
    body_palace: Dict[str, Any]


class AstrologyChart(BaseModel):
    """西方占星盘"""
    sun_sign: str
    moon_sign: str
    rising_sign: str
    planets: List[Dict[str, Any]]
    houses: List[Dict[str, Any]]
    aspects: List[Dict[str, Any]]


class TarotReading(BaseModel):
    """塔罗解读"""
    cards: List[Dict[str, Any]]
    interpretation: str


class NumerologyChart(BaseModel):
    """数字命理"""
    life_path: int
    destiny: int
    soul: int
    personality: int
    analysis: Dict[str, Any]


class HumanDesignChart(BaseModel):
    """人类图"""
    type: str
    authority: str
    strategy: str
    profile: str
    definition: str
    centers: List[Dict[str, Any]]


class ChartResponse(BaseModel):
    """命盘响应"""
    engine: FortuneEngine
    data: Dict[str, Any]


class AIEngineAnalysis(BaseModel):
    """单个引擎分析结果"""
    engine: FortuneEngine
    analysis: str


class AIChatResponse(BaseModel):
    """AI大师对话响应"""
    question: str
    analyses: List[AIEngineAnalysis]
    conclusion: str
    confidence: float = Field(..., ge=0, le=1)


class ReportResponse(BaseModel):
    """报告响应"""
    report_type: ReportType
    title: str
    sections: List[Dict[str, Any]]
    total_pages: int
