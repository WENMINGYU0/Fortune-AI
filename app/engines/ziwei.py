"""紫微斗数引擎 - 十二宫排盘 + 四化飞星"""
from typing import Dict, Any, List
import hashlib


class ZiWeiEngine:
    """紫微斗数排盘引擎"""

    # 十二宫位
    PALACES = ['命宫', '兄弟宫', '夫妻宫', '子女宫', '财帛宫', '疾厄宫',
               '迁移宫', '交友宫', '官禄宫', '田宅宫', '福德宫', '父母宫']

    # 十四主星
    MAIN_STARS = {
        '紫微': {'element': '土', 'category': '帝星', 'brightness': '庙旺'},
        '天机': {'element': '木', 'category': '善星', 'brightness': '庙旺'},
        '太阳': {'element': '火', 'category': '贵星', 'brightness': '庙旺'},
        '武曲': {'element': '金', 'category': '财星', 'brightness': '庙旺'},
        '天同': {'element': '水', 'category': '福星', 'brightness': '庙旺'},
        '廉贞': {'element': '火', 'category': '囚星', 'brightness': '平'},
        '天府': {'element': '土', 'category': '库星', 'brightness': '庙旺'},
        '太阴': {'element': '水', 'category': '富星', 'brightness': '庙旺'},
        '贪狼': {'element': '木', 'category': '桃花星', 'brightness': '平'},
        '巨门': {'element': '土', 'category': '暗星', 'brightness': '落陷'},
        '天相': {'element': '水', 'category': '印星', 'brightness': '庙旺'},
        '天梁': {'element': '土', 'category': '荫星', 'brightness': '庙旺'},
        '七杀': {'element': '金', 'category': '将星', 'brightness': '庙旺'},
        '破军': {'element': '水', 'category': '耗星', 'brightness': '平'},
    }

    # 四化
    SI_HUA = {
        '甲': {'化禄': '廉贞', '化权': '破军', '化科': '武曲', '化忌': '太阳'},
        '乙': {'化禄': '天机', '化权': '天梁', '化科': '紫微', '化忌': '太阴'},
        '丙': {'化禄': '天同', '化权': '天机', '化科': '文昌', '化忌': '廉贞'},
        '丁': {'化禄': '太阴', '化权': '天同', '化科': '天机', '化忌': '巨门'},
        '戊': {'化禄': '贪狼', '化权': '太阴', '化科': '右弼', '化忌': '天机'},
        '己': {'化禄': '武曲', '化权': '贪狼', '化科': '天梁', '化忌': '文曲'},
        '庚': {'化禄': '太阳', '化权': '武曲', '化科': '太阴', '化忌': '天同'},
        '辛': {'化禄': '巨门', '化权': '太阳', '化科': '文曲', '化忌': '文昌'},
        '壬': {'化禄': '天梁', '化权': '紫微', '化科': '左辅', '化忌': '武曲'},
        '癸': {'化禄': '破军', '化权': '巨门', '化科': '太阴', '化忌': '贪狼'},
    }

    def calculate(self, year: int, month: int, day: int, hour: int, gender: str) -> Dict[str, Any]:
        """紫微斗数排盘"""
        # 命宫计算
        life_palace_idx = self._calc_life_palace(month, hour)
        body_palace_idx = self._calc_body_palace(month, hour)

        # 安十四主星
        stars_placement = self._place_main_stars(year, month, day, hour)

        # 四化（以年干推）
        from app.engines.bazi import TIAN_GAN
        year_gan = TIAN_GAN[(year - 4) % 10]
        si_hua = self.SI_HUA.get(year_gan, {})

        # 十二宫组装
        palaces = []
        for i, name in enumerate(self.PALACES):
            palace_idx = (life_palace_idx + i) % 12
            palace = {
                "name": name,
                "position": self.PALACES[palace_idx],
                "stars": stars_placement.get(palace_idx, []),
                "di_zhi": self._palace_di_zhi(palace_idx),
            }
            palaces.append(palace)

        return {
            "palaces": palaces,
            "life_palace": {
                "name": "命宫",
                "position_idx": life_palace_idx,
                "stars": stars_placement.get(life_palace_idx, []),
                "di_zhi": self._palace_di_zhi(life_palace_idx),
            },
            "body_palace": {
                "name": "身宫",
                "position_idx": body_palace_idx,
                "stars": stars_placement.get(body_palace_idx, []),
                "di_zhi": self._palace_di_zhi(body_palace_idx),
            },
            "si_hua": si_hua,
            "year_gan": year_gan,
        }

    def _calc_life_palace(self, month: int, hour: int) -> int:
        """命宫地支索引"""
        # 寅起正月，顺数到生月，再逆数到生时
        idx = (month - 1) - (hour // 2)
        return idx % 12

    def _calc_body_palace(self, month: int, hour: int) -> int:
        """身宫地支索引"""
        idx = (month - 1) + (hour // 2)
        return idx % 12

    def _place_main_stars(self, year: int, month: int, day: int, hour: int) -> Dict[int, List]:
        """安十四主星（简化版）"""
        # 基于出生日期的确定性排布
        seed = f"{year}-{month}-{day}-{hour}"
        hash_val = int(hashlib.md5(seed.encode()).hexdigest()[:8], 16)

        placement = {}
        star_names = list(self.MAIN_STARS.keys())

        for i, star in enumerate(star_names):
            palace_idx = (hash_val + i * 7) % 12
            if palace_idx not in placement:
                placement[palace_idx] = []
            placement[palace_idx].append({
                "name": star,
                "element": self.MAIN_STARS[star]['element'],
                "category": self.MAIN_STARS[star]['category'],
                "brightness": self.MAIN_STARS[star]['brightness'],
            })

        return placement

    def _palace_di_zhi(self, idx: int) -> str:
        """宫位地支"""
        from app.engines.bazi import DI_ZHI
        # 命宫从寅开始逆排
        return DI_ZHI[(2 + idx) % 12]


# 全局单例
ziwei_engine = ZiWeiEngine()
