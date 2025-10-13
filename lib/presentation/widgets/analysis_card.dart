import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/budget_provider.dart';

class AnalysisCard extends ConsumerWidget {
  const AnalysisCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetProvider);
    final remaining = budget.totalBudget - budget.spentAmount;
    final savingsRate = (remaining / budget.totalBudget * 100).clamp(0, 100).toStringAsFixed(1);
    final averageExpense = (budget.expenses.isNotEmpty
        ? budget.spentAmount / budget.expenses.length
        : 0).toStringAsFixed(2);
    final topCategory = budget.topCategory ?? 'N/A';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Left Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStat('Total Budget', '${budget.totalBudget.toStringAsFixed(2)} ETB'),
                  _buildStat('Spent', '${budget.spentAmount.toStringAsFixed(2)} ETB'),
                  _buildStat('Remaining', '${remaining.toStringAsFixed(2)} ETB'),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStat('Top Category', topCategory),
                  _buildStat('Avg Expense', '$averageExpense ETB'),
                  _buildStat('Savings Rate', '$savingsRate%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}