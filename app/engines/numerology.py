"""数字命理引擎 - 毕达哥拉斯数字命理学"""
from typing import Dict, Any, List


class NumerologyEngine:
    """数字命理引擎"""

    # 数字含义
    NUMBER_MEANINGS = {
        1: {'name': '领袖', 'keyword': '独立、创造、领导', 'strength': '开创力、独立性、勇气',
            'challenge': '固执、自我中心、独断', 'career': '企业家、管理者、创意总监'},
        2: {'name': '协调者', 'keyword': '合作、敏感、平衡', 'strength': '外交力、同理心、耐心',
            'challenge': '优柔寡断、过度依赖、敏感', 'career': '咨询师、调解员、艺术家'},
        3: {'name': '表达者', 'keyword': '创意、沟通、乐观', 'strength': '创造力、表达力、社交力',
            'challenge': '分散、表面化、情绪化', 'career': '作家、演说家、艺术家'},
        4: {'name': '建设者', 'keyword': '稳定、勤奋、务实', 'strength': '组织力、可靠性、条理性',
            'challenge': '固执、刻板、过于保守', 'career': '工程师、会计、项目管理'},
        5: {'name': '冒险者', 'keyword': '自由、变化、冒险', 'strength': '适应力、多才多艺、好奇心',
            'challenge': '不安定、冲动、散漫', 'career': '记者、旅行家、销售'},
        6: {'name': '关怀者', 'keyword': '责任、关怀、和谐', 'strength': '责任心、关爱、正义感',
            'challenge': '过度操心、控制、完美主义', 'career': '教师、医疗、社工'},
        7: {'name': '探索者', 'keyword': '智慧、内省、灵性', 'strength': '分析力、洞察力、专注',
            'challenge': '孤僻、多疑、过度思考', 'career': '研究员、哲学家、分析师'},
        8: {'name': '权力者', 'keyword': '权力、财富、成就', 'strength': '商业头脑、执行力、判断力',
            'challenge': '物质主义、工作狂、支配', 'career': 'CEO、金融、律师'},
        9: {'name': '人道者', 'keyword': '博爱、智慧、理想', 'strength': '慈悲、理想主义、全球视野',
            'challenge': '脱离现实、过度牺牲、天马行空', 'career': '慈善家、艺术家、教师'},
        11: {'name': '直觉大师', 'keyword': '灵性、直觉、启示', 'strength': '灵感、先知力、精神领导',
             'challenge': '神经质、不切实际', 'career': '灵性导师、创新者、先知'},
        22: {'name': '建设大师', 'keyword': '大师建设、愿景、实践', 'strength': '建设力、远见、执行力',
             'challenge': '压力过大、好高骛远', 'career': '建筑大师、项目巨头、变革者'},
        33: {'name': '慈悲大师', 'keyword': '无条件爱、奉献、教导', 'strength': '治愈力、教导力、博爱',
             'challenge': '自我牺牲过度、理想化', 'career': '精神领袖、治愈者、教育家'},
    }

    def calculate(self, year: int, month: int, day: int, hour: int = 0,
                  gender: str = "male") -> Dict[str, Any]:
        """数字命理计算"""
        # 生命灵数 (Life Path Number)
        life_path = self._reduce_to_master(year + month + day)

        # 命运数 (Destiny Number) - 基于全日期数字
        destiny = self._reduce_to_master(
            self._digit_sum(year) + self._digit_sum(month) + self._digit_sum(day)
        )

        # 灵魂数 (Soul Number) - 日期
        soul = self._reduce_to_master(day)

        # 人格数 (Personality Number) - 月+日
        personality = self._reduce_to_master(month + day)

        # 成熟数 (Maturity Number) - 生命灵数+命运数
        maturity = self._reduce_to_master(life_path + destiny)

        # 个人年运
        from datetime import datetime
        current_year = datetime.now().year
        personal_year = self._reduce_to_master(day + month + self._digit_sum(current_year))

        # 四维分析
        analysis = {
            "life_path": self._get_number_detail(life_path),
            "destiny": self._get_number_detail(destiny),
            "soul": self._get_number_detail(soul),
            "personality": self._get_number_detail(personality),
            "maturity": self._get_number_detail(maturity),
            "personal_year": self._get_number_detail(personal_year),
            "personal_year_number": personal_year,
            "current_year": current_year,
        }

        return {
            "life_path": life_path,
            "destiny": destiny,
            "soul": soul,
            "personality": personality,
            "maturity": maturity,
            "personal_year": personal_year,
            "analysis": analysis,
        }

    def _digit_sum(self, n: int) -> int:
        """数字各位之和"""
        total = 0
        while n > 0:
            total += n % 10
            n //= 10
        return total

    def _reduce_to_master(self, n: int) -> int:
        """缩减到个位数（保留大师数11/22/33）"""
        while n > 9 and n not in (11, 22, 33):
            n = self._digit_sum(n)
        return n if n > 0 else 1

    def _get_number_detail(self, number: int) -> Dict:
        """获取数字详情"""
        meaning = self.NUMBER_MEANINGS.get(number, self.NUMBER_MEANINGS.get(
            number % 9 if number > 9 else 1, {}
        ))
        return {
            "number": number,
            "name": meaning.get('name', '未知'),
            "keyword": meaning.get('keyword', ''),
            "strength": meaning.get('strength', ''),
            "challenge": meaning.get('challenge', ''),
            "career": meaning.get('career', ''),
        }


# 全局单例
numerology_engine = NumerologyEngine()
