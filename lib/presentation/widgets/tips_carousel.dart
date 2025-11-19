import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yegna_budget/data/models/financial_tip_model.dart';
import 'package:yegna_budget/data/models/icon_mapper.dart';
import 'package:yegna_budget/logic/providers/financial_tips_provider.dart';
import 'package:yegna_budget/presentation/screens/tips/tip_detail_screen.dart';

class TipsCarousel extends ConsumerStatefulWidget {
  const TipsCarousel({super.key});

  @override
  ConsumerState<TipsCarousel> createState() => _TipsCarouselState();
}

class _TipsCarouselState extends ConsumerState<TipsCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  bool _autoSliding = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final page = _controller.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
    Future.delayed(const Duration(seconds: 4), _autoSlide);
  }

  @override
  void dispose() {
    _autoSliding = false;
    _controller.dispose();
    super.dispose();
  }

  void _autoSlide() {
    if (!mounted || !_autoSliding) return;
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
      data: (tips) {
        if (tips.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(child: Text('No tips available')),
          );
        }
        return Column(
          children: [
            SizedBox(
              height: 190,
              child: PageView.builder(
                itemCount: tips.length,
                controller: _controller,
                itemBuilder: (context, index) {
                  final tip = tips[index];
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.9, end: isActive ? 1.0 : 0.9),
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: _TipCard(
                            tip: tip,
                            color: _getCategoryColor(tip.category),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TipDetailScreen(tip: tip),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                tips.length,
                (index) {
                  final active = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: active ? 26 : 10,
                    decoration: BoxDecoration(
                      color: active
                          ? _getCategoryColor(tips[_currentPage].category)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SizedBox(
        height: 180,
        child: Center(child: Text('Error loading tips: $e')),
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
        return Colors.blueGrey;
    }
  }
}

class _TipCard extends StatelessWidget {
  final FinancialTipModel tip;
  final Color color;
  final VoidCallback onTap;

  const _TipCard({
    required this.tip,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.12),
                color.withOpacity(0.05),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _LeadingVisual(
                color: color,
                iconSpec: tip.icon,
                imageAsset: tip.imageAsset,
                imageUrl: tip.imageUrl,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tip.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color.darken(0.1),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tip.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color.darken(0.1),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: color.darken(0.1),
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
    );
  }
}

class _LeadingVisual extends StatelessWidget {
  final Color color;
  final dynamic iconSpec;
  final String? imageAsset;
  final String? imageUrl;

  const _LeadingVisual({
    required this.color,
    required this.iconSpec,
    required this.imageAsset,
    required this.imageUrl,
  });

  bool _isSvg(dynamic spec) {
    if (spec == null) return false;
    if (spec is String) return spec.toLowerCase().endsWith('.svg');
    if (spec is Map && spec['asset'] is String) {
      return (spec['asset'] as String).toLowerCase().endsWith('.svg');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (imageAsset != null && imageAsset!.isNotEmpty) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          imageAsset!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackIcon(),
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackIcon(),
        ),
      );
    } else {
      try {
        // Do not override color for SVG (retain intrinsic colors).
        child = _isSvg(iconSpec)
            ? buildMappedIcon(iconSpec, size: 36)
            : buildMappedIcon(iconSpec, size: 36, color: color.darken(0.05));
      } catch (_) {
        child = _fallbackIcon();
      }
    }

    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _fallbackIcon() => Icon(Icons.lightbulb, color: color.darken(0.05), size: 36);
}

extension _ColorShade on Color {
  Color darken(double amount) {
    final f = 1 - amount;
    return Color.fromARGB(
      alpha,
      (red * f).round(),
      (green * f).round(),
      (blue * f).round(),
    );
  }
}