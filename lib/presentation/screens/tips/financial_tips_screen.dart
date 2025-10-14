import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yegna_budget/logic/providers/financial_tips_provider.dart';
import 'widgets/today_tip_card.dart';
import 'widgets/tip_quiz_sheet.dart';
import 'tip_detail_screen.dart';

class FinancialTipsScreen extends ConsumerWidget {
  const FinancialTipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(tipsFutureProvider);
    final dailyTip = ref.watch(dailyTipProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("💡 Financial Tips")),
      body: tipsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (tips) {
          if (tips.isEmpty) {
            return const Center(child: Text("No tips available"));
          }

          final todaysTip = dailyTip ?? tips.first;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TodayTipCard(
                tip: todaysTip,
                onChallengeMe: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => TipQuizSheet(tip: todaysTip),
                  );
                },
                onReadMore: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TipDetailScreen(tip: todaysTip),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text("Recent Tips",
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...tips.where((t) => t.id != todaysTip.id).map(
                (t) => Card(
                  child: ListTile(
                    leading: Text(t.icon, style: const TextStyle(fontSize: 22)),
                    title: Text(t.title),
                    subtitle: Text(
                      t.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TipDetailScreen(tip: t),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}