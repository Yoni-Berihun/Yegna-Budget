// lib/logic/providers/budget_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/budget_storage_service.dart';

class Expense {
  final String id;
  final double amount;
  final String category;
  final String reasonType; // Necessity, Impulse, Planned, Emergency, Social
  final String reason; // Why did you spend
  final String? description; // Optional details
  final String? receiptPath; // Path to receipt image
  final DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.reasonType,
    required this.reason,
    this.description,
    this.receiptPath,
    required this.date,
  });

  Expense.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      amount = (json['amount'] as num).toDouble(),
      category = json['category'] as String,
      reasonType = json['reasonType'] as String? ?? 'Necessity',
      reason = json['reason'] as String,
      description = json['description'] as String?,
      receiptPath = json['receiptPath'] as String?,
      date = DateTime.parse(json['date'] as String);

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'category': category,
    'reasonType': reasonType,
    'reason': reason,
    'description': description,
    'receiptPath': receiptPath,
    'date': date.toIso8601String(),
  };
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

  double get remaining => totalBudget - spentAmount;
  double get progress =>
      totalBudget > 0 ? (spentAmount / totalBudget).clamp(0.0, 1.0) : 0.0;
  double get savingsRate =>
      totalBudget > 0 ? (remaining / totalBudget * 100).clamp(0, 100) : 0;
}

class BudgetNotifier extends Notifier<BudgetState> {
  @override
  BudgetState build() {
    // Load budget asynchronously after first build
    Future.microtask(() => _loadBudget());
    return BudgetState(
      totalBudget: 7000,
      spentAmount: 0,
      showRemaining: false,
      expenses: [],
    );
  }

  Future<void> _loadBudget() async {
    try {
      final savedBudget = await BudgetStorageService.loadBudget();
      if (savedBudget != null) {
        state = savedBudget;
      }
    } catch (e) {
      // If loading fails, use default state
      print('Error loading budget: $e');
    }
  }

  // Public method to initialize budget from storage
  Future<void> initialize() async {
    await _loadBudget();
  }

  Future<void> _saveBudget() async {
    await BudgetStorageService.saveBudget(state);
    await BudgetStorageService.saveExpenses(state.expenses);
  }

  void addExpense({
    required double amount,
    required String category,
    required String reasonType,
    required String reason,
    String? description,
    String? receiptPath,
  }) {
    final newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: category,
      reasonType: reasonType,
      reason: reason,
      description: description,
      receiptPath: receiptPath,
      date: DateTime.now(),
    );
    final updatedExpenses = [...state.expenses, newExpense];
    final updatedSpent = state.spentAmount + amount;

    state = state.copyWith(
      spentAmount: updatedSpent,
      expenses: updatedExpenses,
    );
    _saveBudget();
  }

  void toggleShowRemaining() {
    state = state.copyWith(showRemaining: !state.showRemaining);
    _saveBudget();
  }

  void updateBudget(double newBudget) {
    final sanitized = newBudget.isNaN || newBudget <= 0
        ? state.totalBudget
        : newBudget;
    state = state.copyWith(totalBudget: sanitized);
    _saveBudget();
  }

  void deleteExpense(String id) {
    final expense = state.expenses.firstWhere((e) => e.id == id);
    final updatedExpenses = state.expenses.where((e) => e.id != id).toList();
    final updatedSpent = state.spentAmount - expense.amount;

    state = state.copyWith(
      spentAmount: updatedSpent.clamp(0, double.infinity),
      expenses: updatedExpenses,
    );
    _saveBudget();
  }

  String? get topCategory {
    if (state.expenses.isEmpty) return null;
    final grouped = <String, double>{};
    for (var e in state.expenses) {
      grouped[e.category] = (grouped[e.category] ?? 0) + e.amount;
    }
    return grouped.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Map<String, double> get categoryBreakdown {
    final grouped = <String, double>{};
    for (var e in state.expenses) {
      grouped[e.category] = (grouped[e.category] ?? 0) + e.amount;
    }
    return grouped;
  }

  double getAverageExpense() {
    if (state.expenses.isEmpty) return 0;
    return state.spentAmount / state.expenses.length;
  }
}

final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(
  BudgetNotifier.new,
);
