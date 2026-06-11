import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 公共 UI 组件库 - Apple 风格设计

// 圆角按钮
class FortuneButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool small;
  final IconData? icon;

  const FortuneButton({
    super.key,
    required this.text,
    this.onPressed,
    this.outlined = false,
    this.small = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: FortuneTheme.goldPrimary,
          side: const BorderSide(color: FortuneTheme.goldPrimary, width: 1.5),
          padding: EdgeInsets.symmetric(
            horizontal: small ? 16 : 24,
            vertical: small ? 8 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FortuneTheme.radiusMD),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: small ? 16 : 20),
              const SizedBox(width: 6),
            ],
            Text(text, style: TextStyle(fontSize: small ? 13 : 15, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: FortuneTheme.goldPrimary,
        foregroundColor: FortuneTheme.mysticBlack,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: small ? 16 : 24,
          vertical: small ? 8 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FortuneTheme.radiusMD),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 16 : 20),
            const SizedBox(width: 6),
          ],
          Text(text, style: TextStyle(fontSize: small ? 13 : 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// 运势评分圆环
class FortuneScoreRing extends StatelessWidget {
  final int score;
  final String label;
  final double size;

  const FortuneScoreRing({
    super.key,
    required this.score,
    required this.label,
    this.size = 80,
  });

  Color _scoreColor() {
    if (score >= 80) return FortuneTheme.goldPrimary;
    if (score >= 60) return FortuneTheme.successGreen;
    if (score >= 40) return FortuneTheme.warningOrange;
    return FortuneTheme.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 4,
                  backgroundColor: FortuneTheme.cardSurface,
                  valueColor: AlwaysStoppedAnimation<Color>(_scoreColor()),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      color: _scoreColor(),
                      fontSize: size * 0.28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '分',
                    style: TextStyle(
                      color: FortuneTheme.silverGray,
                      fontSize: size * 0.12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: FortuneTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// 幸运信息卡片
class LuckyInfoCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const LuckyInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: FortuneTheme.cardDecoration(
        color: FortuneTheme.cardSurface,
        radius: FortuneTheme.radiusMD,
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: FortuneTheme.textWhite,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: FortuneTheme.silverGray,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// 章节标题
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: FortuneTheme.textWhite,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: FortuneTheme.silverGray,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: const Row(
                children: [
                  Text(
                    '更多',
                    style: TextStyle(color: FortuneTheme.goldPrimary, fontSize: 13),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: FortuneTheme.goldPrimary, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// AI 建议卡片
class AiAdviceCard extends StatelessWidget {
  final String advice;

  const AiAdviceCard({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FortuneTheme.goldPrimary.withOpacity(0.1),
            FortuneTheme.goldAccent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(FortuneTheme.radiusLG),
        border: Border.all(
          color: FortuneTheme.goldPrimary.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FortuneTheme.goldPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('✨', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI 大师建议',
                  style: TextStyle(
                    color: FortuneTheme.goldPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  advice,
                  style: const TextStyle(
                    color: FortuneTheme.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 适合/避免 标签
class FitAvoidRow extends StatelessWidget {
  final List<String> suitable;
  final List<String> unsuitable;

  const FitAvoidRow({
    super.key,
    required this.suitable,
    required this.unsuitable,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildColumn('宜', suitable, FortuneTheme.successGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildColumn('忌', unsuitable, FortuneTheme.errorRed),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: FortuneTheme.cardDecoration(
        color: color.withOpacity(0.08),
        radius: FortuneTheme.radiusMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $item',
                    style: const TextStyle(color: FortuneTheme.textSecondary, fontSize: 12)),
              )),
        ],
      ),
    );
  }
}

// 聊天消息气泡
class ChatBubble extends StatelessWidget {
  final String content;
  final bool isUser;

  const ChatBubble({super.key, required this.content, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? FortuneTheme.goldPrimary.withOpacity(0.15) : FortuneTheme.cardSurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: isUser
              ? Border.all(color: FortuneTheme.goldPrimary.withOpacity(0.3))
              : null,
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUser ? FortuneTheme.goldLight : FortuneTheme.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

// 空状态
class EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: FortuneTheme.textWhite, fontSize: 16)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: const TextStyle(color: FortuneTheme.silverGray, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}

// 底部导航栏项目
BottomNavigationBarItem navItem(IconData icon, String label) {
  return BottomNavigationBarItem(
    icon: Icon(icon),
    activeIcon: Icon(icon),
    label: label,
  );
}
