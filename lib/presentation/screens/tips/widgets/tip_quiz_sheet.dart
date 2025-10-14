import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:yegna_budget/data/models/financial_tip_model.dart';

class TipQuizSheet extends StatefulWidget {
  final FinancialTipModel tip;
  const TipQuizSheet({super.key, required this.tip});

  @override
  State<TipQuizSheet> createState() => _TipQuizSheetState();
}

class _TipQuizSheetState extends State<TipQuizSheet> {
  int? _selectedIndex;
  bool _answered = false;
  bool _isCorrect = false;

  @override
  Widget build(BuildContext context) {
    final quiz = widget.tip.quiz;
    if (quiz == null) {
      return const Center(child: Text("No quiz available for this tip."));
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      builder: (context, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: controller,
            children: [
              Text(
                quiz.question,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              // Quiz options
              ...List.generate(quiz.options.length, (i) {
                final isSelected = _selectedIndex == i;
                final isCorrect = _answered && i == quiz.correctIndex;
                final isWrong = _answered && isSelected && i != quiz.correctIndex;

                return ListTile(
                  title: Text(quiz.options[i]),
                  leading: Radio<int>(
                    value: i,
                    groupValue: _selectedIndex,
                    onChanged: _answered
                        ? null
                        : (val) => setState(() => _selectedIndex = val),
                  ),
                  tileColor: isCorrect
                      ? Colors.green.withOpacity(0.2)
                      : isWrong
                          ? Colors.red.withOpacity(0.2)
                          : null,
                );
              }),

              const SizedBox(height: 16),

              // Submit button
              ElevatedButton(
                onPressed: _selectedIndex == null
                    ? null
                    : () {
                        setState(() {
                          _answered = true;
                          _isCorrect = _selectedIndex == quiz.correctIndex;
                        });

                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _isCorrect
                                    ? Lottie.asset(
                                        'assets/animations/success.json',
                                        repeat: false,
                                        height: 120,
                                      )
                                    : Lottie.asset(
                                        'assets/animations/error.json',
                                        repeat: false,
                                        height: 120,
                                      ),
                                const SizedBox(height: 12),
                                Text(
                                  _isCorrect
                                      ? "🎉 Correct! Well done."
                                      : "😅 Oops, try again tomorrow!",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                child: Text(_answered ? "Answered" : "Submit"),
              ),
            ],
          ),
        );
      },
    );
  }
}