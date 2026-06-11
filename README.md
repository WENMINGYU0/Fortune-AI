# 🔮 Fortune AI - AI 命理咨询平台

> 融合东方命理（八字、紫微）+ 西方占星 + 塔罗 + AI 智能分析

## ✨ 核心特性

- **6 大命理引擎**：八字命理、紫微斗数、西方占星、塔罗牌、数字命理、人类图
- **DeepSeek AI 驱动**：多引擎交叉验证，AI 深度解读
- **流式对话**：SSE 实时输出 AI 大师分析过程
- **完整命盘**：四柱排盘、五行分析、大运推算、十二宫排盘
- **5 种报告**：完整人生分析、人格特质、财富运势、婚姻感情、流年运势
- **高端 UI**：玄黑+金色神秘主题，Glass Morphism 设计

## 🏗️ 技术栈

| 层级 | 技术 |
|------|------|
| 前端 | HTML5 + CSS3 + Vanilla JS（移动端优先） |
| 后端 | FastAPI + Uvicorn |
| AI | DeepSeek V4 Pro（多引擎交叉验证） |
| 命理引擎 | 纯 Python 实现（八字/紫微/占星/塔罗/数字命理/人类图） |
| 部署 | Docker + Docker Compose |

## 🚀 快速开始

### 方式一：直接运行

```bash
# 克隆仓库
git clone https://github.com/WENMINGYU0/Fortune-AI.git
cd Fortune-AI

# 安装依赖
pip install -r requirements.txt

# 启动服务
python run.py
```

访问 http://localhost:8000

### 方式二：Docker

```bash
# 构建并启动
docker-compose up -d

# 访问
open http://localhost:8000
```

## 📁 项目结构

```
Fortune-AI/
├── app/
│   ├── main.py              # FastAPI 入口
│   ├── config.py             # 配置管理
│   ├── api/
│   │   ├── fortune.py        # 运势计算 API
│   │   ├── ai_master.py     # AI 大师对话 API
│   │   └── reports.py        # 报告生成 API
│   ├── engines/
│   │   ├── bazi.py           # 八字命理引擎
│   │   ├── ziwei.py          # 紫微斗数引擎
│   │   ├── astrology.py      # 西方占星引擎
│   │   ├── tarot.py          # 塔罗牌引擎
│   │   ├── numerology.py     # 数字命理引擎
│   │   └── human_design.py   # 人类图引擎
│   ├── ai/
│   │   ├── deepseek.py       # DeepSeek AI 客户端
│   │   └── prompts.py        # Prompt 模板
│   └── models/
│       └── schemas.py        # 数据模型
├── static/
│   └── index.html            # 前端 Web App
├── run.py                    # 启动脚本
├── Dockerfile                # Docker 镜像
├── docker-compose.yml        # Docker Compose
├── requirements.txt           # Python 依赖
└── .env                      # 环境变量
```

## 🔌 API 文档

启动后访问 http://localhost:8000/docs 查看完整 Swagger 文档

### 主要端点

| 方法 | 端点 | 说明 |
|------|------|------|
| POST | `/api/v1/fortune/daily` | 每日运势 |
| POST | `/api/v1/fortune/chart` | 命盘排盘 |
| POST | `/api/v1/fortune/tarot` | 塔罗抽牌 |
| GET | `/api/v1/fortune/engines` | 可用引擎列表 |
| POST | `/api/v1/ai/chat` | AI 大师对话 |
| POST | `/api/v1/ai/chat/stream` | AI 大师流式对话 |
| POST | `/api/v1/ai/quick-question` | 快速单引擎回答 |
| POST | `/api/v1/reports/generate` | 生成报告 |
| GET | `/api/v1/reports/types` | 报告类型列表 |

### 请求示例

```bash
# 每日运势
curl -X POST http://localhost:8000/api/v1/fortune/daily \
  -H "Content-Type: application/json" \
  -d '{
    "birth_info": {
      "year": 1995, "month": 6, "day": 15,
      "hour": 14, "gender": "male"
    }
  }'

# 八字排盘
curl -X POST http://localhost:8000/api/v1/fortune/chart \
  -H "Content-Type: application/json" \
  -d '{
    "birth_info": {
      "year": 1995, "month": 6, "day": 15,
      "hour": 14, "gender": "male"
    },
    "engine": "bazi"
  }'

# AI 大师对话
curl -X POST http://localhost:8000/api/v1/ai/chat \
  -H "Content-Type: application/json" \
  -d '{
    "birth_info": {
      "year": 1995, "month": 6, "day": 15,
      "hour": 14, "gender": "male"
    },
    "question": "我适合创业吗？",
    "engines": ["bazi", "ziwei", "astrology"]
  }'
```

## ⚙️ 配置

编辑 `.env` 文件：

```env
DEEPSEEK_API_KEY=your-api-key
DEEPSEEK_BASE_URL=https://api.deepseek.com
DEEPSEEK_MODEL=deepseek-chat
```

## 📄 License

MIT License
