import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/budget_provider.dart';
import '../../../logic/providers/theme_provider.dart';
import '../../../logic/providers/user_provider.dart';
import '../../../services/export_service.dart';
import '../../../services/budget_storage_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetProvider);
    final themeMode = ref.watch(themeModeProvider);
    final userName = ref.watch(userNameProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('⚙️ Settings'), elevation: 0),
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
            content: Text('PDF exported successfully! ✅'),
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
            content: Text('CSV exported successfully! ✅'),
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
