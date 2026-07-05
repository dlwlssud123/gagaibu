import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/report_screen.dart';
import 'screens/setting_screen.dart';
import 'widgets/transaction_modal.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const GaGaIBuApp(),
    ),
  );
}

class GaGaIBuApp extends StatelessWidget {
  const GaGaIBuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '가개부 (GaGaIBu)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF343A40),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF343A40),
          primary: const Color(0xFF343A40),
          secondary: const Color(0xFF10B981),
        ),
        // 현대적인 웹앱 느낌의 전역 폰트 연동 (Outfit & Noto Sans KR)
        fontFamily: 'Noto Sans KR',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // 활성 탭 인덱스 매핑
    int activeIndex = 0;
    Widget activeBody = const HomeScreen();
    String headerTitle = '홈';

    switch (state.activeTab) {
      case 'home':
        activeIndex = 0;
        activeBody = const HomeScreen();
        headerTitle = '홈';
        break;
      case 'history':
        activeIndex = 1;
        activeBody = const CalendarScreen();
        headerTitle = '소비 내역';
        break;
      case 'report':
        activeIndex = 2;
        activeBody = const ReportScreen();
        headerTitle = 'AI 자축 코칭';
        break;
      case 'setting':
        activeIndex = 3;
        activeBody = const SettingScreen();
        headerTitle = '설정';
        break;
    }

    return Scaffold(
      // 앱 상단 헤더
      appBar: AppBar(
        title: Text(
          headerTitle,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12.0),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.grey[300]!, width: 0.5),
            ),
            child: const Text(
              'gagaibu_user',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 22.0),
            onPressed: () {},
          ),
          const SizedBox(width: 8.0),
        ],
      ),

      // 탭별 본문 화면
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF343A40)),
              ),
            )
          : activeBody,

      // 빠른 지출/수입 등록용 FAB 플로팅 액션 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // 키보드 자물쇠 방지
            backgroundColor: Colors.transparent,
            builder: (context) => const TransactionModal(),
          );
        },
        backgroundColor: const Color(0xFF10B981), // 청록색 액센트
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28.0),
      ),

      // 하단 탭 내비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: activeIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF343A40),
        unselectedItemColor: Colors.black38,
        selectedLabelStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10.0),
        iconSize: 20.0,
        elevation: 8,
        onTap: (index) {
          final tabs = ['home', 'history', 'report', 'setting'];
          state.switchTab(tabs[index]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: '내역',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'AI코칭',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
