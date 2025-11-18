import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abushakir/abushakir.dart';
import '../../../logic/providers/budget_provider.dart';

class EthiopianCalendarPage extends ConsumerStatefulWidget {
  final EtDatetime initialDate;
  const EthiopianCalendarPage({super.key, required this.initialDate});

  @override
  ConsumerState<EthiopianCalendarPage> createState() => _EthiopianCalendarPageState();
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
    final year = _focusedDate.year;
    final month = _focusedDate.month;
    final isPagumen = month == 13;
    final isLeap = year % 4 == 3;
    final length = isPagumen ? (isLeap ? 6 : 5) : 30;
    return List.generate(length, (i) => EtDatetime(year: year, month: month, day: i + 1));
  }

  void _goToPrevMonth() {
    final year = _focusedDate.year;
    final month = _focusedDate.month;
    setState(() {
      if (month > 1) {
        _focusedDate = EtDatetime(year: year, month: month - 1, day: 1);
      } else {
        _focusedDate = EtDatetime(year: year - 1, month: 13, day: 1);
      }
      _selectedDate = null;
    });
  }

  void _goToNextMonth() {
    final year = _focusedDate.year;
    final month = _focusedDate.month;
    setState(() {
      if (month < 13) {
        _focusedDate = EtDatetime(year: year, month: month + 1, day: 1);
      } else {
        _focusedDate = EtDatetime(year: year + 1, month: 1, day: 1);
      }
      _selectedDate = null;
    });
  }

  String _monthGeezName(int month) {
    const monthsGeez = [
      'መስከረም','ጥቅምት','ህዳር','ታህሳስ','ጥር','የካቲት','መጋቢት','ሚያዝያ','ግንቦት','ሰኔ','ሐምሌ','ነሐሴ','ጳጕሜ',
    ];
    return monthsGeez[month - 1];
  }

  List<dynamic> _getExpensesForDate(EtDatetime etDate) {
    final budget = ref.watch(budgetProvider);
    try {
      return budget.expenses.where((expense) {
        try {
          final eEt = EtDatetime.fromMillisecondsSinceEpoch(expense.date.millisecondsSinceEpoch);
          return eEt.year == etDate.year && eEt.month == etDate.month && eEt.day == etDate.day;
        } catch (_) {
          return false;
        }
      }).toList();
    } catch (_) {
      return [];
    }
  }

  bool _hasExpenses(EtDatetime etDate) => _getExpensesForDate(etDate).isNotEmpty;

  double _getTotalExpensesForDate(EtDatetime etDate) {
    final expenses = _getExpensesForDate(etDate);
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysInFocusedMonth();
    final title = '${_monthGeezName(_focusedDate.month)} ${_focusedDate.year}';
    final today = EtDatetime.now();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.navigate_before), onPressed: _goToPrevMonth, tooltip: 'Previous'),
          IconButton(icon: const Icon(Icons.navigate_next), onPressed: _goToNextMonth, tooltip: 'Next'),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
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
                  _WeekDayHeader('ሰ','Sun'),
                  _WeekDayHeader('ማ','Mon'),
                  _WeekDayHeader('ረ','Tue'),
                  _WeekDayHeader('ሐ','Wed'),
                  _WeekDayHeader('አ','Thu'),
                  _WeekDayHeader('ቅ','Fri'),
                  _WeekDayHeader('እ','Sat'),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final day = days[index];
                  final isSelected = _selectedDate != null &&
                      day.year == _selectedDate!.year &&
                      day.month == _selectedDate!.month &&
                      day.day == _selectedDate!.day;
                  final hasExpenses = _hasExpenses(day);
                  final amount = _getTotalExpensesForDate(day);
                  final isToday = day.year == today.year &&
                      day.month == today.month &&
                      day.day == today.day;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : isToday
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : isToday
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                                  : Colors.transparent,
                          width: isSelected || isToday ? 2 : 0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                          if (hasExpenses) ...[
                            const SizedBox(height: 2),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.red[400],
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (amount > 0) ...[
                              const SizedBox(height: 0),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  amount.toStringAsFixed(0),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white70 : Colors.red[600],
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
                childCount: days.length,
              ),
            ),
          ),
          if (_selectedDate != null)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Expenses on ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, _selectedDate),
                                child: const Text('Select'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => setState(() => _selectedDate = null),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.35,
                      ),
                      child: _buildExpensesList(_selectedDate!),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(EtDatetime etDate) {
    final expenses = _getExpensesForDate(etDate);
    if (expenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text('No expenses on this day', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: expenses.length,
      itemBuilder: (context, i) {
        final expense = expenses[i];
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
              title: Text(expense.category, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(expense.reason, maxLines: 1, overflow: TextOverflow.ellipsis),
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
      case 'food': return Colors.orange;
      case 'transport': return Colors.blue;
      case 'books and supplies': return Colors.purple;
      case 'entertainment': return Colors.pink;
      case 'health and medical': return Colors.red;
      case 'clothing': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_car;
      case 'books and supplies': return Icons.book;
      case 'entertainment': return Icons.movie;
      case 'health and medical': return Icons.medical_services;
      case 'clothing': return Icons.checkroom;
      default: return Icons.category;
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