import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/user_provider.dart';
import '../../../services/prefs_service.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});
  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final enteredName = _controller.text.trim();
    if (enteredName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your name!')));
      return;
    }

    // persist name and welcome flag
    await PrefsService.saveUserName(enteredName);
    await PrefsService.saveWelcomeSeen();

    // update provider
    ref.read(userNameProvider.notifier).state = enteredName;

    // navigate to home and replace stack
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Yegna Budget')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('What is your name?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Enter your name",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: _onContinue,
            child: const Text('Lets Goooo', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
          ),
          TextButton(
            onPressed: () async {
              await PrefsService.resetWelcome();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome screen reset! Close and reopen app.')));
            },
            child: const Text('Reset Welcome (For Testing)', style: TextStyle(color: Colors.grey)),
          ),
        ]),
      ),
    );
  }
}