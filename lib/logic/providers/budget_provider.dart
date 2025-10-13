import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/expense.dart';

final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(
  BudgetNotifier.new,
);

class BudgetNotifier extends Notifier<BudgetState> {
  @override
  BudgetState build() {
    return BudgetState(
      totalBudget: 7000,
      spentAmount: 0,
      showRemaining: false,
      expenses: [], // 👈 Initialize empty list
    );
  }

  void addExpense({required double amount, required String category}) {
    final newExpense = Expense(category: category, amount: amount);
    final updatedExpenses = [...state.expenses, newExpense];

    state = state.copyWith(
      spentAmount: state.spentAmount + amount,
      expenses: updatedExpenses,
    );
  }

  /// 👇 Renamed to match your UI call
  void toggleShowRemaining() {
    state = state.copyWith(showRemaining: !state.showRemaining);
  }

  void updateBudget(double newBudget) {
    final sanitized = newBudget.isNaN || newBudget <= 0
        ? state.totalBudget
        : newBudget;
    state = state.copyWith(totalBudget: sanitized);
  }

  String? get topCategory {
    if (state.expenses.isEmpty) return null;

    final categoryTotals = <String, double>{};
    for (final expense in state.expenses) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return categoryTotals.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }
}

class BudgetState {
  final double totalBudget;
  final double spentAmount;
  final bool showRemaining;
  final List<Expense> expenses;

  BudgetState({
    required this.totalBudget,
    required this.spentAmount,
    required this.showRemaining,
    required this.expenses,
  });

  BudgetState copyWith({
    double? totalBudget,
    double? spentAmount,
    bool? showRemaining,
    List<Expense>? expenses,
  }) {
    return BudgetState(
      totalBudget: totalBudget ?? this.totalBudget,
      spentAmount: spentAmount ?? this.spentAmount,
      showRemaining: showRemaining ?? this.showRemaining,
      expenses: expenses ?? this.expenses,
    );
  }
}