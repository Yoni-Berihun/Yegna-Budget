import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/financial_tip_model.dart';

class TipDetailScreen extends StatefulWidget {
  final FinancialTipModel tip;
  const TipDetailScreen({required this.tip, super.key});

  @override
  State<TipDetailScreen> createState() => _TipDetailScreenState();
}

class _TipDetailScreenState extends State<TipDetailScreen> {
  bool? wasHelpful;
  bool isBookmarked = false;
  final TextEditingController _feedbackController = TextEditingController();

  void _submitFeedback() {
    final feedbackBox = Hive.box('feedbackBox');
    final feedbackText = _feedbackController.text.trim();

    feedbackBox.add({
      'tipId': widget.tip.id,
      'helpful': wasHelpful,
      'comment': wasHelpful == false ? feedbackText : null,
      'timestamp': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks for your feedback!')),
    );

    setState(() {
      wasHelpful = null;
      _feedbackController.clear();
    });
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'savings':
        return Icons.savings;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'pie_chart':
        return Icons.pie_chart;
      case 'flag':
        return Icons.flag;
      case 'credit_card':
        return Icons.credit_card;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'apps':
        return Icons.apps;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'event':
        return Icons.event;
      default:
        return Icons.lightbulb;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tip = widget.tip;

    return Scaffold(
      appBar: AppBar(
        title: Text(tip.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (tip.savable)
            IconButton(
              icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
              onPressed: () {
                setState(() => isBookmarked = !isBookmarked);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isBookmarked ? 'Saved!' : 'Removed from bookmarks')),
                );
              },
            ),
          if (tip.shareable)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                Share.share('${tip.title}\n\n${tip.details}');
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_getIcon(tip.icon), size: 40, color: Colors.blueAccent),
            const SizedBox(height: 12),
            if (tip.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(tip.imageUrl!, fit: BoxFit.cover),
              )
            else
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('No image available')),
              ),
            const SizedBox(height: 12),
            Text(tip.details, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            // Feedback Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Was this helpful?', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          icon: const Icon(Icons.thumb_up),
                          label: const Text('Yes, helpful!'),
                          onPressed: () => setState(() => wasHelpful = true),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          icon: const Icon(Icons.thumb_down),
                          label: const Text('Not helpful'),
                          onPressed: () => setState(() => wasHelpful = false),
                        ),
                      ],
                    ),
                    if (wasHelpful == false) ...[
                      const SizedBox(height: 12),
                      const Text('Tell us what was missing:'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _feedbackController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Your suggestions...',
                        ),
                      ),
                    ],
                    if (wasHelpful != null) ...[
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _submitFeedback,
                        child: const Text('Submit Feedback'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}