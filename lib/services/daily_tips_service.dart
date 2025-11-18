import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/financial_tip_model.dart';

class DailyTipsService {
  static const String _lastTipDateKey = 'last_tip_date';
  static const String _lastTipIdKey = 'last_tip_id';
  static const String _lastChallengeDateKey = 'last_challenge_date';

  // Check if we need to refresh the daily tip
  static Future<bool> shouldRefreshTip() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString(_lastTipDateKey);

    if (lastDateStr == null) return true;

    final lastDate = DateTime.parse(lastDateStr);
    final today = DateTime.now();

    // Refresh if it's a new day
    return today.year != lastDate.year ||
        today.month != lastDate.month ||
        today.day != lastDate.day;
  }

  // Get today's tip index (deterministic based on date)
  static Future<int> getTodayTipIndex(int totalTips) async {
    final today = DateTime.now();
    // Use year, month, and day to create a consistent index
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    return dayOfYear % totalTips;
  }

  // Save today's tip
  static Future<void> saveTodayTip(String tipId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastTipDateKey, DateTime.now().toIso8601String());
    await prefs.setString(_lastTipIdKey, tipId);
  }

  // Check if challenge should refresh
  static Future<bool> shouldRefreshChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString(_lastChallengeDateKey);

    if (lastDateStr == null) return true;

    final lastDate = DateTime.parse(lastDateStr);
    final today = DateTime.now();

    return today.year != lastDate.year ||
        today.month != lastDate.month ||
        today.day != lastDate.day;
  }

  // Save challenge completion date
  static Future<void> saveChallengeDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lastChallengeDateKey,
      DateTime.now().toIso8601String(),
    );
  }

  // Generate daily challenge question based on tip
  static Quiz generateDailyChallenge(FinancialTipModel tip) {
    // If tip has a quiz, use it
    if (tip.quiz != null) return tip.quiz!;

    // Otherwise generate a simple question based on the tip category
    switch (tip.category.toLowerCase()) {
      case 'budgeting':
        return Quiz(
          question: "What's the best way to start budgeting?",
          options: [
            "Track all expenses",
            "Ignore small purchases",
            "Only budget for big items",
            "Budget once a month",
          ],
          correctIndex: 0,
        );
      case 'saving':
        return Quiz(
          question: "How much should you save from each paycheck?",
          options: [
            "At least 20%",
            "Only what's left over",
            "10% or more",
            "Nothing if you're young",
          ],
          correctIndex: 0,
        );
      case 'tracking':
        return Quiz(
          question: "Why is expense tracking important?",
          options: [
            "To understand spending patterns",
            "It's not necessary",
            "Only for businesses",
            "To impress others",
          ],
          correctIndex: 0,
        );
      default:
        return Quiz(
          question: "What is the key to financial success?",
          options: [
            "Consistent planning and discipline",
            "Earning more money",
            "Avoiding all expenses",
            "Taking big risks",
          ],
          correctIndex: 0,
        );
    }
  }
}
