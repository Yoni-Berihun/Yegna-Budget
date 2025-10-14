import 'package:flutter/material.dart';
import 'package:yegna_budget/data/models/financial_tip_model.dart';

class TodayTipCard extends StatelessWidget {
  final FinancialTipModel tip;
  final VoidCallback onChallengeMe;
  final VoidCallback onReadMore;

  const TodayTipCard({
    super.key,
    required this.tip,
    required this.onChallengeMe,
    required this.onReadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Tip", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(tip.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(tip.summary, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.bolt),
                    label: const Text("Challenge me"),
                    onPressed: onChallengeMe,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.menu_book),
                    label: const Text("Read more"),
                    onPressed: onReadMore,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}