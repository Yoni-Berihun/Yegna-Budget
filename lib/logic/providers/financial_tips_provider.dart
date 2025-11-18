import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yegna_budget/logic/tips_loader.dart';
import '../../data/models/financial_tip_model.dart';
import '../../services/daily_tips_service.dart';

/// Loads all tips from assets/data/financial_tips.json
final tipsFutureProvider = FutureProvider<List<FinancialTipModel>>((ref) async {
  return TipsLoader.loadFromAssets();
});

/// Picks today's tip deterministically - refreshes daily
final dailyTipProvider = FutureProvider<FinancialTipModel?>((ref) async {
  final asyncTips = await ref.watch(tipsFutureProvider.future);

  if (asyncTips.isEmpty) return null;

  // Check if we should refresh (new day)
  final shouldRefresh = await DailyTipsService.shouldRefreshTip();

  // Get today's tip index deterministically
  final tipIndex = await DailyTipsService.getTodayTipIndex(asyncTips.length);
  final todayTip = asyncTips[tipIndex];

  // Save today's tip if it's a new day
  if (shouldRefresh) {
    await DailyTipsService.saveTodayTip(todayTip.id);
  }

  return todayTip;
});

/// Daily challenge question provider - generates new question each day
final dailyChallengeProvider = FutureProvider<Quiz?>((ref) async {
  final todayTip = await ref.watch(dailyTipProvider.future);
  if (todayTip == null) return null;

  // Generate daily challenge (automatically refreshes based on date)
  final challenge = DailyTipsService.generateDailyChallenge(todayTip);

  return challenge;
});
