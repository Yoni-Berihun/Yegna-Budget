import 'package:flutter/material.dart';
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

  final List<String> _options = const [
    'Save a small, consistent amount daily',
    'Spend first, save what is left',
    'Only save when income increases',
    'Use loans for daily expenses frequently',
  ];

  final int _correctIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
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
              Text("Challenge: ${widget.tip.title}",
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...List.generate(_options.length, (i) {
                final isSelected = _selectedIndex == i;
                final isCorrect = _answered && i == _correctIndex;
                final isWrong = _answered && isSelected && i != _correctIndex;

                return ListTile(
                  title: Text(_options[i]),
                  leading: Radio<int>(
                    value: i,
                    groupValue: _selectedIndex,
                    onChanged: _answered ? null : (val) => setState(() => _selectedIndex = val),
                  ),
                  tileColor: isCorrect
                      ? Colors.green.withOpacity(0.2)
                      : isWrong
                          ? Colors.red.withOpacity(0.2)
                          : null,
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectedIndex == null
                    ? null
                    : () {
                        setState(() => _answered = true);
                        Future.delayed(const Duration(seconds: 1), () {
                          if (mounted) Navigator.pop(context);
                        });
                      },
                child: Text(_answered ? "Great job!" : "Submit"),
              ),
            ],
          ),
        );
      },
    );
  }
}