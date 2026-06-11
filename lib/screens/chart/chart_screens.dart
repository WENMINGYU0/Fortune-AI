import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/user_profile.dart';
import '../../models/fortune_models.dart';
import '../../services/bazi_service.dart';
import '../../services/storage_service.dart';

/// 八字命盘页面
class BaziChartScreen extends StatefulWidget {
  const BaziChartScreen({super.key});

  @override
  State<BaziChartScreen> createState() => _BaziChartScreenState();
}

class _BaziChartScreenState extends State<BaziChartScreen> {
  final _bazi = BaziService();
  final _storage = StorageService();
  BaziData? _baziData;
  List<FortuneCycle>? _cycles;

  @override
  void initState() {
    super.initState();
    _loadBazi();
  }

  void _loadBazi() {
    final profile = _storage.getProfile();
    if (profile != null) {
      setState(() {
        _baziData = _bazi.calculateBazi(profile);
        _cycles = _bazi.calculateFortuneCycles(profile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('八字命盘')),
      body: Container(
        decoration: const BoxDecoration(gradient: FortuneTheme.bgGradient),
        child: _baziData == null
            ? const EmptyState(icon: '☯️', title: '请先完善个人信息', subtitle: '在个人中心填写出生信息后查看命盘')
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildFourPillars(),
                    const SizedBox(height: 16),
                    _buildDayMasterCard(),
                    const SizedBox(height: 16),
                    _buildFiveElements(),
                    const SizedBox(height: 16),
                    _buildTenGods(),
                    const SizedBox(height: 16),
                    _buildAnalysis(),
                    const SizedBox(height: 16),
                    _buildFortuneCycles(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFourPillars() {
    final d = _baziData!;
    final pillars = [
      ('年柱', d.yearPillar, '${d.yearPillar[0]}${d.yearPillar[1]}'),
      ('月柱', d.monthPillar, '${d.monthPillar[0]}${d.monthPillar[1]}'),
      ('日柱', d.dayPillar, '${d.dayPillar[0]}${d.dayPillar[1]}'),
      ('时柱', d.hourPillar, '${d.hourPillar[0]}${d.hourPillar[1]}'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: FortuneTheme.cardDecoration(),
      child: Column(
        children: [
          const Text('四 柱', style: TextStyle(color: FortuneTheme.goldPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: pillars.map((p) {
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: FortuneTheme.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: p.$1 == '日柱'
                        ? Border.all(color: FortuneTheme.goldPrimary, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(p.$1,
                          style: const TextStyle(color: FortuneTheme.silverGray, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(p.$2[0],
                          style: const TextStyle(color: FortuneTheme.textWhite, fontSize: 20, fontWeight: FontWeight.w700)),
                      Text(p.$2[1],
                          style: const TextStyle(color: FortuneTheme.textSecondary, fontSize: 20, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayMasterCard() {
    final d = _baziData!;
    final profile = _storage.getProfile();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: FortuneTheme.cardDecoration(color: FortuneTheme.goldPrimary.withOpacity(0.1)),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              gradient: FortuneTheme.goldGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(d.dayMaster,
                  style: const TextStyle(fontSize: 28, color: FortuneTheme.mysticBlack, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('日主：${d.dayMaster}',
                    style: const TextStyle(color: FortuneTheme.textWhite, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('生肖：${_bazi.getShengXiao(profile?.birthYear ?? 2024)}',
                    style: const TextStyle(color: FortuneTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiveElements() {
    final elements = _baziData!.fiveElements;
    final colors = {
      '金': const Color(0xFFF0D68A),
      '木': const Color(0xFF4CAF7A),
      '水': const Color(0xFF6495ED),
      '火': const Color(0xFFE05555),
      '土': const Color(0xFFD4A853),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: FortuneTheme.cardDecoration(),
      child: Column(
        children: [
          const Text('五行比例', style: TextStyle(color: FortuneTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...elements.entries.map((e) {
            final pct = (e.value * 100).toInt();
            final color = colors[e.key] ?? FortuneTheme.goldPrimary;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(e.key,
                        style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: e.value,
                        minHeight: 8,
                        backgroundColor: FortuneTheme.cardSurface,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text('$pct%',
                        style: const TextStyle(color: FortuneTheme.textSecondary, fontSize: 12),
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTenGods() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: FortuneTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('十神分布', style: TextStyle(color: FortuneTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _baziData!.tenGods.map((t) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: FortuneTheme.cardSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(t,
                    style: const TextStyle(color: FortuneTheme.goldLight, fontSize: 12)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysis() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: FortuneTheme.cardDecoration(
        color: FortuneTheme.goldPrimary.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('格局分析', style: TextStyle(color: FortuneTheme.goldPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            _bazi.getPatternAnalysis(_baziData!),
            style: const TextStyle(color: FortuneTheme.textSecondary, fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneCycles() {
    if (_cycles == null || _cycles!.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: FortuneTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('大运流年', style: TextStyle(color: FortuneTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ..._cycles!.take(6).map((c) => Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF2A2F45), width: 0.5)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text('${c.startAge}-${c.endAge}岁',
                          style: const TextStyle(color: FortuneTheme.silverGray, fontSize: 12)),
                    ),
                    Expanded(
                      child: Text(c.name,
                          style: const TextStyle(color: FortuneTheme.textWhite, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    Text(c.element,
                        style: const TextStyle(color: FortuneTheme.goldPrimary, fontSize: 12)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// 紫微斗数页面
class ZiweiChartScreen extends StatelessWidget {
  const ZiweiChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('紫微斗数')),
      body: Container(
        decoration: const BoxDecoration(gradient: FortuneTheme.bgGradient),
        child: const EmptyState(
          icon: '🌟',
          title: '紫微斗数',
          subtitle: '输入AI大师进行紫微斗数分析',
        ),
      ),
    );
  }
}

/// 塔罗占卜
class TarotScreen extends StatelessWidget {
  const TarotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('塔罗占卜')),
      body: Container(
        decoration: const BoxDecoration(gradient: FortuneTheme.bgGradient),
        child: const EmptyState(icon: '🃏', title: '塔罗占卜', subtitle: '在AI大师中询问塔罗问题'),
      ),
    );
  }
}

/// 情侣匹配
class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('情侣匹配')),
      body: Container(
        decoration: const BoxDecoration(gradient: FortuneTheme.bgGradient),
        child: const EmptyState(icon: '💕', title: '情侣匹配', subtitle: '在AI大师中输入双方信息进行分析'),
      ),
    );
  }
}

/// 运势报告
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('运势报告')),
      body: Container(
        decoration: const BoxDecoration(gradient: FortuneTheme.bgGradient),
        child: const EmptyState(icon: '📊', title: '运势报告', subtitle: '在AI大师中请求生成详细报告'),
      ),
    );
  }
}

/// 数字命理
class NumerologyScreen extends StatelessWidget {
  const NumerologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('数字命理')),
      body: Container(
        decoration: const BoxDecoration(gradient: FortuneTheme.bgGradient),
        child: const EmptyState(icon: '🔮', title: '数字命理', subtitle: '在AI大师中询问数字命理分析'),
      ),
    );
  }
}
