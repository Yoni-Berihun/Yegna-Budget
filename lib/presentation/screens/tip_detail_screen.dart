import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../logic/providers/financial_tips_provider.dart';

class TipDetailScreen extends StatefulWidget {
  final FinancialTipModel tip;
  const TipDetailScreen({required this.tip, super.key});

  @override
  State<TipDetailScreen> createState() => _TipDetailScreenState();
}

class _TipDetailScreenState extends State<TipDetailScreen> {
  bool? wasHelpful;
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
            IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
          if (tip.shareable)
            IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tip.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(tip.imageUrl!),
              ),
            const SizedBox(height: 12),
            Text(
              tip.details,
              style: const TextStyle(fontSize: 16),
            ),
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
                    const Text(
                      'Was this helpful?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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