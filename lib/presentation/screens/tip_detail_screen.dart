import 'package:flutter/material.dart';
import 'package:yegna_budget/data/models/financial_tip_model.dart';

class TipDetailScreen extends StatelessWidget {
  final FinancialTipModel tip;
  const TipDetailScreen({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tip.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (tip.imageUrl != null && tip.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(tip.imageUrl!, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Text(tip.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(tip.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Chip(
                  label: Text(tip.category),
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tip.summary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 16),
            Text(tip.details, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Row(
              children: [
                if (tip.shareable)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text("Share"),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Share feature coming soon!")),
                        );
                      },
                    ),
                  ),
                if (tip.shareable) const SizedBox(width: 12),
                if (tip.savable)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.bookmark),
                      label: const Text("Save"),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Saved to your tips!")),
                        );
                      },
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