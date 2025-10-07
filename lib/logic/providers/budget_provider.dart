
import 'package:flutter_riverpod/flutter_riverpod.dart';

final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(BudgetNotifier.new);

class BudgetNotifier extends Notifier<BudgetState> {
  final double initial;
  void addExpense(double amount)
{
  state = state.copyWith(spentAmount:state.spentAmount+amount);
}
void toggleVisibility() {
  state = state.copyWith(showRemaining: !state.showRemaining);
}
  BudgetNotifier({double? initial}) : initial = initial ?? 7000;
void updateBudget(double newBudget) {
    // Basic validation and safety
    final sanitized = newBudget.isNaN || newBudget <= 0 ? state.totalBudget : newBudget;
state = state.copyWith(
      totalBudget: sanitized,
      // spentAmount: adjustedSpent, // use if you chose clamping above
    );
  }

  @override
  BudgetState build() {
    return BudgetState(
      totalBudget: initial,
      spentAmount: 0,
      showRemaining: false,
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