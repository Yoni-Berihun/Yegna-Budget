import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/budget_provider.dart';

class AnalysisCard extends ConsumerWidget {
  const AnalysisCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetProvider);
    final notifier = ref.read(budgetProvider.notifier);

    final remaining = budget.remaining;
    final savingsRate = budget.savingsRate;
    final averageExpense = notifier.getAverageExpense();
    final topCategory = notifier.topCategory ?? 'N/A';
    final categoryBreakdown = notifier.categoryBreakdown;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    Colors.blue.shade900.withOpacity(0.3),
                    Colors.purple.shade900.withOpacity(0.3),
                  ]
                : [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Budget Analysis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildAnimatedStat(
                      context,
                      'Total Budget',
                      '${budget.totalBudget.toStringAsFixed(0)} ETB',
                      Icons.account_balance_wallet,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAnimatedStat(
                      context,
                      'Spent',
                      '${budget.spentAmount.toStringAsFixed(0)} ETB',
                      Icons.trending_down,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAnimatedStat(
                      context,
                      'Remaining',
                      '${remaining.toStringAsFixed(0)} ETB',
                      Icons.savings,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAnimatedStat(
                      context,
                      'Savings Rate',
                      '${savingsRate.toStringAsFixed(1)}%',
                      Icons.trending_up,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAnimatedStat(
                      context,
                      'Top Category',
                      topCategory,
                      Icons.category,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAnimatedStat(
                      context,
                      'Avg Expense',
                      '${averageExpense.toStringAsFixed(0)} ETB',
                      Icons.receipt,
                      Colors.teal,
                    ),
                  ),
                ],
              ),
              if (categoryBreakdown.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Category Breakdown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color?.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                ...categoryBreakdown.entries.map((entry) {
                  final percentage = (entry.value / budget.spentAmount * 100);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${entry.value.toStringAsFixed(0)} ETB (${percentage.toStringAsFixed(1)}%)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: percentage / 100),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]!
                                  : Colors.grey[200]!,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getCategoryColor(entry.key),
                              ),
                              minHeight: 6,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0.0,
              end:
                  double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                  0.0,
            ),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, animatedValue, child) {
              if (value.contains('ETB')) {
                return Text(
                  '${animatedValue.toStringAsFixed(0)} ETB',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                );
              } else if (value.contains('%')) {
                return Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                );
              } else {
                return Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'rent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
