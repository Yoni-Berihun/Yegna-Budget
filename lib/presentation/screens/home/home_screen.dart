import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/user_provider.dart';
import '../../../logic/providers/nav_provider.dart';
import '../analysis/analysis_screen.dart';
import '../settings/settings_screen.dart';
import '../splitter/splitter_screen.dart';
import '../tips/financial_tips_screen.dart';
import '../../../data/models/financial_tip_model.dart';
import 'home_content.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(userNameProvider);
    final currentIndex = ref.watch(navProvider);

    final demoTips = [
      FinancialTipModel(
        id: '1',
        title: 'Start small, stay consistent',
        summary: 'Save 10 ETB daily. Tiny habits compound.',
        details: 'Consistency beats intensity. Begin with 10 ETB daily...',
        category: 'Saving',
        shareable: true,
        savable: true,
        icon: '💡',
        isDaily: true,
      ),
      FinancialTipModel(
        id: '2',
        title: 'Envelope budgeting',
        summary: 'Divide money into envelopes: Essentials, Future You, Generosity.',
        details: 'Envelope budgeting helps restrain impulse spending...',
        category: 'Budgeting',
        shareable: true,
        savable: true,
        icon: '📦',
      ),
    ];

    final tabs = [
      const HomeContent(),
      FinancialTipsScreen(tips: demoTips),
      const AnalysisScreen(),
      const SplitterScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF973C00),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 249, 220, 146),
        unselectedItemColor: const Color.fromARGB(179, 233, 231, 231),
        onTap: (index) {
          ref.read(navProvider.notifier).state = index;
        },
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.tips_and_updates), label: 'FinTips'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Splitter'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      body: Center(child: tabs[currentIndex]),
    );
  }
}