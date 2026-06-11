import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/fortune_widgets.dart';

/// 每日运势页面
class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: FortuneTheme.bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 标题
              const Text('今日运势', style: TextStyle(color: FortuneTheme.textWhite, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('2026年6月11日 星期四', style: TextStyle(color: FortuneTheme.silverGray, fontSize: 13)),
              const SizedBox(height: 24),

              // 四项评分圆环
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _ScoreRing(label: '事业', score: 85, color: FortuneTheme.goldPrimary),
                  _ScoreRing(label: '爱情', score: 72, color: Color(0xFFFF6B8A)),
                  _ScoreRing(label: '财富', score: 90, color: Color(0xFF4ECDC4)),
                  _ScoreRing(label: '健康', score: 78, color: Color(0xFF45B7D1)),
                ],
              ),
              const SizedBox(height: 28),

              // 幸运信息
              _LuckyCard(),
              const SizedBox(height: 20),

              // AI 今日建议
              _AIAdviceCard(),
              const SizedBox(height: 20),

              // 宜/忌
              Row(
                children: const [
                  Expanded(child: _DoDontCard(isDo: true)),
                  SizedBox(width: 12),
                  Expanded(child: _DoDontCard(isDo: false)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 评分圆环
class _ScoreRing extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScoreRing({required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 5,
                  backgroundColor: const Color(0xFF1A1F2E),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Text('$score', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: FortuneTheme.textWhite, fontSize: 12)),
      ],
    );
  }
}

/// 幸运信息卡片
class _LuckyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FortuneCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('今日幸运', style: TextStyle(color: FortuneTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _LuckyItem(icon: '🔢', label: '幸运数字', value: '3, 7, 9'),
              _LuckyItem(icon: '🎨', label: '幸运颜色', value: '金色'),
              _LuckyItem(icon: '🧭', label: '幸运方位', value: '正东'),
              _LuckyItem(icon: '⏰', label: '吉时', value: '9-11点'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LuckyItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _LuckyItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: FortuneTheme.silverGray, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: FortuneTheme.textWhite, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

/// AI 今日建议卡片
class _AIAdviceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FortuneCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: FortuneTheme.goldPrimary, size: 18),
              SizedBox(width: 6),
              Text('AI 今日建议', style: TextStyle(color: FortuneTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '今日天干为甲木，地支为寅木，木气旺盛。事业方面有贵人相助，适合主动出击；感情方面宜含蓄表达，不宜急躁；财运上投资需谨慎，偏财不利；健康注意肝胆养护，少熬夜。',
            style: TextStyle(color: FortuneTheme.textSecondary, fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }
}

/// 宜/忌卡片
class _DoDontCard extends StatelessWidget {
  final bool isDo;

  const _DoDontCard({required this.isDo});

  @override
  Widget build(BuildContext context) {
    final items = isDo ? ['签约', '出行', '求财', '社交'] : ['争吵', '借贷', '动土', '搬迁'];
    return FortuneCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isDo ? Icons.check_circle : Icons.cancel, color: isDo ? FortuneTheme.successGreen : FortuneTheme.errorRed, size: 16),
              const SizedBox(width: 4),
              Text(isDo ? '宜' : '忌', style: TextStyle(color: isDo ? FortuneTheme.successGreen : FortuneTheme.errorRed, fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• $e', style: const TextStyle(color: FortuneTheme.textSecondary, fontSize: 13)),
          )),
        ],
      ),
    );
  }
}
