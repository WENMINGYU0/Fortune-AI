"""八字命理引擎 - 四柱排盘 + 五行分析 + 大运推算"""
from typing import Dict, Any, List
import datetime


# ========== 天干地支基础数据 ==========

TIAN_GAN = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸']
DI_ZHI = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥']
WU_XING_GAN = {'甲': '木', '乙': '木', '丙': '火', '丁': '火', '戊': '土',
               '己': '土', '庚': '金', '辛': '金', '壬': '水', '癸': '水'}
WU_XING_ZHI = {'子': '水', '丑': '土', '寅': '木', '卯': '木', '辰': '土',
               '巳': '火', '午': '火', '未': '土', '申': '金', '酉': '金', '戌': '土', '亥': '水'}
YIN_YANG = {'甲': '阳', '乙': '阴', '丙': '阳', '丁': '阴', '戊': '阳',
            '己': '阴', '庚': '阳', '辛': '阴', '壬': '阳', '癸': '阴'}

# 地支藏干
CANG_GAN = {
    '子': ['癸'], '丑': ['己', '癸', '辛'], '寅': ['甲', '丙', '戊'],
    '卯': ['乙'], '辰': ['戊', '乙', '癸'], '巳': ['丙', '庚', '戊'],
    '午': ['丁', '己'], '未': ['己', '丁', '乙'], '申': ['庚', '壬', '戊'],
    '酉': ['辛'], '戌': ['戊', '辛', '丁'], '亥': ['壬', '甲']
}

# 五行生克
SHENG = {'木': '火', '火': '土', '土': '金', '金': '水', '水': '木'}
KE = {'木': '土', '火': '金', '土': '水', '金': '木', '水': '火'}
BEI_SHENG = {'木': '水', '火': '木', '土': '火', '金': '土', '水': '金'}
BEI_KE = {'木': '金', '火': '水', '土': '木', '金': '火', '水': '土'}


