import 'package:flutter/material.dart';

/// Fortune AI - 主题配置
/// Apple 风格设计：玄黑深蓝底色 + 金色点缀 + 圆角设计

class FortuneTheme {
  // 核心色彩
  static const Color mysticBlack = Color(0xFF0D0D1A);
  static const Color deepBlue = Color(0xFF111B2E);
  static const Color cardDark = Color(0xFF1A1F35);
  static const Color cardSurface = Color(0xFF1E2440);

  static const Color goldPrimary = Color(0xFFD4A853);
  static const Color goldLight = Color(0xFFF0D68A);
  static const Color goldAccent = Color(0xFFC8963E);

  static const Color silverGray = Color(0xFF8E8E9A);
  static const Color silverLight = Color(0xFFB0B0C0);
  static const Color textWhite = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF9A9AB0);

  // 功能色
  static const Color successGreen = Color(0xFF4CAF7A);
  static const Color warningOrange = Color(0xFFE8A850);
  static const Color errorRed = Color(0xFFE05555);
  static const Color lovePink = Color(0xFFE88090);
  static const Color spiritPurple = Color(0xFF8B6FA8);

  // 圆角
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 99.0;

  // 间距
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: goldPrimary,
      scaffoldBackgroundColor: mysticBlack,
      colorScheme: const ColorScheme.dark(
        primary: goldPrimary,
        secondary: goldAccent,
        surface: cardDark,
        error: errorRed,
        onPrimary: mysticBlack,
        onSecondary: mysticBlack,
        onSurface: textWhite,
        onError: textWhite,
      ),
      // Apple 风格导航栏
      appBarTheme: const AppBarTheme(
        backgroundColor: mysticBlack,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: goldPrimary),
      ),
      // 底部导航
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: goldPrimary,
        unselectedItemColor: silverGray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      // 卡片
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        margin: const EdgeInsets.symmetric(horizontal: spacingMD, vertical: spacingSM),
      ),
      // 输入框
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: goldPrimary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: silverGray, fontSize: 14),
        labelStyle: const TextStyle(color: silverLight, fontSize: 14),
      ),
      // 按钮
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldPrimary,
          foregroundColor: mysticBlack,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Tab
      tabBarTheme: const TabBarThemeData(
        labelColor: goldPrimary,
        unselectedLabelColor: silverGray,
        indicatorColor: goldPrimary,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontSize: 14),
      ),
      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2F45),
        thickness: 0.5,
        space: 1,
      ),
      // Text
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textWhite, fontSize: 28, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: textWhite, fontSize: 22, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textWhite, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textWhite, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textWhite, fontSize: 15, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textSecondary, fontSize: 15),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 13),
        bodySmall: TextStyle(color: silverGray, fontSize: 12),
        labelLarge: TextStyle(color: goldPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      fontFamily: 'PingFang SC',
    );
  }

  // 卡片装饰
  static BoxDecoration cardDecoration({Color? color, double? radius}) {
    return BoxDecoration(
      color: color ?? cardDark,
      borderRadius: BorderRadius.circular(radius ?? radiusLG),
      border: Border.all(
        color: const Color(0xFF2A2F45).withOpacity(0.5),
        width: 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // 金色渐变
  static LinearGradient goldGradient = const LinearGradient(
    colors: [goldPrimary, goldAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 背景渐变
  static LinearGradient bgGradient = LinearGradient(
    colors: [
      mysticBlack,
      deepBlue,
      cardDark,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
