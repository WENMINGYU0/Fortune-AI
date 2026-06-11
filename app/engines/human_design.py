"""人类图引擎 - 类型/权威/策略/通道分析"""
from typing import Dict, Any, List
import hashlib


class HumanDesignEngine:
    """人类图引擎"""

    # 能量类型
    TYPES = {
        '显化者': {'percentage': '8%', 'strategy': '告知后再行动',
                  'signature': '平静', 'not_self': '愤怒',
                  'description': '天生具有发起和创造的能力，适合独立启动项目和变革'},
        '生产者': {'percentage': '37%', 'strategy': '等待回应',
                  'signature': '满足', 'not_self': '挫败',
                  'description': '拥有持续的工作能量，适合通过回应来找到正确的工作'},
        '显化生产者': {'percentage': '33%', 'strategy': '等待回应后告知',
                     'signature': '满足', 'not_self': '挫败和愤怒',
                     'description': '兼具显化者和生产者的特质，高效且多能'},
        '投射者': {'percentage': '21%', 'strategy': '等待邀请',
                  'signature': '成功', 'not_self': '苦涩',
                  'description': '善于理解他人和系统，适合作为指导者和管理者'},
        '反映者': {'percentage': '1%', 'strategy': '等待一个太阴周期',
                  'signature': '惊喜', 'not_self': '失望',
                  'description': '如镜般反映环境，极具感受力，适合评估和判断'},
    }

    # 内在权威
    AUTHORITIES = {
        '情绪型': {'center': '太阳神经丛', 'description': '等待情绪清明后再做决定，不要在情绪高潮或低谷时决定'},
        '荐骨型': {'center': '荐骨', 'description': '倾听身体的回应（嗯哼/嗯嗯），荐骨的声响是可靠的指引'},
        '脾脏型': {'center': '脾脏', 'description': '相信瞬间的直觉，第一感觉通常是对的'},
        '自我型': {'center': '心轮', 'description': '跟随内心，做自己真正想做的事'},
        '意志力型': {'center': '意志力中心', 'description': '以意志力为驱动，说到做到'},
        '无定义': {'center': '无', 'description': '所有中心皆开放，需要等待太阴周期来获得清晰'},
    }

    # 36条天赋通道（主要通道）
    CHANNELS = {
        '1-8': {'name': '灵感通道', 'theme': '创意表达', 'gift': '将内在灵感转化为可分享的创意'},
        '2-14': {'name': '脉动通道', 'theme': '方向与资源', 'gift': '持有高我方向并积累资源'},
        '3-60': {'name': '突变通道', 'theme': '从混乱到秩序', 'gift': '在限制中创造突破性变化'},
        '5-15': {'name': '韵律通道', 'theme': '生命韵律', 'gift': '建立自然的生活节奏和模式'},
        '7-31': {'name': '领导者通道', 'theme': '自我领导', 'gift': '天生的领导力，指引方向'},
        '9-52': {'name': '专注通道', 'theme': '专注', 'gift': '深度专注力，适合细节工作'},
        '10-34': {'name': '探索通道', 'theme': '追随自我', 'gift': '以爱自己的方式行动'},
        '10-57': {'name': '完美形式通道', 'theme': '生存直觉', 'gift': '直觉性地知道什么是对自己好的'},
        '11-56': {'name': '好奇通道', 'theme': '好奇心', 'gift': '寻找新体验并分享故事'},
        '12-22': {'name': '开放通道', 'theme': '社交个体', 'gift': '情感表达力，社交魅力'},
        '13-33': {'name': '倾听者通道', 'theme': '倾听', 'gift': '善于倾听并保守秘密'},
        '16-48': {'name': '才华通道', 'theme': '深度', 'gift': '不断深化技能达到大师水平'},
        '17-62': {'name': '组织通道', 'theme': '逻辑', 'gift': '将直觉组织为可表达的概念'},
        '18-58': {'name': '批判通道', 'theme': '修正', 'gift': '发现错误并推动改进'},
        '20-34': {'name': '当下通道', 'theme': '忙碌', 'gift': '在当下行动，忙碌而有成效'},
        '20-57': {'name': '脑波通道', 'theme': '直觉意识', 'gift': '瞬间的直觉洞察力'},
        '21-45': {'name': '金钱线', 'theme': '资源管理', 'gift': '管理物质资源和财富'},
        '23-43': {'name': '天才通道', 'theme': '个体洞见', 'gift': '将独特洞见表达为可理解的语言'},
        '25-51': {'name': '启蒙通道', 'theme': '觉醒', 'gift': '通过竞争和冲击达到觉醒'},
        '27-50': {'name': '守护通道', 'theme': '滋养', 'gift': '照顾他人并保护价值'},
        '28-38': {'name': '挣扎通道', 'theme': '寻找意义', 'gift': '在挣扎中找到生命的意义'},
        '29-46': {'name': '发现通道', 'theme': '承诺', 'gift': '通过全身心投入发现身体真相'},
        '30-41': {'name': '认识通道', 'theme': '幻想', 'gift': '将新体验带入形式'},
        '32-54': {'name': '蜕变通道', 'theme': '转化', 'gift': '驱动成长和蜕变'},
        '34-57': {'name': '力量通道', 'theme': '荐骨直觉', 'gift': '强大的生存直觉和生命力'},
        '35-36': {'name': '变革者通道', 'theme': '体验', 'gift': '通过体验推动变革'},
        '37-40': {'name': '社区通道', 'theme': '社区', 'gift': '通过契约和公平建立社区'},
        '39-55': {'name': '情感通道', 'theme': '情绪', 'gift': '激发深层情感并找到精神自由'},
        '42-53': {'name': '成熟通道', 'theme': '循环', 'gift': '完成循环并推动新发展'},
        '44-26': {'name': '传递者通道', 'theme': '传递', 'gift': '将记忆转化为可传递的信息'},
        '47-64': {'name': '抽象通道', 'theme': '思考', 'gift': '从混乱中提炼意义'},
        '48-16': {'name': '深度通道', 'theme': '才华', 'gift': '将逻辑深度与才华结合'},
        '49-19': {'name': '敏感通道', 'theme': '原则', 'gift': '基于原则和需求建立社区'},
        '54-32': {'name': '觉醒通道', 'theme': '蜕变', 'gift': '驱动从微观到宏观的蜕变'},
        '57-20': {'name': '瞬间觉察', 'theme': '直觉行动', 'gift': '瞬间的直觉力与行动结合'},
        '59-6': {'name': '亲密通道', 'theme': '亲密', 'gift': '打破壁垒建立亲密关系'},
    }

    # 9大能量中心
    CENTERS = {
        '头脑中心': {'theme': '灵感', 'defined_color': '#FFD700'},
        '逻辑中心': {'theme': '概念化', 'defined_color': '#FFA500'},
        '喉咙中心': {'theme': '表达', 'defined_color': '#8B5E3C'},
        '自我中心': {'theme': '爱与方向', 'defined_color': '#FF6B6B'},
        '意志力中心': {'theme': '意志力', 'defined_color': '#FF4444'},
        '脾脏中心': {'theme': '直觉', 'defined_color': '#87CEEB'},
        '情绪中心': {'theme': '情绪', 'defined_color': '#DDA0DD'},
        '荐骨中心': {'theme': '生命力', 'defined_color': '#FF9999'},
        '根中心': {'theme': '驱动力', 'defined_color': '#FF8C00'},
    }

    # 角色轮廓
    PROFILES = [
        '1/3 探究者/殉道者', '1/4 探究者/机会主义者',
        '2/4 隐士/机会主义者', '2/5 隐士/异端者',
        '3/5 殉道者/异端者', '3/6 殉道者/榜样',
        '4/6 机会主义者/榜样', '4/1 机会主义者/探究者',
        '5/1 异端者/探究者', '5/2 异端者/隐士',
        '6/2 榜样/隐士', '6/3 榜样/殉道者',
    ]

    def calculate(self, year: int, month: int, day: int, hour: int,
                  gender: str = "male") -> Dict[str, Any]:
        """人类图计算"""
        seed = f"{year}-{month}-{day}-{hour}"
        hash_val = int(hashlib.md5(seed.encode()).hexdigest()[:8], 16)

        # 类型判定
        type_names = list(self.TYPES.keys())
        type_weights = [8, 37, 33, 21, 1]
        # 加权随机
        type_idx = self._weighted_choice(type_weights, hash_val)
        hd_type = type_names[type_idx]

        # 权威
        auth_names = list(self.AUTHORITIES.keys())
        authority = auth_names[hash_val % len(auth_names)]

        # 角色
        profile = self.PROFILES[hash_val % len(self.PROFILES)]

        # 天赋通道（选2-4条）
        channel_keys = list(self.CHANNELS.keys())
        rng = hash_val
        num_channels = 2 + (hash_val % 3)
        defined_channels = []
        for _ in range(num_channels):
            idx = rng % len(channel_keys)
            key = channel_keys[idx]
            channel = self.CHANNELS[key]
            defined_channels.append({
                "id": key,
                "name": channel['name'],
                "theme": channel['theme'],
                "gift": channel['gift'],
            })
            rng = (rng * 7 + 13) % len(channel_keys)

        # 能量中心定义
        defined_centers = []
        undefined_centers = []
        center_names = list(self.CENTERS.keys())
        for i, name in enumerate(center_names):
            is_defined = (hash_val + i * 3) % 3 != 0
            center_info = {
                "name": name,
                "theme": self.CENTERS[name]['theme'],
                "defined": is_defined,
            }
            if is_defined:
                defined_centers.append(center_info)
            else:
                undefined_centers.append(center_info)

        return {
            "type": hd_type,
            "type_detail": self.TYPES[hd_type],
            "authority": authority,
            "authority_detail": self.AUTHORITIES[authority],
            "strategy": self.TYPES[hd_type]['strategy'],
            "profile": profile,
            "signature": self.TYPES[hd_type]['signature'],
            "not_self": self.TYPES[hd_type]['not_self'],
            "definition": self._calc_definition(defined_centers),
            "defined_channels": defined_channels,
            "defined_centers": defined_centers,
            "undefined_centers": undefined_centers,
        }

    def _weighted_choice(self, weights: List[int], seed: int) -> int:
        """加权选择"""
        total = sum(weights)
        r = seed % total
        cumulative = 0
        for i, w in enumerate(weights):
            cumulative += w
            if r < cumulative:
                return i
        return 0

    def _calc_definition(self, defined_centers: List) -> str:
        """计算定义类型"""
        count = len(defined_centers)
        if count == 0:
            return "无定义(反映者)"
        elif count <= 2:
            return "分列定义"
        elif count <= 5:
            return "单一定义"
        else:
            return "全定义"


# 全局单例
human_design_engine = HumanDesignEngine()
