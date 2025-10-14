import 'package:flutter/material.dart';
import 'package:yegna_budget/data/models/financial_tip_model.dart';
import 'widgets/today_tip_card.dart';
import 'widgets/tip_quiz_sheet.dart';
import 'tip_detail_screen.dart';

class FinancialTipsScreen extends StatelessWidget {
  final List<FinancialTipModel> tips;

  const FinancialTipsScreen({super.key, required this.tips});

  @override
  Widget build(BuildContext context) {
    final bool hasTips = tips.isNotEmpty;

    // If you added `isDaily` to the model, uncomment the block below and remove the fallback:
    // final FinancialTipModel? todaysTip = hasTips
    //     ? tips.firstWhere(
    //         (t) => t.isDaily == true,
    //         orElse: () => tips.first,
    //       )
    //     : null;

    // Fallback if `isDaily` is NOT in your model yet:
    final FinancialTipModel? todaysTip = hasTips ? tips.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("💡 Financial Tips"),
        centerTitle: true,
      ),
      body: hasTips && todaysTip != null
          ? ListView(
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
                Text(
                  "Recent Tips",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...tips.skip(1).map(
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
                          MaterialPageRoute(builder: (_) => TipDetailScreen(tip: t)),
                        );
                      },
                    ),
                  ),
                ),
              ],
            )
          : _EmptyState(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 40),
            const SizedBox(height: 12),
            Text(
              "No tips available yet",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Add tips to your data source and come back.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}