import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/api_config.dart';
import '../../models/user_profile.dart';
import '../../models/fortune_models.dart';
import '../../services/deepseek_service.dart';
import '../../services/bazi_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/fortune_widgets.dart';
import '../chat/chat_screen.dart';
import '../chart/chart_screens.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _deepSeek = DeepSeekService();
  final _bazi = BaziService();
  final _storage = StorageService();

  DailyFortune? _fortune;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFortune();
  }

  Future<void> _loadFortune() async {
    setState(() => _loading = true);

    final profile = _storage.getProfile();
    if (profile != null) {
      try {
        final fortune = await _deepSeek.generateDailyFortune(profile);
        if (mounted) setState(() { _fortune = fortune; _loading = false; });
      } catch (_) {
        if (mounted) setState(() => _loading = false; );
      }
    } else {
      // 使用默认运势
      if (mounted) {
        setState(() {
          _fortune = DailyFortune(
            date: DateTime.now(),
            overall: 75, career: 72, love: 78, wealth: 70, health: 80,
            luckyColor: '金色', luckyNumber: '6', luckyDirection: '东南',
            luckyTime: '上午9-11时',
            aiAdvice: '今日运势平稳，宜保持积极心态，审时度势，顺势而为。贵人方位在东南，可多向此方向发展。',
            suitable: ['学习进修', '与人合作', '理财规划'],
            unsuitable: ['冲动决策', '熬夜工作', '大额投资'],
          );
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _storage.getProfile();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: FortuneTheme.bgGradient),
        child: SafeArea(
          child: RefreshIndicator(
            color: FortuneTheme.goldPrimary,
            onRefresh: _loadFortune,
            child: CustomScrollView(
              slivers: [
                // 顶部标题栏
                SliverToBoxAdapter(child: _buildHeader(profile)),
                // 今日运势评分
                SliverToBoxAdapter(child: _buildScoreRing()),
                // 幸运信息
                SliverToBoxAdapter(child: _buildLuckyInfo()),
                // AI 大师建议
                SliverToBoxAdapter(child: _buildAiAdvice()),
                // 适合/避免
                SliverToBoxAdapter(child: _buildFitAvoid()),
                // 快捷入口
                SliverToBoxAdapter(child: _buildQuickActions()),
                // 底部间距
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserProfile? profile) {
    final greeting = _getGreeting();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(color: FortuneTheme.silverGray, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                profile?.name ?? '有缘人',
                style: const TextStyle(
                  color: FortuneTheme.textWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: FortuneTheme.goldGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person, color: FortuneTheme.mysticBlack, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了，早点休息';
    if (hour < 12) return '早上好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  Widget _buildScoreRing() {
    if (_loading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: FortuneTheme.goldPrimary)),
      );
    }

    final f = _fortune;
    if (f == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const Text(
            '今日运势',
            style: TextStyle(color: FortuneTheme.textWhite, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
            style: const TextStyle(color: FortuneTheme.silverGray, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FortuneScoreRing(score: f.overall, label: '综合'),
              FortuneScoreRing(score: f.career, label: '事业'),
              FortuneScoreRing(score: f.love, label: '爱情'),
              FortuneScoreRing(score: f.wealth, label: '财富'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyInfo() {
    final f = _fortune;
    if (f == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: LuckyInfoCard(icon: '🎨', label: '幸运颜色', value: f.luckyColor)),
          const SizedBox(width: 8),
          Expanded(child: LuckyInfoCard(icon: '🔢', label: '幸运数字', value: f.luckyNumber)),
          const SizedBox(width: 8),
          Expanded(child: LuckyInfoCard(icon: '🧭', label: '幸运方位', value: f.luckyDirection)),
          const SizedBox(width: 8),
          Expanded(child: LuckyInfoCard(icon: '⏰', label: '吉时', value: f.luckyTime)),
        ],
      ),
    );
  }

  Widget _buildAiAdvice() {
    final f = _fortune;
    if (f == null) return const SizedBox.shrink();
    return AiAdviceCard(advice: f.aiAdvice);
  }

  Widget _buildFitAvoid() {
    final f = _fortune;
    if (f == null) return const SizedBox.shrink();
    return FitAvoidRow(suitable: f.suitable, unsuitable: f.unsuitable);
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SectionTitle(title: '命理工具'),
          const SizedBox(height: 8),
          Row(
            children: [
              _QuickAction(
                icon: '☯️', title: '八字命盘', subtitle: '四柱·十神·用神',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BaziChartScreen())),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: '🌟', title: '紫微斗数', subtitle: '十二宫·星曜',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ZiweiChartScreen())),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _QuickAction(
                icon: '🃏', title: '塔罗占卜', subtitle: '78张牌·每日一牌',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TarotScreen())),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: '💕', title: '情侣匹配', subtitle: '八字合婚·缘分',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MatchScreen())),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _QuickAction(
                icon: '📊', title: '运势报告', subtitle: '流年·月运·详批',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ReportScreen())),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: '🔮', title: '数字命理', subtitle: '生命灵数·姓名',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NumerologyScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 快捷操作卡片
class _QuickAction extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: FortuneTheme.cardDecoration(
            color: FortuneTheme.cardSurface,
            radius: FortuneTheme.radiusMD,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(color: FortuneTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(color: FortuneTheme.silverGray, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
