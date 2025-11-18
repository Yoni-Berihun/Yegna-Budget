import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:yegna_budget/data/models/financial_tip_model.dart';
import 'package:yegna_budget/logic/providers/financial_tips_provider.dart';

class TipQuizSheet extends ConsumerStatefulWidget {
  final FinancialTipModel? tip;
  const TipQuizSheet({super.key, this.tip});

  @override
  ConsumerState<TipQuizSheet> createState() => _TipQuizSheetState();
}

class _TipQuizSheetState extends ConsumerState<TipQuizSheet> {
  int? _selectedIndex;
  bool _answered = false;
  bool _isCorrect = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final challengeAsync = ref.watch(dailyChallengeProvider);

    return challengeAsync.when(
      data: (quiz) {
        if (quiz == null) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                "No challenge available today.",
                style: theme.textTheme.bodyLarge,
              ),
            ),
          );
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, controller) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.all(24),
                      children: [
                        // Header
                        Row(
                          children: [
                            Icon(
                              Icons.bolt,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Daily Challenge",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Test your knowledge!",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Question
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            quiz.question,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Quiz options
                        ...List.generate(quiz.options.length, (i) {
                          final isSelected = _selectedIndex == i;
                          final isCorrect = _answered && i == quiz.correctIndex;
                          final isWrong =
                              _answered && isSelected && i != quiz.correctIndex;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              elevation: isSelected ? 4 : 1,
                              color: isCorrect
                                  ? Colors.green.withOpacity(0.2)
                                  : isWrong
                                  ? Colors.red.withOpacity(0.2)
                                  : theme.cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  quiz.options[i],
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                leading: Radio<int>(
                                  value: i,
                                  groupValue: _selectedIndex,
                                  onChanged: _answered
                                      ? null
                                      : (val) => setState(
                                          () => _selectedIndex = val,
                                        ),
                                ),
                                onTap: _answered
                                    ? null
                                    : () => setState(() => _selectedIndex = i),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 24),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _selectedIndex == null || _answered
                                ? null
                                : () async {
                                    setState(() {
                                      _answered = true;
                                      _isCorrect =
                                          _selectedIndex == quiz.correctIndex;
                                    });

                                    if (_isCorrect) {
                                      // Save challenge completion
                                      // await DailyTipsService.saveChallengeDate();
                                    }

                                    if (mounted) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) => AlertDialog(
                                          backgroundColor:
                                              theme.scaffoldBackgroundColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _isCorrect
                                                  ? Lottie.asset(
                                                      'assets/lottie/Success.json',
                                                      repeat: false,
                                                      height: 120,
                                                    )
                                                  : Lottie.asset(
                                                      'assets/lottie/wrong.json',
                                                      repeat: false,
                                                      height: 120,
                                                    ),
                                              const SizedBox(height: 16),
                                              Text(
                                                _isCorrect
                                                    ? "🎉 Correct! Well done!"
                                                    : "😅 Oops, try again tomorrow!",
                                                style: theme
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: theme
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.color,
                                                    ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _isCorrect
                                                    ? "You're on the right track!"
                                                    : "Don't worry, there's always tomorrow!",
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color
                                                          ?.withOpacity(0.7),
                                                    ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                if (_isCorrect) {
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _answered
                                  ? (_isCorrect
                                        ? "✓ Answered Correctly"
                                        : "Try Again Tomorrow")
                                  : "Submit Answer",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: Text(
            "Error loading challenge: $e",
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
