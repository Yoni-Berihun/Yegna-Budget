import 'package:flutter/material.dart';
import '../../../logic/providers/financial_tips_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/screens/tip_detail_screen.dart';

class TipsCarousel extends ConsumerWidget {
  const TipsCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(financialTipsProvider);

    return tipsAsync.when(
      data: (tips) => SizedBox(
        height: 140,
        child: PageView.builder(
          itemCount: tips.length,
          controller: PageController(viewportFraction: 0.9),
          itemBuilder: (context, index) {
            final tip = tips[index];
            return Card(
              color: Colors.blue[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${tip.icon} ${tip.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(tip.summary, style: const TextStyle(fontSize: 13)),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TipDetailScreen(tip: tip),
                            ),
                          );
                        },
                        child: const Text('Read More'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error loading tips: $e'),
    );
  }
}