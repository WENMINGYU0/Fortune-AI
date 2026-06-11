/**
 * Fortune AI - 命理引擎 JavaScript 版
 * 所有计算在浏览器端完成，无需后端
 */

// ============================================================
// 工具函数
// ============================================================
const Utils = {
    /**
     * 天干
     */
    TIAN_GAN: ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'],
    
    /**
     * 地支
     */
    DI_ZHI: ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'],
    
    /**
     * 五行
     */
    WU_XING: ['木', '火', '土', '金', '水'],
    
    /**
     * 地支对应月份（寅月=1）
     */
    ZHI_TO_MONTH: { '寅': 1, '卯': 2, '辰': 3, '巳': 4, '午': 5, '未': 6, '申': 7, '酉': 8, '戌': 9, '亥': 10, '子': 11, '丑': 12 },
    
    /**
     * 天干五行
     */
    GAN_WUXING: { '甲': '木', '乙': '木', '丙': '火', '丁': '火', '戊': '土', '己': '土', '庚': '金', '辛': '金', '壬': '水', '癸': '水' },
    
    /**
     * 地支五行
     */
    ZHI_WUXING: { '子': '水', '丑': '土', '寅': '木', '卯': '木', '辰': '土', '巳': '火', '午': '火', '未': '土', '申': '金', '酉': '金', '戌': '土', '亥': '水' },
    
    /**
     * 地支藏干
     */
    ZHI_CANG_GAN: {
        '子': ['癸'],
        '丑': ['己', '癸', '辛'],
        '寅': ['甲', '丙', '戊'],
        '卯': ['乙'],
        '辰': ['戊', '乙', '癸'],
        '巳': ['丙', '庚', '戊'],
        '午': ['丁', '己'],
        '未': ['己', '丁', '乙'],
        '申': ['庚', '壬', '戊'],
        '酉': ['辛'],
        '戌': ['戊', '辛', '丁'],
        '亥': ['壬', '甲'],
    },
    
    /**
     * 获取年柱天干（1984年是甲子年）
     */
    getYearGanZhi(year) {
        const ganIdx = (year - 4) % 10;
        const zhiIdx = (year - 4) % 12;
        return {
            gan: this.TIAN_GAN[ganIdx >= 0 ? ganIdx : ganIdx + 10],
            zhi: this.DI_ZHI[zhiIdx >= 0 ? zhiIdx : zhiIdx + 12],
        };
    },
    
    /**
     * 获取月柱天干地支
     */
    getMonthGanZhi(year, month) {
        // 月支固定：寅月=1，卯月=2...
        const zhiNames = ['寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥', '子', '丑'];
        const zhi = zhiNames[(month - 1) % 12];
        
        // 月干根据年干推算（五虎遁）
        const yearGanIdx = (year - 4) % 10;
        const baseGanIdx = (yearGanIdx * 2 + 2) % 10;
        const monthGanIdx = (baseGanIdx + (month - 1)) % 10;
        const gan = this.TIAN_GAN[monthGanIdx];
        
        return { gan, zhi };
    },
    
    /**
     * 获取日柱天干地支（简化版，使用通用公式）
     */
    getDayGanZhi(year, month, day) {
        // 使用简化的日柱计算公式
        const base = new Date(1900, 0, 1); // 1900年1月1日是甲辰日
        const target = new Date(year, month - 1, day);
        const diffDays = Math.floor((target - base) / (1000 * 60 * 60 * 24));
        const ganIdx = (diffDays + 5) % 10; // 甲辰日的日干是甲(0)，所以+5
        const zhiIdx = (diffDays + 8) % 12; // 甲辰日的日支是辰(4)，所以+8
        
        return {
            gan: this.TIAN_GAN[(ganIdx % 10 + 10) % 10],
            zhi: this.DI_ZHI[(zhiIdx % 12 + 12) % 12],
        };
    },
    
    /**
     * 获取时柱天干地支
     */
    getHourGanZhi(dayGan, hour) {
        const ganIdx = this.TIAN_GAN.indexOf(dayGan);
        const baseGanIdx = (ganIdx * 2) % 10;
        const hourZhiNames = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
        const zhiIdx = Math.floor(hour / 2) % 12;
        const zhi = hourZhiNames[zhiIdx];
        const hourGanIdx = (baseGanIdx + zhiIdx) % 10;
        const gan = this.TIAN_GAN[hourGanIdx];
        
        return { gan, zhi };
    },
    
    /**
     * 计算八字四柱
     */
    calculateBazi(year, month, day, hour) {
        const yearGZ = this.getYearGanZhi(year);
        const monthGZ = this.getMonthGanZhi(year, month);
        const dayGZ = this.getDayGanZhi(year, month, day);
        const hourGZ = this.getHourGanZhi(dayGZ.gan, hour);
        
        return {
            year: yearGZ,
            month: monthGZ,
            day: dayGZ,
            hour: hourGZ,
        };
    },
    
    /**
     * 计算日主（日干）
     */
    getDayMaster(bazi) {
        return bazi.day.gan;
    },
    
    /**
     * 计算五行个数
     */
    countWuXing(bazi) {
        const counts = { '木': 0, '火': 0, '土': 0, '金': 0, '水': 0 };
        
        // 天干
        counts[this.GAN_WUXING[bazi.year.gan]]++;
        counts[this.GAN_WUXING[bazi.month.gan]]++;
        counts[this.GAN_WUXING[bazi.day.gan]]++;
        counts[this.GAN_WUXING[bazi.hour.gan]]++;
        
        // 地支本气
        counts[this.ZHI_WUXING[bazi.year.zhi]]++;
        counts[this.ZHI_WUXING[bazi.month.zhi]]++;
        counts[this.ZHI_WUXING[bazi.day.zhi]]++;
        counts[this.ZHI_WUXING[bazi.hour.zhi]]++;
        
        return counts;
    },
    
    /**
     * 简化的日主强弱判断
     */
    analyzeDayMaster(bazi, gender) {
        const dayGan = bazi.day.gan;
        const dayWuxing = this.GAN_WUXING[dayGan];
        
        // 统计生扶日主的元素
        let support = 0;
        
        // 同五行天干
        [bazi.year.gan, bazi.month.gan, bazi.hour.gan].forEach(gan => {
            if (this.GAN_WUXING[gan] === dayWuxing) support++;
        });
        
        // 生我之五行
        const shengWo = { '木': '水', '火': '木', '土': '火', '金': '土', '水': '金' }[dayWuxing];
        [bazi.year.gan, bazi.month.gan, bazi.hour.gan].forEach(gan => {
            if (this.GAN_WUXING[gan] === shengWo) support++;
        });
        
        const strength = support >= 3 ? '强' : support >= 1 ? '中和' : '弱';
        
        return {
            day_master: dayGan,
            day_wuxing: dayWuxing,
            strength: strength,
            support_count: support,
        };
    },
    
    /**
     * 简单的大运计算（从出生年开始）
     */
    calculateDaYun(bazi, gender, year) {
        // 简化版：每10年一个大运
        const startAge = gender === 'male' ? 8 : 7; // 简化起运年龄
        const daYun = [];
        
        for (let i = 0; i < 8; i++) {
            const startYear = year + startAge + i * 10;
            const endYear = startYear + 9;
            daYun.push({
                index: i + 1,
                start_age: startAge + i * 10,
                end_age: startAge + (i + 1) * 10 - 1,
                start_year: startYear,
                end_year: endYear,
            });
        }
        
        return daYun;
    },
    
    /**
     * Hash 函数（用于伪随机）
     */
    simpleHash(str) {
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash;
        }
        return Math.abs(hash);
    },
};

