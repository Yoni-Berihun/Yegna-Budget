import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yegna_budget/data/models/icon_mapper.dart';

import '../../../logic/providers/budget_provider.dart';
import '../../../logic/providers/preferences_provider.dart';
import '../../../logic/providers/theme_provider.dart';
import '../../../logic/providers/user_provider.dart';
import '../../../services/budget_storage_service.dart';
import '../../../services/export_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/prefs_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetProvider);
    final themeMode = ref.watch(themeModeProvider);
    final userName = ref.watch(userNameProvider);
    final dailyReminderAsync = ref.watch(dailyNotificationProvider);
    final reminderTimeAsync = ref.watch(reminderTimeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.settings, size: 22),
            const SizedBox(width: 8),
            const Text('Settings'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.isNotEmpty ? userName : 'User',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Budget: ${budget.totalBudget.toStringAsFixed(0)} ETB',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Export Section
            const Text(
              'Export Data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _ExportOptionTile(
                    icon: Icons.picture_as_pdf,
                    title: 'Export to PDF',
                    subtitle: 'Download expense report as PDF',
                    color: Colors.red,
                    onTap: () => _exportPDF(context, ref, budget),
                  ),
                  const Divider(height: 1),
                  _ExportOptionTile(
                    icon: Icons.table_chart,
                    title: 'Export to CSV',
                    subtitle: 'Download expense data as CSV',
                    color: Colors.green,
                    onTap: () => _exportCSV(context, ref, budget),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Settings
            const Text(
              'App Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.badge,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Nickname'),
                    subtitle: Text(
                      userName.isEmpty ? 'Tap to set your nickname' : userName,
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showNicknameDialog(context, ref, userName),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Dark Mode'),
                    subtitle: Text(
                      themeMode == ThemeMode.dark ? 'Enabled' : 'Disabled',
                    ),
                    value: themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setTheme(value ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.visibility,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Show Remaining Amount'),
                    subtitle: Text(budget.showRemaining ? 'Visible' : 'Hidden'),
                    trailing: Switch(
                      value: budget.showRemaining,
                      onChanged: (value) async {
                        try {
                          await ref
                              .read(budgetProvider.notifier)
                              .toggleShowRemaining();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating setting: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  dailyReminderAsync.when(
                    data: (enabled) => SwitchListTile(
                      secondary: Icon(
                        Icons.notifications_active,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('Daily Reminder'),
                      subtitle: Text(
                        '${_formatReminderSubtitle(reminderTimeAsync, context)} • Silent notification',
                      ),
                      value: enabled,
                      onChanged: (value) async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          if (value) {
                            await PrefsService.setDailyNotificationEnabled(true);
                            final time = await PrefsService.loadReminderTime();
                            await NotificationService.scheduleDailyReminder(
                              hour: time.hour,
                              minute: time.minute,
                            );
                          } else {
                            await PrefsService.setDailyNotificationEnabled(false);
                            await NotificationService.cancelDailyReminder();
                          }
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Failed to update reminder: $e'),
                            ),
                          );
                          await PrefsService.setDailyNotificationEnabled(!value);
                        } finally {
                          ref.invalidate(dailyNotificationProvider);
                        }
                      },
                    ),
                    loading: () => const ListTile(
                      leading: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      title: Text('Daily Reminder'),
                      subtitle: Text('Loading your preference...'),
                    ),
                    error: (error, _) => ListTile(
                      leading: const Icon(Icons.error, color: Colors.red),
                      title: const Text('Daily Reminder'),
                      subtitle: Text('Error: $error'),
                      trailing: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () =>
                            ref.invalidate(dailyNotificationProvider),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  reminderTimeAsync.when(
                    data: (time) => ListTile(
                      leading: Icon(
                        Icons.schedule,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('Reminder Time'),
                      subtitle: Text(time.format(context)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _pickReminderTime(context, ref, time),
                    ),
                    loading: () => const ListTile(
                      leading: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      title: Text('Reminder Time'),
                      subtitle: Text('Loading...'),
                    ),
                    error: (e, _) => ListTile(
                      leading: const Icon(Icons.error, color: Colors.red),
                      title: const Text('Reminder Time'),
                      subtitle: Text('Error: $e'),
                      trailing: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => ref.invalidate(reminderTimeProvider),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Data Management
            const Text(
              'Data Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.delete_outline, color: Colors.red[600]),
                    title: const Text('Clear All Data'),
                    subtitle: const Text(
                      'Delete all expenses and reset budget',
                    ),
                    onTap: () => _showClearDataDialog(context, ref),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('About'),
                    subtitle: const Text('App version and information'),
                    onTap: () => _showAboutDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.developer_mode,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Developer'),
                    subtitle: const Text('Meet the developer'),
                    onTap: () => _showDeveloperDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistics
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.withOpacity(0.1),
                      Colors.purple.withOpacity(0.1),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _StatItem('Total Expenses', '${budget.expenses.length}'),
                    _StatItem(
                      'Total Spent',
                      '${budget.spentAmount.toStringAsFixed(2)} ETB',
                    ),
                    _StatItem(
                      'Remaining',
                      '${budget.remaining.toStringAsFixed(2)} ETB',
                    ),
                    _StatItem(
                      'Savings Rate',
                      '${budget.savingsRate.toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPDF(
    BuildContext context,
    WidgetRef ref,
    BudgetState budget,
  ) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Exporting to PDF...'),
            ],
          ),
        ),
      );

      await ExportService.exportToPDF(budget);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportCSV(
    BuildContext context,
    WidgetRef ref,
    BudgetState budget,
  ) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Exporting to CSV...'),
            ],
          ),
        ),
      );

      await ExportService.exportToCSV(budget);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all expenses and reset your budget? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await BudgetStorageService.clearAll();
              ref.invalidate(budgetProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  String _formatReminderSubtitle(
    AsyncValue<TimeOfDay> timeAsync,
    BuildContext context,
  ) {
    return timeAsync.maybeWhen(
      data: (time) => time.format(context),
      orElse: () => '8:00 PM',
    );
  }

  Future<void> _showNicknameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    final messenger = ScaffoldMessenger.of(context);
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Nickname'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nickname',
            hintText: 'e.g. Yonii',
          ),
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nickname = controller.text.trim();
              if (nickname.length < 2) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Nickname must be at least 2 characters.'),
                  ),
                );
                return;
              }
              await PrefsService.saveUserName(nickname);
              ref.read(userNameProvider.notifier).setUserName(nickname);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              messenger.showSnackBar(
                SnackBar(content: Text('Nickname updated to $nickname')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    WidgetRef ref,
    TimeOfDay initialTime,
  ) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (newTime == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await PrefsService.saveReminderTime(newTime);
      if (await PrefsService.isDailyNotificationEnabled()) {
        await NotificationService.scheduleDailyReminder(
          hour: newTime.hour,
          minute: newTime.minute,
        );
      }
      messenger.showSnackBar(
        SnackBar(content: Text('Reminder set for ${newTime.format(context)}')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to update reminder: $e')),
      );
    } finally {
      ref.invalidate(reminderTimeProvider);
      ref.invalidate(dailyNotificationProvider);
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About YegnaBudget'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('YegnaBudget helps you manage your finances effectively.'),
            SizedBox(height: 8),
            Text('Features:'),
            Text('• Track expenses'),
            Text('• Budget management'),
            Text('• Expense splitting'),
            Text('• Financial tips'),
            Text('• Data export'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Reusable export option tile
class _ExportOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ExportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// Reusable stat item
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

void _showDeveloperDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Developer'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/developer.jpg',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.person, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hi, I am Yonatan Berihun, the developer of YegnaBudget. '
              'This app was built to empower students and communities '
              'with financial literacy and practical budgeting tools.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                const Text(
                  'Contact me at:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.asset(
                          'assets/telegramlogo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.telegram, size: 32),
                        ),
                      ),
                      onPressed: () => _launchExternal(
                        context,
                        'https://t.me/Yoni_xyz',
                        'Could not open Telegram',
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: buildMappedIcon('instagram', size: 28),
                      onPressed: () => _launchExternal(
                        context,
                        'https://instagram.com/yoni_berihun',
                        'Could not open Instagram',
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: buildMappedIcon('whatsapp', size: 28),
                      onPressed: () => _launchExternal(
                        context,
                        'https://wa.me/251991134526',
                        'Could not open WhatsApp',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _launchExternal(
                    context,
                    'https://t.me/Yoni_verse',
                    'Could not open Telegram community',
                  ),
                  child: const Text(
                    'Join my Telegram community',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<void> _launchExternal(
  BuildContext context,
  String url,
  String errorMessage,
) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }
}