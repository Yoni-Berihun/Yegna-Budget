import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/nav_provider.dart';
import '../analysis/analysis_screen.dart';
import '../settings/settings_screen.dart';
import '../splitter/splitter_screen.dart';
import '../tips/financial_tips_screen.dart';
import '../../widgets/fancy_bottom_nav.dart';
import 'home_content.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navProvider);

    final tabs = [
      const HomeContent(),
      const FinancialTipsScreen(), // no tips argument
      const AnalysisScreen(),
      const SplitterScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: FancyBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navProvider.notifier).setIndex(index);
        },
      ),
      body: tabs[currentIndex],
    );
  }
}