// ============================================================
// 八字引擎
// ============================================================
class BaziEngine {
    calculate(birthInfo) {
        const { year, month, day, hour, gender } = birthInfo;
        
        const bazi = Utils.calculateBazi(year, month, day, hour);
        const dayMaster = Utils.analyzeDayMaster(bazi, gender);
        const wuxing = Utils.countWuXing(bazi);
        const daYun = Utils.calculateDaYun(bazi, gender, year);
        
        // 格局判断（简化）
        let pattern = '正格';
        if (dayMaster.strength === '强') pattern = '身强用财官';
        else if (dayMaster.strength === '弱') pattern = '身弱用印比';
        
        // 用神喜忌（简化）
        const yongShen = dayMaster.strength === '强' ? '金水' : '木火';
        const jiShen = dayMaster.strength === '强' ? '木火' : '金水';
        
        return {
            success: true,
            bazi: {
                year_pillar: bazi.year,
                month_pillar: bazi.month,
                day_pillar: bazi.day,
                hour_pillar: bazi.hour,
            },
            day_master: dayMaster,
            wuxing_count: wuxing,
            pattern: pattern,
            yong_shen: yongShen,
            ji_shen: jiShen,
            da_yun: daYun,
            summary: `日主${dayMaster.day_master}(${dayMaster.day_wuxing})，${dayMaster.strength}，${pattern}。用神：${yongShen}，忌神：${jiShen}。`,
        };
    }
}

