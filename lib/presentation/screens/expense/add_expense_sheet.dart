import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String _category = 'Food';

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
              '➕ Add Expense',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (ETB)',
                prefixText: 'ETB ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _category,
              items: const [
                DropdownMenuItem(value: 'Food', child: Text('Food')),
                DropdownMenuItem(value: 'Transport', child: Text('Transport')),
                DropdownMenuItem(value: 'Rent', child: Text('Rent')),
              ],
              onChanged: (val) => setState(() => _category = val ?? 'Food'),
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Why did you spend?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Tips
            const Text(
              '💡 Expense Tips:\n'
              '• Be honest and specific\n'
              '• Add receipts if possible\n'
              '• Categorize for better tracking\n'
              '• Review weekly to spot patterns',
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
                    final amount = double.tryParse(_amountController.text);
                    final reason = _reasonController.text.trim();

                    if (amount != null && amount > 0 && reason.isNotEmpty) {
                      // TODO: Save expense to provider or database
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Expense added: ETB $amount ✅'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter valid amount and reason ❌'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Save Expense'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}