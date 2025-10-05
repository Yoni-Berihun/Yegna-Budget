import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/user_provider.dart';

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(userNameProvider);
    final displayName = name.isEmpty ? 'User' : name;

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.lightBlue[100],
            foregroundColor: Colors.black87,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Calendar + Actions
                Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Calendar feature coming soon! 📅'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text(
                      'መስከረም 17', // TODO: dynamically calculate Ethiopian date
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                    const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Search coming soon!')),
                      );
                    },
                  ),

                    const SizedBox(width: 8),
                  DropdownButton<String>(
                    underline: const SizedBox(),
                    icon: const Icon(Icons.language),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('EN')),
                      DropdownMenuItem(value: 'am', child: Text('አማ')),
                    ],
                    onChanged: (val) {
                      // TODO: implement language change
                    },
                  ),

                    const SizedBox(width: 8),
                   IconButton(
                    icon: const Icon(Icons.brightness_6),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Dark/Light mode toggle soon!')),
                      );
                    },
                  ),
                ],
              ),
                const SizedBox(height: 8),
                // Row 2: Greeting
                   Row(
                children: [
                  const Text('👋', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    'ሰላም $displayName',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Selam $displayName',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

        
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // children: [
            //   // Quick Actions
            //   Text(
            //     'Quick Actions',
            //     style: Theme.of(context).textTheme.titleMedium,
            //   ),
            //   const SizedBox(height: 12),
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: const [
            //       _QuickAction(icon: Icons.add_circle, label: 'Add Expense'),
            //       _QuickAction(icon: Icons.tips_and_updates, label: 'Tips'),
            //       _QuickAction(icon: Icons.bar_chart, label: 'Analysis'),
            //     ],
            //   ),
            //   const SizedBox(height: 28),
            //   // Budget Summary Card
            //   Card(
            //     elevation: 4,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(16),
            //     ),
            //     child: Padding(
            //       padding: const EdgeInsets.all(20),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           const Text(
            //             'This Month’s Budget',
            //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //           ),
            //           const SizedBox(height: 16),
            //           LinearProgressIndicator(
            //             value: 2300 / 7000, // spent / total
            //             backgroundColor: Colors.grey[300],
            //             color: Colors.blueAccent,
            //             minHeight: 10,
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //           const SizedBox(height: 12),
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: const [
            //               Text('Spent: 2,300 ETB'),
            //               Text('Remaining: 4,700 ETB'),
            //             ],
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ],
          ),
        ),
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
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // TODO: hook into navigation later
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blueAccent,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}