// ============================================================
// 紫微斗数引擎
// ============================================================
class ZiweiEngine {
    calculate(birthInfo) {
        const { year, month, day, hour, gender } = birthInfo;
        const hash = Utils.simpleHash(`${year}-${month}-${day}-${hour}`);
        
        // 主要星曜
        const mainStars = ['紫微', '天机', '太阳', '武曲', '天同', '廉贞', '天府', '太阴', '贪狼', '巨门', '天相', '天梁', '七杀', '破军'];
        
        // 十二宫
        const palaces = ['命宫', '兄弟', '夫妻', '子女', '财帛', '疾厄', '迁移', '交友', '官禄', '田宅', '福德', '父母'];
        
        // 分配星曜到宫位（简化）
        const palaceStars = {};
        palaces.forEach((palace, idx) => {
            const starIdx = (hash + idx * 3) % mainStars.length;
            const stars = [];
            for (let i = 0; i < 2; i++) {
                stars.push(mainStars[(starIdx + i) % mainStars.length]);
            }
            palaceStars[palace] = stars;
        });
        
        // 命宫（简化：以出生日定命宫）
        const mingGongIdx = (day + month) % 12;
        const mingGong = palaces[mingGongIdx];
        
        // 身宫（命宫对面）
        const shenGongIdx = (mingGongIdx + 6) % 12;
        const shenGong = palaces[shenGongIdx];
        
        return {
            success: true,
            ming_gong: mingGong,
            shen_gong: shenGong,
            palaces: palaces.map((name, idx) => ({
                name: name,
                is_ming_gong: idx === mingGongIdx,
                stars: palaceStars[name],
            })),
            main_stars: mainStars.slice(0, 5),
            summary: `命宫在${mingGong}，身宫在${shenGong}。${mingGong}坐${palaceStars[mingGong].join('、')}，主${this._getPalaceMeaning(mingGong)}。`,
        };
    }
    
    _getPalaceMeaning(palace) {
        const meanings = {
            '命宫': '命主性格与天赋',
            '兄弟': '兄弟缘分与助力',
            '夫妻': '婚姻感情状况',
            '子女': '子女缘分与晚年',
            '财帛': '财运与理财能力',
            '疾厄': '健康与体质',
            '迁移': '外出发展与贵人',
            '交友': '朋友与人际关系',
            '官禄': '事业与工作环境',
            '田宅': '家庭与不动产',
            '福德': '精神生活与福气',
            '父母': '父母缘分与早年',
        };
        return meanings[palace] || '运势走向';
    }
}

// ============================================================
// 西方占星引擎
// ============================================================
class AstrologyEngine {
    calculate(birthInfo) {
        const { year, month, day, hour } = birthInfo;
        
        // 黄道十二宫
        const signs = ['白羊座', '金牛座', '双子座', '巨蟹座', '狮子座', '处女座', '天秤座', '天蝎座', '射手座', '摩羯座', '水瓶座', '双鱼座'];
        
        // 十大行星
        const planets = ['太阳', '月亮', '水星', '金星', '火星', '木星', '土星', '天王星', '海王星', '冥王星'];
        
        // 宫位含义
        const houseMeanings = [
            '自我与外在形象', '财富与价值观', '沟通与学习',
            '家庭与根基', '创造力与子女', '健康与工作',
            '婚姻与合伙', '转化与共享资源', '高等教育与旅行',
            '事业与社会地位', '朋友与团体', '潜意识与结束',
        ];
        
        const hash = Utils.simpleHash(`${year}-${month}-${day}-${hour}`);
        
        // 简化计算：根据生日分配星座和行星位置
        const sunSign = signs[(month - 1 + Math.floor(day / 30)) % 12];
        const moonSign = signs[(hash + 3) % 12];
        const ascSign = signs[(hash + 7) % 12];
        
        // 行星分布
        const planetPositions = {};
        planets.forEach((planet, idx) => {
            const signIdx = (hash + idx * 2) % 12;
            planetPositions[planet] = {
                sign: signs[signIdx],
                degree: (hash + idx * 7) % 30,
            };
        });
        
        // 相位（简化）
        const aspects = [
            { p1: '太阳', p2: '月亮', type: '三合', orb: 2 },
            { p1: '太阳', p2: '木星', type: '六合', orb: 1 },
        ];
        
        return {
            success: true,
            sun_sign: sunSign,
            moon_sign: moonSign,
            ascendant: ascSign,
            planets: planetPositions,
            houses: houseMeanings.map((meaning, idx) => ({
                house: idx + 1,
                meaning: meaning,
                sign: signs[(hash + idx) % 12],
            })),
            aspects: aspects,
            summary: `太阳${sunSign}，月亮${moonSign}，上升${ascSign}。太阳与月亮呈三合相位，性格内外和谐统一。`,
        };
    }
}

