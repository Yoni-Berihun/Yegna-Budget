import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yegna_budget/logic/tips_loader.dart';
import '../../data/models/financial_tip_model.dart';

/// Loads all tips from assets/data/financial_tips.json
final tipsFutureProvider = FutureProvider<List<FinancialTipModel>>((ref) async {
  return TipsLoader.loadFromAssets();
});

/// Picks today's tip deterministically
final dailyTipProvider = Provider<FinancialTipModel?>((ref) {
  final asyncTips = ref.watch(tipsFutureProvider);

  return asyncTips.maybeWhen(
    data: (tips) {
      if (tips.isEmpty) return null;

      // Prefer any tip flagged as daily
      final flagged = tips.where((t) => t.isDaily).toList();
      if (flagged.isNotEmpty) return flagged.first;

      // Otherwise pick based on today's day number
      final today = DateTime.now();
      final index = today.day % tips.length;
      return tips[index];
    },
    orElse: () => null,
  );
});