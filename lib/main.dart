import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'services/storage_service.dart';
import 'screens/home/home_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/chart/chart_screens.dart';
import 'screens/daily/daily_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();
  runApp(const FortuneAIApp());
}

class FortuneAIApp extends StatelessWidget {
  const FortuneAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '命理AI',
      debugShowCheckedModeBanner: false,
      theme: FortuneTheme.darkTheme,
      home: const MainShell(),
    );
  }
}

/// 主框架 — 底部导航
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static final _pages = <Widget>[
    HomeScreen(),
    ChatScreen(),
    DailyScreen(),
    BaziChartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF2A2F45), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '首页'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI大师'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: '每日运势'),
            BottomNavigationBarItem(icon: Icon(Icons.star_rounded), label: '命盘'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: '我的'),
          ],
        ),
      ),
    );
  }
}
