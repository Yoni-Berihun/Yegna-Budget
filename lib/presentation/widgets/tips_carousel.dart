import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/financial_tips_provider.dart';
import '../../../presentation/screens/tip_detail_screen.dart';

class TipsCarousel extends ConsumerStatefulWidget {
  const TipsCarousel({super.key});

  @override
  ConsumerState<TipsCarousel> createState() => _TipsCarouselState();
}

class _TipsCarouselState extends ConsumerState<TipsCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), _autoSlide);
  }

  void _autoSlide() {
    if (!mounted) return;
    final tips = ref.read(tipsFutureProvider).value; // ✅ fixed
    if (tips == null || tips.isEmpty) return;

    setState(() {
      _currentPage = (_currentPage + 1) % tips.length;
    });

    _controller.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(seconds: 4), _autoSlide);
  }

  @override
  Widget build(BuildContext context) {
    final tipsAsync = ref.watch(tipsFutureProvider); // ✅ fixed

    return tipsAsync.when(
      data: (tips) => SizedBox(
        height: 160,
        child: PageView.builder(
          itemCount: tips.length,
          controller: _controller,
          itemBuilder: (context, index) {
            final tip = tips[index];
            return Card(
              color: Colors.blue[50],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(_getIcon(tip.icon),
                        size: 32, color: Colors.blueAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tip.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(tip.summary,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87)),
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading tips: $e'),
    );
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
}