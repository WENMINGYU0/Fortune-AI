import '../models/fortune_models.dart';
import '../models/user_profile.dart';

/// 八字命理计算服务
class BaziService {
  static final BaziService _instance = BaziService._();
  factory BaziService() => _instance;
  BaziService._();

  static const _tianGan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
  static const _diZhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
  static const _shengXiao = ['鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'];

  static const _fiveElementMap = {
    '甲': '木', '乙': '木', '丙': '火', '丁': '火',
    '戊': '土', '己': '土', '庚': '金', '辛': '金',
    '壬': '水', '癸': '水',
    '寅': '木', '卯': '木', '巳': '火', '午': '火',
    '辰': '土', '戌': '土', '丑': '土', '未': '土',
    '申': '金', '酉': '金', '子': '水', '亥': '水',
  };

  static const _yinYang = {
    '甲': '阳', '丙': '阳', '戊': '阳', '庚': '阳', '壬': '阳',
    '乙': '阴', '丁': '阴', '己': '阴', '辛': '阴', '癸': '阴',
  };

  // 计算八字
  BaziData calculateBazi(UserProfile profile) {
    int year = profile.birthYear;
    int month = profile.birthMonth;
    int day = profile.birthDay;
    int hour = profile.birthHour;

    // 年柱
    final yearGan = _tianGan[(year - 4) % 10];
    final yearZhi = _diZhi[(year - 4) % 12];
    final yearPillar = '$yearGan$yearZhi';

    // 月柱
    final monthGanIndex = ((year - 4) % 10 * 2 + month) % 10;
    final monthZhiIndex = (month + 1) % 12;
    final monthGan = _tianGan[monthGanIndex];
    final monthZhi = _diZhi[monthZhiIndex];
    final monthPillar = '$monthGan$monthZhi';

    // 日柱（简化计算）
    final baseDate = DateTime(year, month, day);
    final refDate = DateTime(1900, 1, 1);
    final daysDiff = baseDate.difference(refDate).inDays;
    final dayGan = _tianGan[((daysDiff + 9) % 10)];
    final dayZhi = _diZhi[((daysDiff + 1) % 12)];
    final dayPillar = '$dayGan$dayZhi';

    // 时柱
    final hourZhiIndex = ((hour + 1) ~/ 2) % 12;
    final dayGanIndex = _tianGan.indexOf(dayGan);
    final hourGanIndex = (dayGanIndex * 2 + hourZhiIndex) % 10;
    final hourGan = _tianGan[hourGanIndex];
    final hourZhi = _diZhi[hourZhiIndex];
    final hourPillar = '$hourGan$hourZhi';

    // 日主
    final dayMaster = dayGan;

    // 十神
    final tenGods = _calculateTenGods(dayMaster);

    // 五行比例
    final elements = _calculateFiveElements([
      yearGan, yearZhi, monthGan, monthZhi,
      dayGan, dayZhi, hourGan, hourZhi,
    ]);

    return BaziData(
      yearPillar: yearPillar,
      monthPillar: monthPillar,
      dayPillar: dayPillar,
      hourPillar: hourPillar,
      dayMaster: dayMaster,
      tenGods: tenGods,
      fiveElements: elements,
    );
  }

  // 十神计算
  List<String> _calculateTenGods(String dayMaster) {
    const tenGodNames = [
      '比肩', '劫财', '食神', '伤官',
      '偏财', '正财', '偏官', '正官',
      '偏印', '正印',
    ];
    // 简化：返回全部十神
    return tenGodNames;
  }

  // 五行比例
  Map<String, double> _calculateFiveElements(List<String> chars) {
    final counts = {'金': 0, '木': 0, '水': 0, '火': 0, '土': 0};
    for (final c in chars) {
      final elem = _fiveElementMap[c];
      if (elem != null) counts[elem] = (counts[elem] ?? 0) + 1;
    }
    final total = counts.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return counts.map((k, v) => MapEntry(k, 0.0));
    return counts.map((k, v) => MapEntry(k, v / total));
  }

  // 大运计算
  List<FortuneCycle> calculateFortuneCycles(UserProfile profile) {
    final bazi = calculateBazi(profile);
    final genderMale = profile.gender == '男';
    final dayGanYinYang = _yinYang[bazi.dayMaster] == '阴';

    final forward = (genderMale && !dayGanYinYang) || (!genderMale && dayGanYinYang);

    final monthGanIndex = _tianGan.indexOf(bazi.monthPillar[0]);
    final monthZhiIndex = _diZhi.indexOf(bazi.monthPillar[1]);

    final cycles = <FortuneCycle>[];
    final startAge = forward ? 3 : 8;

    for (int i = 0; i < 8; i++) {
      final ganIndex = forward
          ? (monthGanIndex + i + 1) % 10
          : ((monthGanIndex - i - 1) % 10 + 10) % 10;
      final zhiIndex = forward
          ? (monthZhiIndex + i + 1) % 12
          : ((monthZhiIndex - i - 1) % 12 + 12) % 12;

      final ageStart = startAge + i * 10;

      cycles.add(FortuneCycle(
        name: '${_tianGan[ganIndex]}${_diZhi[zhiIndex]}运',
        startAge: ageStart,
        endAge: ageStart + 9,
        element: _fiveElementMap[_tianGan[ganIndex]] ?? '未知',
        description: '${_tianGan[ganIndex]}${_diZhi[zhiIndex]}大运，${ageStart}-${ageStart + 9}岁行运',
      ));
    }
    return cycles;
  }

  // 生肖
  String getShengXiao(int year) => _shengXiao[(year - 4) % 12];

  // 五行强弱分析
  String getPatternAnalysis(BaziData bazi) {
    final elem = bazi.fiveElements;
    final maxElem = elem.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final minElem = elem.entries.reduce((a, b) => a.value < b.value ? a : b).key;

    return '''
格局分析：
日主${bazi.dayMaster}，五行属${_fiveElementMap[bazi.dayMaster] ?? ''}。
八字中${maxElem}最旺，${minElem}最弱。
${_getUseGod(bazi)}
''';
  }

  String _getUseGod(BaziData bazi) {
    final elem = bazi.fiveElements;
    final dm = bazi.dayMaster;
    final dmElem = _fiveElementMap[dm] ?? '';

    // 简化用神判断
    const generation = {'木': '水', '火': '木', '土': '火', '金': '土', '水': '金'};

    double maxVal = 0;
    String weakElem = '';
    for (final entry in elem.entries) {
      if (entry.value < 0.15) {
        weakElem = entry.key;
        break;
      }
    }

    final useGod = generation[dmElem] ?? '水';
    final xiGod = dmElem;

    return '用神：$useGod（生扶日主）\n喜神：$xiGod\n忌神克制$dmElem之五行';
  }
}
