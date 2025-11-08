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
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: TodayTipCard(
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
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber[600]),
                  const SizedBox(width: 8),
                  Text(
                    "All Tips",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...tips
                  .where((t) => t.id != todaysTip.id)
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) {
                    final index = entry.key;
                    final tip = entry.value;
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TipDetailScreen(tip: tip),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(
                                            tip.category,
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          tip.icon,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tip.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              tip.summary,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _getCategoryColor(
                                                  tip.category,
                                                ).withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                tip.category,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: _getCategoryColor(
                                                    tip.category,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey[400],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ],
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'budgeting':
        return Colors.blue;
      case 'tracking':
        return Colors.green;
      case 'planning':
        return Colors.purple;
      case 'goal setting':
        return Colors.orange;
      case 'shopping':
        return Colors.pink;
      case 'debt':
        return Colors.red;
      case 'saving':
        return Colors.teal;
      case 'tools':
        return Colors.indigo;
      case 'motivation':
        return Colors.amber;
      case 'seasonal':
        return Colors.deepOrange;
      default:
        return Colors.blue;
    }
  }
}
