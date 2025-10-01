import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            'Selam 👋',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back to YegnaBudget',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),

          const SizedBox(height: 24),

          // Quick Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuickAction(icon: Icons.add, label: 'Add Expense'),
              _QuickAction(icon: Icons.tips_and_updates, label: 'Tips'),
              _QuickAction(icon: Icons.bar_chart, label: 'Analysis'),
            ],
          ),

          const SizedBox(height: 24),

          // Budget Summary Card
          Card(
            color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'This Month\'s Budget',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text('Spent: 2,300 ETB'),
                  Text('Remaining: 4,700 ETB'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable quick action button
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blueAccent,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}