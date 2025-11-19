import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../logic/providers/theme_provider.dart';
import '../../../logic/providers/user_provider.dart';
import '../../../services/notification_service.dart';
import '../../../services/prefs_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentIndex = 0;
  bool _saving = false;
  String? _nameError;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      title: 'Budget smarter',
      description:
          'Stay on track with a clear overview of what you planned vs spent.',
      asset: 'assets/images/spending_chart.png',
    ),
    _OnboardingPageData(
      title: 'Plan with confidence',
      description:
          'Discover helpful tips and insights tailored for students and teams.',
      asset: 'assets/images/buffer_tip.png',
    ),
    _OnboardingPageData(
      title: 'Make it yours',
      description:
          'Choose a nickname and get daily reminders at 8:00 PM EAT to log expenses.',
      asset: 'assets/images/monthly_review.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _prefillExistingName();
  }

  Future<void> _prefillExistingName() async {
    final existingName = await PrefsService.loadUserName() ?? '';
    if (existingName.isNotEmpty && mounted) {
      setState(() {
        _nameController.text = existingName;
        _nameError = null;
      });
    }
  }

  void _handleNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final nickname = _nameController.text.trim();
    if (nickname.length < 2) {
      setState(() {
        _nameError = 'Please enter at least 2 characters';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nickname must be at least 2 characters.'),
        ),
      );
      return;
    }

    setState(() {
      _nameError = null;
    });

    setState(() => _saving = true);
    try {
      await PrefsService.saveUserName(nickname);
      await PrefsService.saveWelcomeSeen();
      await PrefsService.setDailyNotificationEnabled(true);
      ref.read(userNameProvider.notifier).setUserName(nickname);
      try {
        await NotificationService.scheduleDailyReminderIfEnabled();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notifications unavailable: $e')),
          );
        }
      }

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == _pages.length - 1;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'Toggle theme',
                    icon: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                    onPressed: () =>
                        ref.read(themeModeProvider.notifier).toggleTheme(),
                  ),
                  Visibility(
                    visible: !isLast,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton(
                      onPressed: () => _pageController.jumpToPage(2),
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Colors.brown),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.asset(page.asset, fit: BoxFit.contain),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                        if (index == _pages.length - 1) ...[
                          const SizedBox(height: 24),
                          TextField(
                            controller: _nameController,
                            textInputAction: TextInputAction.done,
                            autofocus: true,
                            decoration: InputDecoration(
                              labelText: 'Nickname',
                              hintText: 'e.g. Yonii',
                              errorText: _nameError,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildIndicators(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C3A1F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isLast ? 'Let\'s Goooo' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentIndex == index ? 28 : 8,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? const Color(0xFF5C3A1F)
                : Colors.brown.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String description;
  final String asset;

  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.asset,
  });
}
