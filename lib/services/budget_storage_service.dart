import 'package:hive_flutter/hive_flutter.dart';
import '../logic/providers/budget_provider.dart';

class BudgetStorageService {
  static const String _boxName = 'budgetBox';
  static const String _budgetKey = 'budget';
  static const String _expensesKey = 'expenses';

  static Future<Box> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  // Save budget state
  static Future<void> saveBudget(BudgetState budget) async {
    final box = await _box;
    await box.put(_budgetKey, {
      'totalBudget': budget.totalBudget,
      'spentAmount': budget.spentAmount,
      'showRemaining': budget.showRemaining,
    });
  }

  // Load budget state
  static Future<BudgetState?> loadBudget() async {
    final box = await _box;
    final data = box.get(_budgetKey);
    if (data == null) return null;

    return BudgetState(
      totalBudget: (data['totalBudget'] as num).toDouble(),
      spentAmount: (data['spentAmount'] as num).toDouble(),
      showRemaining: data['showRemaining'] as bool? ?? false,
      expenses: await loadExpenses(),
    );
  }

  // Save expenses
  static Future<void> saveExpenses(List<Expense> expenses) async {
    final box = await _box;
    final expensesJson = expenses.map((e) => e.toJson()).toList();
    await box.put(_expensesKey, expensesJson);
  }

  // Load expenses
  static Future<List<Expense>> loadExpenses() async {
    final box = await _box;
    final data = box.get(_expensesKey);
    if (data == null) return [];

    try {
      return (data as List)
          .map((json) => Expense.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Clear all data
  static Future<void> clearAll() async {
    final box = await _box;
    await box.clear();
  }
}
