import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/prefs_service.dart';
import 'presentation/screens/welcome/welcome_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'logic/providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load persisted username and welcome flag
  final bool firstTime = await PrefsService.isFirstTime();
  final String? savedName = await PrefsService.loadUserName();

  runApp(
    ProviderScope(
      overrides: [
        // initialize provider with saved name (if any)
        if ((savedName ?? '').isNotEmpty)
          userNameProvider.overrideWith(
            () => UserNameNotifier()..state = savedName!,
          ),
      ],
      child: YegnaApp(
        showWelcome: firstTime && (savedName == null || savedName.isEmpty),
      ),
    ),
  );
}

class YegnaApp extends StatelessWidget {
  final bool showWelcome;
  const YegnaApp({required this.showWelcome, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YegnaBudget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: showWelcome ? const WelcomeScreen() : const HomeScreen(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/welcome': (_) => const WelcomeScreen(),
      },
    );
  }
}
