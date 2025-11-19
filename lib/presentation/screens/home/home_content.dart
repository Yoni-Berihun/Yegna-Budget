import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:abushakir/abushakir.dart';

import '../../../logic/providers/budget_provider.dart';
import '../../../logic/providers/theme_provider.dart';
import '../../../logic/providers/user_provider.dart';
import '../../../presentation/widgets/tips_carousel.dart';
import '../../widgets/analysis_card.dart';
import '../../widgets/animated_hand_wave.dart';
import '../calender/ethiopian_calender_page.dart';
import '../expense/add_expense_sheet.dart';

class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({super.key});

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent> {
  late EtDatetime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = EtDatetime.fromMillisecondsSinceEpoch(
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EthiopianCalendarPage(initialDate: _selectedDate),
      ),
    );
    if (picked != null && picked is EtDatetime) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(userNameProvider);
    final budget = ref.watch(budgetProvider);
    final formattedDate = '${_selectedDate.monthGeez} ${_selectedDate.day}';
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverToBoxAdapter(
                child: HeaderCard(
                  displayName: userName.isEmpty ? 'User' : userName,
                  formattedDate: formattedDate,
                  isDarkMode: isDarkMode,
                  onPickDate: () => _pickDate(context),
                  onToggleTheme: () =>
                      ref.read(themeModeProvider.notifier).toggleTheme(),
                  onSearchTap: () =>
                      _showMessage(context, 'Search is coming soon!'),
                  onLanguageTap: () =>
                      _showMessage(context, 'Language options coming soon!'),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              sliver: SliverToBoxAdapter(
                child: BudgetSummaryCard(
                  budget: budget,
                  onToggleVisibility: () async {
                    await ref
                        .read(budgetProvider.notifier)
                        .toggleShowRemaining();
                  },
                  onEditBudget: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => const EditBudgetSheet(),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SectionTitle(text: '💡 Financial Tips'),
                    SizedBox(height: 12),
                    TipsCarousel(),
                    SizedBox(height: 32),
                    SectionTitle(text: '📊 Budget Analysis'),
                    SizedBox(height: 12),
                    AnalysisCard(),
                    SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedFab(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: const AddExpenseSheet(),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class HeaderCard extends StatelessWidget {
  const HeaderCard({
    super.key,
    required this.displayName,
    required this.formattedDate,
    required this.isDarkMode,
    required this.onPickDate,
    required this.onToggleTheme,
    required this.onSearchTap,
    required this.onLanguageTap,
  });

  final String displayName;
  final String formattedDate;
  final bool isDarkMode;
  final VoidCallback onPickDate;
  final VoidCallback onToggleTheme;
  final VoidCallback onSearchTap;
  final VoidCallback onLanguageTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(formattedDate),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  IconButton(
                    onPressed: onSearchTap,
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(
                    onPressed: onLanguageTap,
                    icon: const Icon(Icons.language),
                  ),
                  IconButton(
                    onPressed: onToggleTheme,
                    icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const AnimatedHandWave(size: 35),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ሰላም $displayName',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selam $displayName',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Track your budget, add expenses, and keep your goals in sight.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetSummaryCard extends StatelessWidget {
  const BudgetSummaryCard({
    super.key,
    required this.budget,
    required this.onToggleVisibility,
    required this.onEditBudget,
  });

  final BudgetState budget;
  final VoidCallback onToggleVisibility;
  final VoidCallback onEditBudget;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: budget.progress),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CircularPercentIndicator(
                        radius: 70,
                        lineWidth: 12,
                        percent: animatedProgress.clamp(0.0, 1.0),
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(animatedProgress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Used',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        progressColor: animatedProgress > .8
                            ? Colors.red
                            : animatedProgress > .5
                            ? Colors.orange
                            : Colors.green,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Spent',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 6),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: budget.spentAmount),
                            duration: const Duration(milliseconds: 700),
                            builder: (context, value, _) {
                              return Text(
                                '${value.toStringAsFixed(0)} ETB',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Remaining',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: 0.0,
                                    end: budget.remaining,
                                  ),
                                  duration: const Duration(milliseconds: 700),
                                  builder: (context, value, _) {
                                    return FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        budget.showRemaining
                                            ? '${value.toStringAsFixed(0)} ETB'
                                            : '******',
                                        style: const TextStyle(
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: onToggleVisibility,
                                icon: Icon(
                                  budget.showRemaining
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onEditBudget,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Budget'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Auto deducted from your recorded expenses.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class EditBudgetSheet extends ConsumerStatefulWidget {
  const EditBudgetSheet({super.key});

  @override
  ConsumerState<EditBudgetSheet> createState() => _EditBudgetSheetState();
}

class _EditBudgetSheetState extends ConsumerState<EditBudgetSheet> {
  final TextEditingController _controller = TextEditingController();
  String _period = 'Monthly';

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(budgetProvider).totalBudget.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set New Budget',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'New Budget Amount (ETB)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Monthly'),
                  selected: _period == 'Monthly',
                  onSelected: (_) => setState(() => _period = 'Monthly'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Weekly'),
                  selected: _period == 'Weekly',
                  onSelected: (_) => setState(() => _period = 'Weekly'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final amount in [1000, 2000, 3000, 5000, 8000])
                  ActionChip(
                    label: Text('$amount ETB'),
                    onPressed: () => _controller.text = amount.toString(),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              ' Tips:\n Include essential expenses\n Keep a small buffer\n Review monthly\n Consider holidays & events',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final entered = double.tryParse(_controller.text);
                    if (entered == null || entered <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid amount '),
                        ),
                      );
                      return;
                    }
                    try {
                      await ref
                          .read(budgetProvider.notifier)
                          .updateBudget(entered);
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Budget updated successfully! '),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error updating budget: '),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Save Budget'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedFab extends StatefulWidget {
  const AnimatedFab({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<AnimatedFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _scaleAnimation = Tween(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _pulseAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1 + (_pulseAnimation.value * 0.3),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(
                          0.4 * (1 - _pulseAnimation.value),
                        ),
                        blurRadius: 20 + (_pulseAnimation.value * 10),
                        spreadRadius: 5 + (_pulseAnimation.value * 5),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
