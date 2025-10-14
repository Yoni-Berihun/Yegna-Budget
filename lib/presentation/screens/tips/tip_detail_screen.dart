import 'package:flutter/material.dart';
import '../../../data/models/financial_tip.dart';

class TipDetailScreen extends StatelessWidget {
  final FinancialTip tip;
  const TipDetailScreen({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tip.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),