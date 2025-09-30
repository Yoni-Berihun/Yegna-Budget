import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/user_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(userNameProvider);
    final displayName = (name.isEmpty) ? 'User' : name;
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: Text('Selam $displayName'),
      
      leading: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Calendar feature coming soon! 📅')),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Language settings coming soon!')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Search feature coming soon!')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.night_shelter),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dark mode coming soon!')),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF973C00),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color.fromARGB(255, 249, 220, 146),
        unselectedItemColor: const Color.fromARGB(179, 233, 231, 231),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.tips_and_updates), label: 'FinTips'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Splitter'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),

      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Hello $displayName! 👋', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Welcome to Yegna Budget', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
        ]),
      ),
    );
  }
}