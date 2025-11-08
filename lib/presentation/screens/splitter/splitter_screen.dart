import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/budget_provider.dart';

class SplitterScreen extends ConsumerStatefulWidget {
  const SplitterScreen({super.key});

  @override
  ConsumerState<SplitterScreen> createState() => _SplitterScreenState();
}

class _SplitterScreenState extends ConsumerState<SplitterScreen>
    with SingleTickerProviderStateMixin {
  double _amount = 0.0;
  int _numberOfPeople = 1;
  double _eachPersonPays = 0.0;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _updateCalculation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    setState(() {
      _eachPersonPays = _numberOfPeople > 0 ? _amount / _numberOfPeople : 0.0;
    });
    _animationController.forward(from: 0.0);
  }

  void _addToMyShare() {
    if (_amount <= 0 || _numberOfPeople <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount and number of people'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show expense sheet with pre-filled amount
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _SplitExpenseSheet(
          amount: _eachPersonPays,
          totalAmount: _amount,
          numberOfPeople: _numberOfPeople,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💰 Split Expense'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 4,
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
                      Colors.purple.withOpacity(0.1),
                      Colors.blue.withOpacity(0.1),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 48,
                      color: Colors.purple[600],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Split your expenses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Divide the bill equally among friends',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Amount Slider
            _buildSectionTitle('Total Amount (ETB)'),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: _amount),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Text(
                          '${value.toStringAsFixed(0)} ETB',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[600],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.purple,
                        inactiveTrackColor: Colors.purple[100],
                        thumbColor: Colors.purple,
                        overlayColor: Colors.purple.withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 12,
                        ),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _amount.clamp(0.0, 10000.0),
                        min: 0,
                        max: 10000,
                        divisions: 200,
                        label: '${_amount.toStringAsFixed(0)} ETB',
                        onChanged: (value) {
                          setState(() {
                            _amount = value;
                          });
                          _updateCalculation();
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickAmountButton(100),
                        _buildQuickAmountButton(500),
                        _buildQuickAmountButton(1000),
                        _buildQuickAmountButton(2000),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Number of People Slider
            _buildSectionTitle('Number of People'),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: _numberOfPeople.toDouble()),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people,
                              size: 32,
                              color: Colors.blue[600],
                            ),
                            const SizedBox(width: 12),
                            Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.blue,
                        inactiveTrackColor: Colors.blue[100],
                        thumbColor: Colors.blue,
                        overlayColor: Colors.blue.withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 12,
                        ),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _numberOfPeople.toDouble(),
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: '$_numberOfPeople people',
                        onChanged: (value) {
                          setState(() {
                            _numberOfPeople = value.toInt();
                          });
                          _updateCalculation();
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickPeopleButton(1),
                        _buildQuickPeopleButton(2),
                        _buildQuickPeopleButton(4),
                        _buildQuickPeopleButton(6),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Each Person Pays
            ScaleTransition(
              scale: _slideAnimation,
              child: Card(
                elevation: 6,
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
                        Colors.green.withOpacity(0.2),
                        Colors.green.withOpacity(0.1),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Each Person Pays',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: _eachPersonPays),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Text(
                            '${value.toStringAsFixed(2)} ETB',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Add to My Share Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _addToMyShare,
                icon: const Icon(Icons.add_circle, size: 24),
                label: const Text(
                  'Add to My Share',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildQuickAmountButton(double amount) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _amount = amount;
        });
        _updateCalculation();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _amount == amount ? Colors.purple : Colors.purple[100],
        foregroundColor: _amount == amount ? Colors.white : Colors.purple,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text('${amount.toStringAsFixed(0)}'),
    );
  }

  Widget _buildQuickPeopleButton(int people) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _numberOfPeople = people;
        });
        _updateCalculation();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _numberOfPeople == people
            ? Colors.blue
            : Colors.blue[100],
        foregroundColor: _numberOfPeople == people ? Colors.white : Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text('$people'),
    );
  }
}

// Sheet for adding split expense
class _SplitExpenseSheet extends ConsumerStatefulWidget {
  final double amount;
  final double totalAmount;
  final int numberOfPeople;

  const _SplitExpenseSheet({
    required this.amount,
    required this.totalAmount,
    required this.numberOfPeople,
  });

  @override
  ConsumerState<_SplitExpenseSheet> createState() => _SplitExpenseSheetState();
}

class _SplitExpenseSheetState extends ConsumerState<_SplitExpenseSheet> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _category = 'Food';
  String _reasonType = 'Social';

  @override
  void dispose() {
    _reasonController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const Text(
              'Add Your Share',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${widget.totalAmount.toStringAsFixed(0)} ETB / ${widget.numberOfPeople} people',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Share:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${widget.amount.toStringAsFixed(2)} ETB',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Use the same fields as AddExpenseSheet but simplified
            DropdownButtonFormField<String>(
              value: _category,
              items: const [
                DropdownMenuItem(value: 'Food', child: Text('Food')),
                DropdownMenuItem(value: 'Transport', child: Text('Transport')),
                DropdownMenuItem(
                  value: 'Entertainment',
                  child: Text('Entertainment'),
                ),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (val) => setState(() => _category = val ?? 'Food'),
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Reason',
                hintText: 'Why did you spend?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add details...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_reasonController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a reason'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  ref
                      .read(budgetProvider.notifier)
                      .addExpense(
                        amount: widget.amount,
                        category: _category,
                        reasonType: _reasonType,
                        reason: _reasonController.text.trim(),
                        description: _descriptionController.text.trim().isEmpty
                            ? null
                            : _descriptionController.text.trim(),
                      );

                  Navigator.pop(context);
                  Navigator.pop(context); // Close splitter screen too
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Your share (${widget.amount.toStringAsFixed(0)} ETB) added! ✅',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
