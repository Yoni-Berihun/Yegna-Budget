import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:abushakir/abushakir.dart';
import '../../../logic/providers/user_provider.dart';
import '../../../logic/providers/budget_provider.dart';
import '../../../logic/providers/theme_provider.dart';
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
    // Initialize with current Gregorian date converted to Ethiopian
    _selectedDate = EtDatetime.fromMillisecondsSinceEpoch(
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  void _pickDate(BuildContext context) async {
    final picked = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EthiopianCalendarPage(initialDate: _selectedDate),
      ),
    );

    if (picked != null && picked is EtDatetime) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(userNameProvider);
    final displayName = name.isEmpty ? 'User' : name;
    final budget = ref.watch(budgetProvider);
    final progress = budget.progress;
    final remaining = budget.remaining;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final formattedDate = "${_selectedDate.monthGeez} ${_selectedDate.day}";

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _pickDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(formattedDate),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                    DropdownButton<String>(
                      underline: const SizedBox(),
                      icon: const Icon(Icons.language),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('EN')),
                        DropdownMenuItem(value: 'am', child: Text('አማ')),
                      ],
                      onChanged: (val) {},
                    ),
                    IconButton(
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                      onPressed: () {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    const AnimatedHandWave(size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'ሰላም $displayName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Selam $displayName',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Budget Card
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, animatedProgress, child) {
                  return Card(
                    elevation: 8,
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
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TweenAnimationBuilder<double>(
                                        tween: Tween(
                                          begin: 0.0,
                                          end: animatedProgress,
                                        ),
                                        duration: const Duration(
                                          milliseconds: 800,
                                        ),
                                        curve: Curves.easeOutBack,
                                        builder: (context, value, child) {
                                          return CircularPercentIndicator(
                                            radius: 70,
                                            lineWidth: 12,
                                            percent: value.clamp(0.0, 1.0),
                                            center: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${(value * 100).toStringAsFixed(0)}%',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                  ),
                                                ),
                                                Text(
                                                  'Used',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            progressColor:
                                                animatedProgress > 0.8
                                                ? Colors.red
                                                : animatedProgress > 0.5
                                                ? Colors.orange
                                                : Colors.green,
                                            backgroundColor: Colors.grey[200]!,
                                            animation: true,
                                            animateFromLastPercent: true,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Spent',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TweenAnimationBuilder<double>(
                                        tween: Tween(
                                          begin: 0.0,
                                          end: budget.spentAmount,
                                        ),
                                        duration: const Duration(
                                          milliseconds: 800,
                                        ),
                                        curve: Curves.easeOut,
                                        builder: (context, value, child) {
                                          return FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              '${value.toStringAsFixed(0)} ETB',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red[500],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Remaining',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: TweenAnimationBuilder<double>(
                                              tween: Tween(
                                                begin: 0.0,
                                                end: remaining,
                                              ),
                                              duration: const Duration(
                                                milliseconds: 800,
                                              ),
                                              curve: Curves.easeOut,
                                              builder: (context, value, child) {
                                                return FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    budget.showRemaining
                                                        ? '${value.toStringAsFixed(0)} ETB'
                                                        : '******',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green[600],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              budget.showRemaining
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              size: 20,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              ref
                                                  .read(budgetProvider.notifier)
                                                  .toggleShowRemaining();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
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
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Budget'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Auto deducted from expenses',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                '💡 Financial Tips',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const TipsCarousel(),
              const SizedBox(height: 24),
              const Text(
                '📊 Budget Analysis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const AnalysisCard(),
            ],
          ),
        ),
        floatingActionButton: _AnimatedFAB(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
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
      ),
    );
  }
}
// ----------------- Edit Budget Bottom Sheet -----------------

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
    final currentBudget = ref.read(budgetProvider).totalBudget;
    _controller.text = currentBudget.toStringAsFixed(0);
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

            // Input field
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'New Budget Amount (ETB)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Period toggle
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

            // Quick suggestions
            Wrap(
              spacing: 8,
              children: [
                for (var amount in [1000, 2000, 3000, 5000, 8000])
                  ActionChip(
                    label: Text('$amount'),
                    onPressed: () {
                      _controller.text = amount.toString();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Tips
            const Text(
              '💡 Budget Tips:\n'
              '• Include all essential expenses\n'
              '• Add 10–15% buffer for unexpected costs\n'
              '• Review and adjust monthly\n'
              '• Consider Ethiopian holidays and events',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final entered = double.tryParse(_controller.text);
                    if (entered != null && entered > 0) {
                      // Update provider (ensure BudgetNotifier has updateBudget)
                      ref.read(budgetProvider.notifier).updateBudget(entered);

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Budget updated successfully! ✅'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid amount ❌'),
                        ),
                      );
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

// Animated Floating Action Button with Pulse Effect
class _AnimatedFAB extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedFAB({required this.onTap});

  @override
  State<_AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<_AnimatedFAB>
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

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(
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
              // Pulsing shadow effect
              Transform.scale(
                scale: 1.0 + (_pulseAnimation.value * 0.3),
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
              // Main button
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 3,
                        offset: const Offset(0, 5),
                      ),
                    ],
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
