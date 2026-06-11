/// 命理数据模型

// 八字模型
class BaziData {
  final String yearPillar; // 年柱
  final String monthPillar; // 月柱
  final String dayPillar; // 日柱
  final String hourPillar; // 时柱
  final String dayMaster; // 日主（天干）
  final List<String> tenGods; // 十神
  final Map<String, double> fiveElements; // 五行比例

  const BaziData({
    required this.yearPillar,
    required this.monthPillar,
    required this.dayPillar,
    required this.hourPillar,
    required this.dayMaster,
    required this.tenGods,
    required this.fiveElements,
  });

  factory BaziData.empty() => const BaziData(
        yearPillar: '',
        monthPillar: '',
        dayPillar: '',
        hourPillar: '',
        dayMaster: '',
        tenGods: [],
        fiveElements: {},
      );
}

// 大运流年
class FortuneCycle {
  final String name;
  final int startAge;
  final int endAge;
  final String element;
  final String description;

  const FortuneCycle({
    required this.name,
    required this.startAge,
    required this.endAge,
    required this.element,
    required this.description,
  });
}

// 今日运势
class DailyFortune {
  final DateTime date;
  final int overall; // 综合 0-100
  final int career; // 事业
  final int love; // 爱情
  final int wealth; // 财富
  final int health; // 健康
  final String luckyColor; // 幸运颜色
  final String luckyNumber; // 幸运数字
  final String luckyDirection; // 幸运方位
  final String luckyTime; // 吉时
  final String aiAdvice; // AI建议
  final List<String> suitable; // 宜
  final List<String> unsuitable; // 忌
  final String zodiacClash; // 冲煞

  const DailyFortune({
    required this.date,
    this.overall = 70,
    this.career = 70,
    this.love = 70,
    this.wealth = 70,
    this.health = 70,
    this.luckyColor = '',
    this.luckyNumber = '',
    this.luckyDirection = '',
    this.luckyTime = '',
    this.aiAdvice = '',
    this.suitable = const [],
    this.unsuitable = const [],
    this.zodiacClash = '',
  });

  factory DailyFortune.fromJson(Map<String, dynamic> json) => DailyFortune(
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        overall: json['overall'] ?? 70,
        career: json['career'] ?? 70,
        love: json['love'] ?? 70,
        wealth: json['wealth'] ?? 70,
        health: json['health'] ?? 70,
        luckyColor: json['luckyColor'] ?? '',
        luckyNumber: json['luckyNumber'] ?? '',
        luckyDirection: json['luckyDirection'] ?? '',
        luckyTime: json['luckyTime'] ?? '',
        aiAdvice: json['aiAdvice'] ?? '',
        suitable: List<String>.from(json['suitable'] ?? []),
        unsuitable: List<String>.from(json['unsuitable'] ?? []),
        zodiacClash: json['zodiacClash'] ?? '',
      );
}

// 聊天消息
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final ChatMessageType type;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = ChatMessageType.text,
  });
}

enum ChatMessageType { text, fortune, loading, error }

// 塔罗牌
class TarotCard {
  final String name;
  final String imageName;
  final String meaning;
  final bool isReversed;

  const TarotCard({
    required this.name,
    required this.imageName,
    required this.meaning,
    this.isReversed = false,
  });
}

// 紫微斗数
class ZiweiData {
  final Map<String, String> palaces; // 十二宫
  final Map<String, List<String>> stars; // 星曜分布

  const ZiweiData({
    required this.palaces,
    required this.stars,
  });

  factory ZiweiData.empty() => const ZiweiData(
        palaces: {},
        stars: {},
      );
}

// 情侣匹配
class CoupleMatch {
  final int score; // 0-100
  final String summary;
  final Map<String, String> dimensions; // 各维度分析
  final String advice;

  const CoupleMatch({
    required this.score,
    required this.summary,
    required this.dimensions,
    required this.advice,
  });
}
