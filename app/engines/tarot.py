"""塔罗牌引擎 - 抽牌 + 牌义解读"""
from typing import Dict, Any, List
import hashlib
import random


class TarotEngine:
    """塔罗牌引擎"""

    # 22张大阿卡纳
    MAJOR_ARCANA = [
        {'id': 0, 'name': '愚者', 'en': 'The Fool', 'upright': '新开始、冒险、自由、天真',
         'reversed': '鲁莽、冒险、缺乏方向', 'element': '风',
         'image': '🃏', 'keywords': ['自由', '冒险', '新起点']},
        {'id': 1, 'name': '魔术师', 'en': 'The Magician', 'upright': '创造力、技能、意志力',
         'reversed': '操控、欺骗、缺乏行动', 'element': '水星',
         'image': '🎩', 'keywords': ['创造', '技能', '意志']},
        {'id': 2, 'name': '女祭司', 'en': 'The High Priestess', 'upright': '直觉、神秘、内在智慧',
         'reversed': '忽略直觉、表面化', 'element': '月亮',
         'image': '🌙', 'keywords': ['直觉', '神秘', '智慧']},
        {'id': 3, 'name': '女皇', 'en': 'The Empress', 'upright': '丰收、母性、创造力',
         'reversed': '依赖、过度保护', 'element': '金星',
         'image': '👑', 'keywords': ['丰收', '母性', '创造']},
        {'id': 4, 'name': '皇帝', 'en': 'The Emperor', 'upright': '权威、结构、控制',
         'reversed': '专制、僵化', 'element': '白羊',
         'image': '🏛️', 'keywords': ['权威', '结构', '领导']},
        {'id': 5, 'name': '教皇', 'en': 'The Hierophant', 'upright': '传统、信仰、指导',
         'reversed': '叛逆、打破传统', 'element': '金牛',
         'image': '📿', 'keywords': ['信仰', '传统', '指导']},
        {'id': 6, 'name': '恋人', 'en': 'The Lovers', 'upright': '爱情、选择、和谐',
         'reversed': '失衡、价值观冲突', 'element': '双子',
         'image': '💕', 'keywords': ['爱情', '选择', '和谐']},
        {'id': 7, 'name': '战车', 'en': 'The Chariot', 'upright': '胜利、决心、前进',
         'reversed': '失控、攻击性', 'element': '巨蟹',
         'image': '⚔️', 'keywords': ['胜利', '决心', '前进']},
        {'id': 8, 'name': '力量', 'en': 'Strength', 'upright': '勇气、耐心、内在力量',
         'reversed': '自我怀疑、脆弱', 'element': '狮子',
         'image': '🦁', 'keywords': ['勇气', '耐心', '力量']},
        {'id': 9, 'name': '隐者', 'en': 'The Hermit', 'upright': '内省、寻求真理、独处',
         'reversed': '孤僻、逃避', 'element': '处女',
         'image': '🏔️', 'keywords': ['内省', '智慧', '独处']},
        {'id': 10, 'name': '命运之轮', 'en': 'Wheel of Fortune', 'upright': '转变、机遇、循环',
         'reversed': '厄运、抗拒变化', 'element': '木星',
         'image': '🎡', 'keywords': ['转变', '机遇', '循环']},
        {'id': 11, 'name': '正义', 'en': 'Justice', 'upright': '公正、真相、因果',
         'reversed': '不公、逃避责任', 'element': '天秤',
         'image': '⚖️', 'keywords': ['公正', '真相', '因果']},
        {'id': 12, 'name': '倒吊人', 'en': 'The Hanged Man', 'upright': '牺牲、新视角、等待',
         'reversed': '拖延、无意义的牺牲', 'element': '海王星',
         'image': '🔄', 'keywords': ['牺牲', '新视角', '等待']},
        {'id': 13, 'name': '死神', 'en': 'Death', 'upright': '结束、转变、重生',
         'reversed': '抗拒改变、停滞', 'element': '天蝎',
         'image': '🦋', 'keywords': ['转变', '重生', '结束']},
        {'id': 14, 'name': '节制', 'en': 'Temperance', 'upright': '平衡、耐心、调和',
         'reversed': '失衡、过度', 'element': '射手',
         'image': '🏺', 'keywords': ['平衡', '调和', '耐心']},
        {'id': 15, 'name': '恶魔', 'en': 'The Devil', 'upright': '束缚、诱惑、物质',
         'reversed': '释放、突破限制', 'element': '摩羯',
         'image': '⛓️', 'keywords': ['束缚', '诱惑', '物质']},
        {'id': 16, 'name': '塔', 'en': 'The Tower', 'upright': '突变、崩塌、觉醒',
         'reversed': '避免灾难、恐惧变化', 'element': '火星',
         'image': '⚡', 'keywords': ['突变', '觉醒', '重建']},
        {'id': 17, 'name': '星星', 'en': 'The Star', 'upright': '希望、灵感、宁静',
         'reversed': '失望、脱离现实', 'element': '水瓶',
         'image': '⭐', 'keywords': ['希望', '灵感', '宁静']},
        {'id': 18, 'name': '月亮', 'en': 'The Moon', 'upright': '幻象、恐惧、直觉',
         'reversed': '释放恐惧、真相显露', 'element': '双鱼',
         'image': '🌕', 'keywords': ['幻象', '直觉', '潜意识']},
        {'id': 19, 'name': '太阳', 'en': 'The Sun', 'upright': '成功、快乐、活力',
         'reversed': '暂时低潮、过度乐观', 'element': '太阳',
         'image': '☀️', 'keywords': ['成功', '快乐', '活力']},
        {'id': 20, 'name': '审判', 'en': 'Judgement', 'upright': '觉醒、重生、审视',
         'reversed': '自我怀疑、拒绝改变', 'element': '冥王星',
         'image': '📯', 'keywords': ['觉醒', '重生', '审视']},
        {'id': 21, 'name': '世界', 'en': 'The World', 'upright': '完成、圆满、整合',
         'reversed': '未完成、缺乏闭合', 'element': '土星',
         'image': '🌍', 'keywords': ['完成', '圆满', '整合']},
    ]

    # 小阿卡纳花色
    SUITS = {
        '权杖': {'element': '火', 'theme': '行动与激情'},
        '圣杯': {'element': '水', 'theme': '情感与关系'},
        '宝剑': {'element': '风', 'theme': '思想与冲突'},
        '钱币': {'element': '土', 'theme': '物质与现实'},
    }

    def draw_cards(self, question: str, spread: str = "three_card",
                   count: int = None) -> Dict[str, Any]:
        """抽牌"""
        # 基于问题的确定性随机
        seed = hashlib.md5(f"{question}{spread}".encode()).hexdigest()
        rng = random.Random(int(seed[:8], 16))

        if count is None:
            count = 3 if spread == "three_card" else 10

        # 从大阿卡纳中抽取
        deck = list(range(22))
        rng.shuffle(deck)

        drawn = []
        for i in range(min(count, 22)):
            card_idx = deck[i]
            card = self.MAJOR_ARCANA[card_idx].copy()
            is_reversed = rng.random() > 0.6  # 40%概率逆位

            card['is_reversed'] = is_reversed
            card['position'] = i + 1

            if spread == "three_card":
                positions = ['过去', '现在', '未来']
                card['position_name'] = positions[i] if i < 3 else f'第{i+1}张'
            else:
                position_names = ['当前处境', '挑战', '潜意识', '过去影响',
                                  '目标', '近期未来', '自我认知', '外部影响',
                                  '希望与恐惧', '最终结果']
                card['position_name'] = position_names[i] if i < 10 else f'第{i+1}张'

            drawn.append(card)

        return {
            "question": question,
            "spread": spread,
            "cards": drawn,
            "card_count": len(drawn),
        }


# 全局单例
tarot_engine = TarotEngine()
