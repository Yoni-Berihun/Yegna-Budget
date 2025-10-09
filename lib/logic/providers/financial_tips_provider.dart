import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../data/models/financial_tip_model.dart';
final financialTipsProvider = FutureProvider<List<FinancialTipModel>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/data/financial_tips.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((e) => FinancialTipModel.fromJson(e)).toList();
}); 