// ============================================================
// 塔罗牌引擎
// ============================================================
class TarotEngine {
    constructor() {
        this.deck = this._createDeck();
    }
    
    _createDeck() {
        const majorArcana = [
            { name: '愚者', number: 0, meaning: '新的开始、冒险、自由' },
            { name: '魔术师', number: 1, meaning: '创造力、技能、意志力' },
            { name: '女祭司', number: 2, meaning: '直觉、潜意识、内在智慧' },
            { name: '女皇', number: 3, meaning: '丰收、母性、自然' },
            { name: '皇帝', number: 4, meaning: '权威、稳定、控制' },
            { name: '教皇', number: 5, meaning: '传统、信仰、指引' },
            { name: '恋人', number: 6, meaning: '爱情、选择、和谐' },
            { name: '战车', number: 7, meaning: '意志、胜利、控制' },
            { name: '力量', number: 8, meaning: '勇气、耐心、内在力量' },
            { name: '隐士', number: 9, meaning: '内省、寻求真理、独处' },
            { name: '命运之轮', number: 10, meaning: '命运、转变、机遇' },
            { name: '正义', number: 11, meaning: '公正、真相、因果' },
            { name: '倒吊人', number: 12, meaning: '牺牲、等待、新视角' },
            { name: '死神', number: 13, meaning: '结束、转变、重生' },
            { name: '节制', number: 14, meaning: '平衡、耐心、适度' },
            { name: '恶魔', number: 15, meaning: '束缚、物质主义、诱惑' },
            { name: '塔', number: 16, meaning: '突变、觉醒、解放' },
            { name: '星星', number: 17, meaning: '希望、灵感、宁静' },
            { name: '月亮', number: 18, meaning: '幻觉、恐惧、潜意识' },
            { name: '太阳', number: 19, meaning: '成功、活力、喜悦' },
            { name: '审判', number: 20, meaning: '重生、觉醒、决断' },
            { name: '世界', number: 21, meaning: '完成、整合、成就' },
        ];
        
        return majorArcana;
    }
    
    drawCards(question, count = 3) {
        const hash = Utils.simpleHash(question + Date.now());
        const drawnCards = [];
        
        for (let i = 0; i < count; i++) {
            const cardIdx = (hash + i * 7 + Date.now()) % this.deck.length;
            const card = this.deck[Math.abs(cardIdx) % this.deck.length];
            const isReversed = (hash + i * 13) % 2 === 0;
            
            drawnCards.push({
                name: card.name,
                number: card.number,
                is_reversed: isReversed,
                meaning: isReversed ? `逆位：${card.meaning}（能量受阻或内在化）` : `正位：${card.meaning}`,
                position: i === 0 ? '过去' : i === 1 ? '现在' : '未来',
            });
        }
        
        return {
            success: true,
            question: question,
            cards: drawnCards,
            summary: `问题：「${question}」\n抽牌结果：${drawnCards.map(c => `${c.position}-${c.name}(${c.is_reversed ? '逆' : '正'})`).join(' → ')}`,
        };
    }
}

