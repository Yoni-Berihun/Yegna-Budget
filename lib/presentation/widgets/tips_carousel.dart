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
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page?.round() ?? 0;
      });
    });
    Future.delayed(const Duration(seconds: 4), _autoSlide);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _autoSlide() {
    if (!mounted) return;
    final tips = ref.read(tipsFutureProvider).value;
    if (tips == null || tips.isEmpty) return;

    final nextPage = (_currentPage + 1) % tips.length;
    _controller.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );

    Future.delayed(const Duration(seconds: 5), _autoSlide);
  }

  @override
  Widget build(BuildContext context) {
    final tipsAsync = ref.watch(tipsFutureProvider);

    return tipsAsync.when(
      data: (tips) => Column(
        children: [
          SizedBox(
            height: 180,
            child: PageView.builder(
              itemCount: tips.length,
              controller: _controller,
              itemBuilder: (context, index) {
                final tip = tips[index];
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: isActive ? 1.0 : 0.8),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Card(
                          elevation: isActive ? 8 : 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _getCategoryColor(tip.category).withOpacity(0.1),
                                  _getCategoryColor(tip.category).withOpacity(0.05),
                                ],
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TipDetailScreen(tip: tip),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(tip.category)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getIcon(tip.icon),
                                        size: 36,
                                        color: _getCategoryColor(tip.category),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            tip.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: _getCategoryColor(
                                                tip.category,
                                              ),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            tip.summary,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
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
                                              const Spacer(),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 14,
                                                color: _getCategoryColor(
                                                  tip.category,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              tips.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentPage == index
                      ? _getCategoryColor(tips[_currentPage].category)
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
        ],
      ),
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SizedBox(
        height: 180,
        child: Center(
          child: Text('Error loading tips: $e'),
        ),
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