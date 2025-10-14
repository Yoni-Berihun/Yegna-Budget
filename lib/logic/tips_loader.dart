import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../data/models/financial_tip_model.dart';

class TipsLoader {
  static Future<List<FinancialTipModel>> loadFromAssets() async {
    final raw = await rootBundle.loadString('assets/data/financial_tips.json');
    final List<dynamic> data = json.decode(raw);
    return data.map((e) => FinancialTipModel.fromJson(e)).toList();
  }
}