// ============================================================
// 数字命理引擎
// ============================================================
class NumerologyEngine {
    calculate(birthInfo) {
        const { year, month, day } = birthInfo;
        
        // 生命灵数（出生日期各数字相加直到个位数）
        const lifePath = this._reduceToSingleDigit(
            this._reduceToSingleDigit(year) + 
            this._reduceToSingleDigit(month) + 
            this._reduceToSingleDigit(day)
        );
        
        // 命运数（名字，这里简化用生日代替）
        const destiny = this._reduceToSingleDigit(year + month + day);
        
        // 灵魂驱动力（元音数字和）
        const soulUrge = this._reduceToSingleDigit(day);
        
        // 人格数（辅音数字和）
        const personality = this._reduceToSingleDigit(month + year);
        
        // 当前个人年（当前年份的数字和）
        const currentYear = new Date().getFullYear();
        const personalYear = this._reduceToSingleDigit(
            this._reduceToSingleDigit(currentYear) + lifePath
        );
        
        const meanings = {
            1: '领导者、独立、创新',
            2: '合作、敏感、 diplomat',
            3: '创意、表达、社交',
            4: '稳定、务实、建设',
            5: '自由、冒险、变化',
            6: '责任、家庭、服务',
            7: '灵性、分析、内省',
            8: '权力、财富、成就',
            9: '慈悲、智慧、完成',
        };
        
        return {
            success: true,
            life_path: lifePath,
            destiny: destiny,
            soul_urge: soulUrge,
            personality: personality,
            personal_year: personalYear,
            current_year_theme: meanings[personalYear] || '转变之年',
            summary: `生命灵数${lifePath}（${meanings[lifePath]}），命运数${destiny}，当前个人年${personalYear}（${meanings[personalYear]}）。`,
        };
    }
    
    _reduceToSingleDigit(num) {
        while (num > 9) {
            num = String(num).split('').reduce((sum, d) => sum + parseInt(d), 0);
        }
        return num;
    }
}

// ============================================================
// 人类图引擎
// ============================================================
class HumanDesignEngine {
    calculate(birthInfo) {
        const { year, month, day, hour, gender } = birthInfo;
        const hash = Utils.simpleHash(`${year}-${month}-${day}-${hour}`);
        
        // 类型
        const types = ['显化者', '生产者', '显化生产者', '投射者', '反映者'];
        const typeWeights = [8, 37, 33, 21, 1];
        const totalWeight = typeWeights.reduce((a, b) => a + b, 0);
        let rand = hash % totalWeight;
        let typeIdx = 0;
        for (let i = 0; i < typeWeights.length; i++) {
            rand -= typeWeights[i];
            if (rand < 0) { typeIdx = i; break; }
        }
        const hdType = types[typeIdx];
        
        // 权威
        const authorities = ['情绪型', '荐骨型', '脾脏型', '自我型', '无定义'];
        const authority = authorities[hash % authorities.length];
        
        // 策略
        const strategies = {
            '显化者': '告知后再行动',
            '生产者': '等待回应',
            '显化生产者': '等待回应后告知',
            '投射者': '等待邀请',
            '反映者': '等待一个太阴周期',
        };
        const strategy = strategies[hdType];
        
        // 角色
        const profiles = [
            '1/3 探究者/殉道者', '1/4 探究者/机会主义者',
            '2/4 隐士/机会主义者', '2/5 隐士/异端者',
            '3/5 殉道者/异端者', '3/6 殉道者/榜样',
            '4/6 机会主义者/榜样', '4/1 机会主义者/探究者',
            '5/1 异端者/探究者', '5/2 异端者/隐士',
            '6/2 榜样/隐士', '6/3 榜样/殉道者',
        ];
        const profile = profiles[hash % profiles.length];
        
        // 天赋通道（简化选2-4条）
        const channels = [
            { id: '1-8', name: '灵感通道', gift: '将灵感转化为创意' },
            { id: '2-14', name: '方向通道', gift: '持有高我方向' },
            { id: '3-60', name: '突变通道', gift: '在限制中创造变化' },
            { id: '10-34', name: '探索通道', gift: '追随自我' },
            { id: '25-51', name: '启蒙通道', gift: '通过竞争觉醒' },
            { id: '59-6', name: '亲密通道', gift: '建立亲密关系' },
        ];
        const numChannels = 2 + (hash % 3);
        const selectedChannels = [];
        for (let i = 0; i < numChannels; i++) {
            selectedChannels.push(channels[(hash + i * 3) % channels.length]);
        }
        
        return {
            success: true,
            type: hdType,
            authority: authority,
            strategy: strategy,
            profile: profile,
            signature: hdType === '生产者' ? '满足' : hdType === '投射者' ? '成功' : '平静',
            not_self: hdType === '生产者' ? '挫败' : '苦涩',
            defined_channels: selectedChannels,
            summary: `${hdType}类型，${authority}权威，策略「${strategy}」。${profile}。天赋通道：${selectedChannels.map(c => c.name).join('、')}。`,
        };
    }
}

// ============================================================
// 导出
// ============================================================
window.FortuneEngines = {
    BaziEngine,
    ZiweiEngine,
    AstrologyEngine,
    TarotEngine,
    NumerologyEngine,
    HumanDesignEngine,
    Utils,
};
