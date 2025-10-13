import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'services/prefs_service.dart';
import 'presentation/screens/welcome/welcome_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'logic/providers/user_provider.dart';
import 'logic/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);
  await Hive.openBox('feedbackBox');

  final bool firstTime = await PrefsService.isFirstTime();
  final String? savedName = await PrefsService.loadUserName();

  runApp(
    ProviderScope(
      child: YegnaApp(
        showWelcome: firstTime && (savedName == null || savedName.isEmpty),
        initialUserName: savedName,
      ),
    ),
  );
}

class YegnaApp extends ConsumerStatefulWidget {
  final bool showWelcome;
  final String? initialUserName;

  const YegnaApp({required this.showWelcome, this.initialUserName, super.key});

  @override
  ConsumerState<YegnaApp> createState() => _YegnaAppState();
}

class _YegnaAppState extends ConsumerState<YegnaApp> {
  @override
  void initState() {
    super.initState();
    if (widget.initialUserName != null && widget.initialUserName!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userNameProvider.notifier).setUserName(widget.initialUserName!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider); // 👈 Watch provider

    return MaterialApp(
      title: 'YegnaBudget',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode, // 👈 Dynamic theme switching
      home: widget.showWelcome ? const WelcomeScreen() : const HomeScreen(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/welcome': (_) => const WelcomeScreen(),
      },
    );
  }
}