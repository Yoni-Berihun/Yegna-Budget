import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:abushakir/abushakir.dart';

import '../../../logic/providers/user_provider.dart';
import '../../../logic/providers/budget_provider.dart';
import '../../../logic/providers/theme_provider.dart';
import '../../../presentation/widgets/tips_carousel.dart';
import '../../widgets/analysis_card.dart';
import '../calender/ethiopian_calender_page.dart';

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
    final progress = budget.spentAmount / budget.totalBudget;
    final percentage = (progress * 100).toStringAsFixed(0);
    final remaining = budget.totalBudget - budget.spentAmount;
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
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                      ),
                      onPressed: () {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('👋', style: TextStyle(fontSize: 22)),
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
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularPercentIndicator(
                                  radius: 60,
                                  lineWidth: 10,
                                  percent: progress.clamp(0.0, 1.0),
                                  center: Text('$percentage%'),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Remaining',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      budget.showRemaining
                                          ? '${remaining.toStringAsFixed(2)} ETB'
                                          : '******',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        budget.showRemaining
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        size: 20,
                                      ),
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
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                builder: (context) {
                                  // 👇 Keep your existing EditBudgetSheet implementation
                                  return const EditBudgetSheet();
                                },
                              );
                            },
                            child: const Text('Edit Budget'),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Auto deducted from recent expenses',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