class BaZiEngine:
    """八字排盘引擎"""

    def calculate(self, year: int, month: int, day: int, hour: int, gender: str) -> Dict[str, Any]:
        """完整八字排盘"""
        # 年柱
        year_gan, year_zhi = self._year_pillar(year)
        # 月柱
        month_gan, month_zhi = self._month_pillar(year_gan, month)
        # 日柱
        day_gan, day_zhi = self._day_pillar(year, month, day)
        # 时柱
        hour_gan, hour_zhi = self._hour_pillar(day_gan, hour)

        # 日主
        day_master = day_gan
        day_master_wx = WU_XING_GAN[day_master]

        # 五行统计
        five_elements = self._count_five_elements(
            year_gan, year_zhi, month_gan, month_zhi, day_gan, day_zhi, hour_gan, hour_zhi
        )

        # 格局判定
        pattern = self._determine_pattern(day_master, five_elements, month_zhi)

        # 喜忌用神
        favorable, unfavorable = self._determine_yong_shen(day_master_wx, five_elements)

        # 大运
        major_cycles = self._calculate_major_cycles(
            year, month, day, hour, gender, year_gan
        )

        return {
            "four_pillars": {
                "year": {"gan": year_gan, "zhi": year_zhi, "wx_gan": WU_XING_GAN[year_gan],
                         "wx_zhi": WU_XING_ZHI[year_zhi], "yy": YIN_YANG[year_gan]},
                "month": {"gan": month_gan, "zhi": month_zhi, "wx_gan": WU_XING_GAN[month_gan],
                           "wx_zhi": WU_XING_ZHI[month_zhi], "yy": YIN_YANG[month_gan]},
                "day": {"gan": day_gan, "zhi": day_zhi, "wx_gan": WU_XING_GAN[day_gan],
                        "wx_zhi": WU_XING_ZHI[day_zhi], "yy": YIN_YANG[day_gan]},
                "hour": {"gan": hour_gan, "zhi": hour_zhi, "wx_gan": WU_XING_GAN[hour_gan],
                         "wx_zhi": WU_XING_ZHI[hour_zhi], "yy": YIN_YANG[hour_gan]},
            },
            "five_elements": five_elements,
            "day_master": day_master,
            "day_master_element": day_master_wx,
            "pattern": pattern,
            "favorable": favorable,
            "unfavorable": unfavorable,
            "major_cycles": major_cycles,
            "cang_gan": {
                "year": CANG_GAN[year_zhi],
                "month": CANG_GAN[month_zhi],
                "day": CANG_GAN[day_zhi],
                "hour": CANG_GAN[hour_zhi],
            }
        }

    def _year_pillar(self, year: int) -> tuple:
        """年柱计算"""
        gan_idx = (year - 4) % 10
        zhi_idx = (year - 4) % 12
        return TIAN_GAN[gan_idx], DI_ZHI[zhi_idx]

    def _month_pillar(self, year_gan: str, month: int) -> tuple:
        """月柱计算 - 根据年干推月干"""
        # 月支固定：寅月(1月)开始
        zhi_idx = (month + 1) % 12
        month_zhi = DI_ZHI[zhi_idx]

        # 年干定月干（五虎遁月法）
        year_gan_idx = TIAN_GAN.index(year_gan)
        start_gan_idx = (year_gan_idx % 5) * 2 + 2  # 甲己起丙寅
        if start_gan_idx >= 10:
            start_gan_idx -= 10
        month_gan_idx = (start_gan_idx + month - 1) % 10
        month_gan = TIAN_GAN[month_gan_idx]

        return month_gan, month_zhi

    def _day_pillar(self, year: int, month: int, day: int) -> tuple:
        """日柱计算 - 基于儒略日"""
        # 简化的日柱计算
        # 使用公历日期推算干支序号
        try:
            dt = datetime.date(year, month, day)
            # 以1900年1月1日为基准（庚子日，天干庚=6，地支子=0）
            base = datetime.date(1900, 1, 1)
            diff = (dt - base).days
            # 1900年1月1日：庚子 → gan_idx=6, zhi_idx=0
            gan_idx = (6 + diff) % 10
            zhi_idx = (0 + diff) % 12
            return TIAN_GAN[gan_idx], DI_ZHI[zhi_idx]
        except ValueError:
            return '甲', '子'

    def _hour_pillar(self, day_gan: str, hour: int) -> tuple:
        """时柱计算"""
        # 时支
        zhi_idx = ((hour + 1) // 2) % 12
        hour_zhi = DI_ZHI[zhi_idx]

        # 日干定时干（五鼠遁日法）
        day_gan_idx = TIAN_GAN.index(day_gan)
        start_gan_idx = (day_gan_idx % 5) * 2  # 甲己起甲子
        hour_gan_idx = (start_gan_idx + zhi_idx) % 10
        hour_gan = TIAN_GAN[hour_gan_idx]

        return hour_gan, hour_zhi

    def _count_five_elements(self, yg: str, yz: str, mg: str, mz: str,
                              dg: str, dz: str, hg: str, hz: str) -> Dict[str, float]:
        """五行统计"""
        count = {'木': 0, '火': 0, '土': 0, '金': 0, '水': 0}

        # 天干五行（权重1.0）
        for gan in [yg, mg, dg, hg]:
            count[WU_XING_GAN[gan]] += 1.0

        # 地支五行（权重1.0）
        for zhi in [yz, mz, dz, hz]:
            count[WU_XING_ZHI[zhi]] += 0.8

        # 藏干五行（权重0.3-0.6）
        for zhi in [yz, mz, dz, hz]:
            hidden = CANG_GAN[zhi]
            for i, hg_item in enumerate(hidden):
                weight = 0.6 if i == 0 else (0.3 if i == 1 else 0.1)
                count[WU_XING_GAN[hg_item]] += weight

        # 归一化
        total = sum(count.values())
        if total > 0:
            for k in count:
                count[k] = round(count[k] / total * 100, 1)

        return count

    def _determine_pattern(self, day_master: str, five_elements: Dict,
                           month_zhi: str) -> str:
        """格局判定（简化版）"""
        dm_wx = WU_XING_GAN[day_master]
        dm_strength = five_elements[dm_wx]
        sheng_wx = BEI_SHENG[dm_wx]

        if dm_strength >= 30:
            return f"{dm_wx}旺，身强格"
        elif dm_strength >= 20:
            sheng_strength = five_elements[sheng_wx]
            if sheng_strength >= 20:
                return f"印绶格（{sheng_wx}生{dm_wx}）"
            return f"{dm_wx}中和，身旺格"
        else:
            return f"{dm_wx}弱，身弱格"

    def _determine_yong_shen(self, day_master_wx: str,
                             five_elements: Dict) -> tuple:
        """用神喜忌判定"""
        dm_strength = five_elements[day_master_wx]

        if dm_strength >= 25:
            # 身强：喜克泄耗
            favorable = [KE[day_master_wx], SHENG[day_master_wx],
                         BEI_KE[day_master_wx]]
            unfavorable = [day_master_wx, BEI_SHENG[day_master_wx]]
        else:
            # 身弱：喜生扶
            favorable = [BEI_SHENG[day_master_wx], day_master_wx]
            unfavorable = [KE[day_master_wx], SHENG[day_master_wx],
                           BEI_KE[day_master_wx]]

        return favorable, unfavorable

    def _calculate_major_cycles(self, year: int, month: int, day: int,
                                 hour: int, gender: str, year_gan: str) -> List[Dict]:
        """大运推算（简化版）"""
        cycles = []
        is_yang = YIN_YANG[year_gan] == '阳'
        is_male = gender == 'male'
        forward = (is_yang and is_male) or (not is_yang and not is_male)

        start_age = 5  # 简化起运年龄
        month_gan_idx = TIAN_GAN.index(self._month_pillar(year_gan, month)[0])
        month_zhi_idx = DI_ZHI.index(self._month_pillar(year_gan, month)[1])

        for i in range(8):
            age = start_age + i * 10
            if forward:
                gan_idx = (month_gan_idx + i + 1) % 10
                zhi_idx = (month_zhi_idx + i + 1) % 12
            else:
                gan_idx = (month_gan_idx - i - 1) % 10
                zhi_idx = (month_zhi_idx - i - 1) % 12

            gan = TIAN_GAN[gan_idx]
            zhi = DI_ZHI[zhi_idx]
            wx_gan = WU_XING_GAN[gan]
            wx_zhi = WU_XING_ZHI[zhi]

            cycles.append({
                "age_range": f"{age}-{age + 9}",
                "gan": gan, "zhi": zhi,
                "element": f"{wx_gan}{wx_zhi}",
                "wx_gan": wx_gan, "wx_zhi": wx_zhi,
                "start_year": year + age,
            })

        return cycles

    def get_daily_fortune(self, bazi: Dict, target_date: str = None) -> Dict[str, int]:
        """基于八字的每日运势评分"""
        import hashlib
        seed = f"{bazi['day_master']}{target_date or ''}"
        hash_val = int(hashlib.md5(seed.encode()).hexdigest()[:8], 16)

        overall = 60 + (hash_val % 35)
        career = 55 + (hash_val // 7 % 40)
        love = 50 + (hash_val // 13 % 45)
        wealth = 55 + (hash_val // 19 % 40)
        health = 60 + (hash_val // 31 % 35)

        return {
            "overall": min(overall, 98),
            "career": min(career, 98),
            "love": min(love, 98),
            "wealth": min(wealth, 98),
            "health": min(health, 98),
        }

    def get_lucky_elements(self, bazi: Dict, target_date: str = None) -> Dict[str, str]:
        """幸运要素"""
        import hashlib
        seed = f"{bazi['day_master']}{target_date or ''}"
        hash_val = int(hashlib.md5(seed.encode()).hexdigest()[:8], 16)

        numbers = ['1', '3', '5', '6', '7', '8', '9', '11', '13', '16', '18', '21']
        colors_map = {
            '木': '青色/绿色', '火': '红色/紫色', '土': '黄色/棕色',
            '金': '白色/银色', '水': '黑色/蓝色'
        }
        directions_map = {
            '木': '东方', '火': '南方', '土': '中央',
            '金': '西方', '水': '北方'
        }

        favorable = bazi.get('favorable', ['木', '水'])
        primary = favorable[hash_val % len(favorable)]

        return {
            "number": numbers[hash_val % len(numbers)],
            "color": colors_map.get(primary, '金色'),
            "direction": directions_map.get(primary, '东南'),
            "time": f"{(hash_val % 12) + 1}点-{(hash_val % 12) + 3}点",
        }


# 全局单例
bazi_engine = BaZiEngine()
