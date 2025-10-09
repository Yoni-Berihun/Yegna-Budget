
import 'package:flutter_riverpod/flutter_riverpod.dart';

final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(BudgetNotifier.new);

class BudgetNotifier extends Notifier<BudgetState> {
  @override
  BudgetState build() {
    return BudgetState(
      totalBudget: 7000,
      spentAmount: 0,
      showRemaining: false,
    );
  }

  void addExpense(double amount) {
    state = state.copyWith(spentAmount: state.spentAmount + amount);
  }

  void toggleVisibility() {
    state = state.copyWith(showRemaining: !state.showRemaining);
  }

  void updateBudget(double newBudget) {
    // Basic validation and safety
    final sanitized = newBudget.isNaN || newBudget <= 0 ? state.totalBudget : newBudget;
    state = state.copyWith(
      totalBudget: sanitized,
    );
  }
}
class BudgetState {
  final double totalBudget;
  final double spentAmount;
  final bool showRemaining;

  BudgetState({
    required this.totalBudget,
    required this.spentAmount,
    required this.showRemaining,
  });

  BudgetState copyWith({
    double? totalBudget,
    double? spentAmount,
    bool? showRemaining,
  }) {
    return BudgetState(
      totalBudget: totalBudget ?? this.totalBudget,
      spentAmount: spentAmount ?? this.spentAmount,
      showRemaining: showRemaining ?? this.showRemaining,
    );
  }
}