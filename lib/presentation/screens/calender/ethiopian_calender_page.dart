import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abushakir/abushakir.dart';
import '../../../logic/providers/budget_provider.dart';

class EthiopianCalendarPage extends ConsumerStatefulWidget {
  final EtDatetime initialDate;

  const EthiopianCalendarPage({super.key, required this.initialDate});

  @override
  ConsumerState<EthiopianCalendarPage> createState() =>
      _EthiopianCalendarPageState();
}

class _EthiopianCalendarPageState extends ConsumerState<EthiopianCalendarPage> {
  late EtDatetime _focusedDate;
  EtDatetime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.initialDate;
    _selectedDate = null;
  }

  List<EtDatetime> _daysInFocusedMonth() {
    final int year = _focusedDate.year;
    final int month = _focusedDate.month;
    final bool isPagumen = month == 13;
    final bool isLeap = year % 4 == 3;
    final int length = isPagumen ? (isLeap ? 6 : 5) : 30;

    return List.generate(
      length,
      (i) => EtDatetime(year: year, month: month, day: i + 1),
    );
  }

  void _goToPrevMonth() {
    final int year = _focusedDate.year;
    final int month = _focusedDate.month;

    if (month > 1) {
      setState(() {
        _focusedDate = EtDatetime(year: year, month: month - 1, day: 1);
      });
    } else {
      setState(() {
        _focusedDate = EtDatetime(year: year - 1, month: 13, day: 1);
      });
    }
  }

  void _goToNextMonth() {
    final int year = _focusedDate.year;
    final int month = _focusedDate.month;

    if (month < 13) {
      setState(() {
        _focusedDate = EtDatetime(year: year, month: month + 1, day: 1);
      });
    } else {
      setState(() {
        _focusedDate = EtDatetime(year: year + 1, month: 1, day: 1);
      });
    }
  }

  String _monthGeezName(int month) {
    const monthsGeez = [
      'መስከረም',
      'ጥቅምት',
      'ህዳር',
      'ታህሳስ',
      'ጥር',
      'የካቲት',
      'መጋቢት',
      'ሚያዝያ',
      'ግንቦት',
      'ሰኔ',
      'ሐምሌ',
      'ነሐሴ',
      'ጳጕሜ',
    ];
    return monthsGeez[month - 1];
  }

  List<dynamic> _getExpensesForDate(EtDatetime ethiopianDate) {
    final budget = ref.watch(budgetProvider);
    try {
      // Convert Ethiopian date to milliseconds, then to DateTime
      // EtDatetime has fromMillisecondsSinceEpoch, so we can work backwards
      // For now, let's convert expense dates to Ethiopian and compare
      return budget.expenses.where((expense) {
        try {
          final expenseEthiopian = EtDatetime.fromMillisecondsSinceEpoch(
            expense.date.millisecondsSinceEpoch,
          );
          return expenseEthiopian.year == ethiopianDate.year &&
              expenseEthiopian.month == ethiopianDate.month &&
              expenseEthiopian.day == ethiopianDate.day;
        } catch (e) {
          return false;
        }
      }).toList();
    } catch (e) {
      return [];
    }
  }

  bool _hasExpenses(EtDatetime ethiopianDate) {
    return _getExpensesForDate(ethiopianDate).isNotEmpty;
  }

  double _getTotalExpensesForDate(EtDatetime ethiopianDate) {
    final expenses = _getExpensesForDate(ethiopianDate);
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysInFocusedMonth();
    final String title =
        '${_monthGeezName(_focusedDate.month)} ${_focusedDate.year}';
    final todayEthiopian = EtDatetime.now();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: _goToPrevMonth,
            tooltip: 'Previous Month',
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: _goToNextMonth,
            tooltip: 'Next Month',
          ),
        ],
      ),
      body: Column(
        children: [
          // Weekday headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _WeekDayHeader('ሰ', 'Sun'),
                _WeekDayHeader('ማ', 'Mon'),
                _WeekDayHeader('ረ', 'Tue'),
                _WeekDayHeader('ሐ', 'Wed'),
                _WeekDayHeader('አ', 'Thu'),
                _WeekDayHeader('ቅ', 'Fri'),
                _WeekDayHeader('እ', 'Sat'),
              ],
            ),
          ),
          // Calendar grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isSelected =
                      _selectedDate != null &&
                      day.year == _selectedDate!.year &&
                      day.month == _selectedDate!.month &&
                      day.day == _selectedDate!.day;
                  final hasExpenses = _hasExpenses(day);
                  final expenseAmount = _getTotalExpensesForDate(day);
                  final isToday =
                      day.year == todayEthiopian.year &&
                      day.month == todayEthiopian.month &&
                      day.day == todayEthiopian.day;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = day;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : isToday
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : isToday
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.5)
                              : Colors.transparent,
                          width: isSelected || isToday ? 2 : 0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                          if (hasExpenses) ...[
                            const SizedBox(height: 2),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.red[400],
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (expenseAmount > 0) ...[
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${expenseAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white70
                                        : Colors.red[600],
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Selected date expenses
          if (_selectedDate != null)
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Expenses on ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, _selectedDate);
                              },
                              child: const Text('Select'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _selectedDate = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flexible(child: _buildExpensesList(_selectedDate!)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(EtDatetime ethiopianDate) {
    final expenses = _getExpensesForDate(ethiopianDate);

    if (expenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No expenses on this day',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(expense.category).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: _getCategoryColor(expense.category),
                size: 20,
              ),
            ),
            title: Text(
              expense.category,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(expense.reason),
            trailing: Text(
              '${expense.amount.toStringAsFixed(0)} ETB',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'books and supplies':
        return Colors.purple;
      case 'entertainment':
        return Colors.pink;
      case 'health and medical':
        return Colors.red;
      case 'clothing':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'books and supplies':
        return Icons.book;
      case 'entertainment':
        return Icons.movie;
      case 'health and medical':
        return Icons.medical_services;
      case 'clothing':
        return Icons.checkroom;
      default:
        return Icons.category;
    }
  }
}

class _WeekDayHeader extends StatelessWidget {
  final String geez;
  final String english;

  const _WeekDayHeader(this.geez, this.english);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          geez,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Text(english, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}
