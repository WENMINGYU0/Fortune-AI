"""西方占星引擎 - 星盘计算 + 相位分析"""
from typing import Dict, Any, List
import hashlib
import math


class AstrologyEngine:
    """西方占星引擎"""

    # 黄道十二宫
    ZODIAC_SIGNS = [
        '白羊座', '金牛座', '双子座', '巨蟹座', '狮子座', '处女座',
        '天秤座', '天蝎座', '射手座', '摩羯座', '水瓶座', '双鱼座'
    ]

    ZODIAC_EN = [
        'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
        'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ]

    ZODIAC_ELEMENTS = {
        '白羊座': '火', '狮子座': '火', '射手座': '火',
        '金牛座': '土', '处女座': '土', '摩羯座': '土',
        '双子座': '风', '天秤座': '风', '水瓶座': '风',
        '巨蟹座': '水', '天蝎座': '水', '双鱼座': '水',
    }

    PLANETS = ['太阳', '月亮', '水星', '金星', '火星', '木星', '土星', '天王星', '海王星', '冥王星']

    ASPECT_TYPES = [
        {'name': '合相', 'angle': 0, 'orb': 8, 'symbol': '☌'},
        {'name': '六分相', 'angle': 60, 'orb': 6, 'symbol': '⚹'},
        {'name': '四分相', 'angle': 90, 'orb': 7, 'symbol': '□'},
        {'name': '三分相', 'angle': 120, 'orb': 8, 'symbol': '△'},
        {'name': '对冲', 'angle': 180, 'orb': 8, 'symbol': '☍'},
    ]

    def calculate(self, year: int, month: int, day: int, hour: int, gender: str,
                  birth_place: str = None) -> Dict[str, Any]:
        """占星盘计算"""
        seed = f"{year}-{month}-{day}-{hour}-{birth_place or ''}"
        hash_val = int(hashlib.md5(seed.encode()).hexdigest()[:8], 16)

        # 太阳星座
        sun_sign_idx = self._calc_sun_sign(month, day)
        sun_sign = self.ZODIAC_SIGNS[sun_sign_idx]

        # 月亮星座（简化计算）
        moon_sign_idx = (sun_sign_idx + (hash_val % 12)) % 12
        moon_sign = self.ZODIAC_SIGNS[moon_sign_idx]

        # 上升星座（基于出生时间）
        rising_sign_idx = ((hour + 2) // 2) % 12
        rising_sign = self.ZODIAC_SIGNS[rising_sign_idx]

        # 行星位置
        planets = self._calc_planet_positions(sun_sign_idx, moon_sign_idx, hash_val)

        # 宫位
        houses = self._calc_houses(rising_sign_idx, hash_val)

        # 相位
        aspects = self._calc_aspects(planets)

        return {
            "sun_sign": sun_sign,
            "sun_sign_en": self.ZODIAC_EN[sun_sign_idx],
            "moon_sign": moon_sign,
            "moon_sign_en": self.ZODIAC_EN[moon_sign_idx],
            "rising_sign": rising_sign,
            "rising_sign_en": self.ZODIAC_EN[rising_sign_idx],
            "elements": {
                "sun": self.ZODIAC_ELEMENTS.get(sun_sign, '未知'),
                "moon": self.ZODIAC_ELEMENTS.get(moon_sign, '未知'),
                "rising": self.ZODIAC_ELEMENTS.get(rising_sign, '未知'),
            },
            "planets": planets,
            "houses": houses,
            "aspects": aspects,
        }

    def _calc_sun_sign(self, month: int, day: int) -> int:
        """太阳星座计算"""
        cutoffs = [(1, 20), (2, 19), (3, 21), (4, 20), (5, 21), (6, 21),
                    (7, 23), (8, 23), (9, 23), (10, 23), (11, 22), (12, 22)]
        for i, (m, d) in enumerate(cutoffs):
            if month < m or (month == m and day < d):
                return (i - 1) % 12
        return 11  # Capricorn

    def _calc_planet_positions(self, sun_idx: int, moon_idx: int,
                                hash_val: int) -> List[Dict]:
        """行星位置"""
        planets = []
        for i, name in enumerate(self.PLANETS):
            if i == 0:  # Sun
                sign_idx = sun_idx
                degree = (hash_val % 30)
            elif i == 1:  # Moon
                sign_idx = moon_idx
                degree = (hash_val // 7 % 30)
            else:
                sign_idx = (sun_idx + hash_val // (i + 3)) % 12
                degree = (hash_val // (i * 7 + 1)) % 30

            planets.append({
                "name": name,
                "sign": self.ZODIAC_SIGNS[sign_idx],
                "sign_en": self.ZODIAC_EN[sign_idx],
                "degree": degree,
                "house": (i + 1) if i < 12 else (i % 12 + 1),
                "retrograde": (hash_val + i) % 7 == 0,
            })
        return planets

    def _calc_houses(self, rising_idx: int, hash_val: int) -> List[Dict]:
        """宫位计算"""
        houses = []
        house_names = ['第一宫(命宫)', '第二宫(财帛)', '第三宫(兄弟)', '第四宫(家庭)',
                       '第五宫(子女)', '第六宫(健康)', '第七宫(婚姻)', '第八宫(疾厄)',
                       '第九宫(迁移)', '第十宫(事业)', '第十一宫(社交)', '第十二宫(玄秘)']

        for i, name in enumerate(house_names):
            sign_idx = (rising_idx + i) % 12
            houses.append({
                "house": i + 1,
                "name": name,
                "sign": self.ZODIAC_SIGNS[sign_idx],
                "sign_en": self.ZODIAC_EN[sign_idx],
            })
        return houses

    def _calc_aspects(self, planets: List[Dict]) -> List[Dict]:
        """相位计算"""
        aspects = []
        for i in range(min(len(planets), 5)):
            for j in range(i + 1, min(len(planets), 7)):
                angle_diff = abs(planets[i]["degree"] - planets[j]["degree"])
                if angle_diff > 180:
                    angle_diff = 360 - angle_diff

                for aspect in self.ASPECT_TYPES:
                    if abs(angle_diff - aspect['angle']) <= aspect['orb']:
                        aspects.append({
                            "planet1": planets[i]["name"],
                            "planet2": planets[j]["name"],
                            "aspect": aspect['name'],
                            "symbol": aspect['symbol'],
                            "exact": abs(angle_diff - aspect['angle']) < 1,
                        })
                        break
        return aspects


# 全局单例
astrology_engine = AstrologyEngine()
