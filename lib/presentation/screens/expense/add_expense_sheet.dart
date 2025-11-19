import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/budget_provider.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController(); // now optional
  final TextEditingController _descriptionController = TextEditingController();

  String _category = 'Food';
  String _reasonType = 'Necessity';

  final List<String> _categories = [
    'Food',
    'Transport',
    'Books and Supplies',
    'Entertainment',
    'Health and Medical',
    'Clothing',
    'Other',
  ];

  final List<String> _reasonTypes = [
    'Necessity',
    'Impulse',
    'Planned',
    'Emergency',
    'Social',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_circle,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Expense',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Amount (required)
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount in ETB',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          color: _getCategoryColor(category),
                        ),
                        const SizedBox(width: 8),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _category = val ?? 'Food'),
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
              ),
              const SizedBox(height: 16),

              // Reason Type
              DropdownButtonFormField<String>(
                value: _reasonType,
                items: _reasonTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          _getReasonTypeIcon(type),
                          color: _getReasonTypeColor(type),
                        ),
                        const SizedBox(width: 8),
                        Text(type),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _reasonType = val ?? 'Necessity'),
                decoration: InputDecoration(
                  labelText: 'Reason Type',
                  hintText: 'Why did you spend?',
                  prefixIcon: const Icon(Icons.help_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
              ),
              const SizedBox(height: 16),

              // Reason (Optional now)
              TextField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'Reason (Optional)',
                  hintText: 'Brief reason (can leave empty)',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Description (Optional)
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add details about this expense...',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final amount = double.tryParse(_amountController.text.trim());
                        final reason = _reasonController.text.trim(); // optional

                        if (amount != null && amount > 0) {
                          try {
                            await ref.read(budgetProvider.notifier).addExpense(
                                  amount: amount,
                                  category: _category,
                                  reasonType: _reasonType,
                                  // pass empty string or null depending on your model (using empty to avoid breaking)
                                  reason: reason.isEmpty ? '' : reason,
                                  description: _descriptionController.text.trim().isEmpty
                                      ? null
                                      : _descriptionController.text.trim(),
                                  // receipt removed – pass null if parameter exists
                                  receiptPath: null,
                                );

                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text('Expense added: ETB ${amount.toStringAsFixed(0)} ✅'),
                                    ],
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to add expense: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Please enter a valid amount ❌'),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Add Expense'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Books and Supplies':
        return Icons.book;
      case 'Entertainment':
        return Icons.movie;
      case 'Health and Medical':
        return Icons.medical_services;
      case 'Clothing':
        return Icons.checkroom;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Books and Supplies':
        return Colors.purple;
      case 'Entertainment':
        return Colors.pink;
      case 'Health and Medical':
        return Colors.red;
      case 'Clothing':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getReasonTypeIcon(String type) {
    switch (type) {
      case 'Necessity':
        return Icons.check_circle;
      case 'Impulse':
        return Icons.flash_on;
      case 'Planned':
        return Icons.event_note;
      case 'Emergency':
        return Icons.warning;
      case 'Social':
        return Icons.people;
      default:
        return Icons.help_outline;
    }
  }

  Color _getReasonTypeColor(String type) {
    switch (type) {
      case 'Necessity':
        return Colors.green;
      case 'Impulse':
        return Colors.orange;
      case 'Planned':
        return Colors.blue;
      case 'Emergency':
        return Colors.red;
      case 'Social':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
