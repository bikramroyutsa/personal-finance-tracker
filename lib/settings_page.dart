import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:currency_picker/currency_picker.dart';
import 'main.dart'; // For themeNotifier
import 'settings_state.dart';
import 'manage_categories_page.dart';
import 'services/database_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _dailyController;
  late TextEditingController _monthlyController;

  @override
  void initState() {
    super.initState();
    _dailyController = TextEditingController(text: settingsNotifier.value.dailyMax.toString());
    _monthlyController = TextEditingController(text: settingsNotifier.value.monthlyMax.toString());
  }

  @override
  void dispose() {
    _dailyController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  void _updateDaily(String value) {
    final val = double.tryParse(value);
    if (val != null) {
      settingsNotifier.value = settingsNotifier.value.copyWith(dailyMax: val);
    }
  }

  void _updateMonthly(String value) {
    final val = double.tryParse(value);
    if (val != null) {
      settingsNotifier.value = settingsNotifier.value.copyWith(monthlyMax: val);
    }
  }

  void _showResetConfirmation(BuildContext context) {
    final randomString = (Random().nextInt(90000) + 10000).toString(); // 5 digit random number
    String typedString = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(LucideIcons.alertTriangle, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Reset All Data', style: TextStyle(color: Colors.red)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WARNING: This will permanently delete all your transactions, custom categories, and data. This action CANNOT be undone.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'To confirm, please type this code: $randomString',
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type code here',
                    ),
                    onChanged: (value) {
                      setState(() {
                        typedString = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: typedString == randomString
                      ? () async {
                          final messenger = ScaffoldMessenger.of(context);
                          Navigator.of(dialogContext).pop();
                          await DatabaseService().resetAllData();
                          if (!mounted) return;
                          
                          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const MainScreen()),
                            (route) => false,
                          );

                          messenger.showSnackBar(
                            const SnackBar(content: Text('All data has been reset successfully.')),
                          );
                        }
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Reset Data'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<UserSettings>(
          valueListenable: settingsNotifier,
          builder: (context, settings, child) {
            return ListView(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 120),
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Theme Toggle
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(isDark ? LucideIcons.moon : LucideIcons.sun, color: textColor),
                    title: Text('Dark Mode', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                    trailing: Switch(
                      value: isDark,
                      onChanged: (val) {
                        themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                      },
                      activeColor: const Color(0xFF6366F1),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Budgets Header
                Text(
                  'Budgets & Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Manage Categories
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(LucideIcons.tags, color: textColor),
                    title: Text('Manage Categories', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                    trailing: Icon(LucideIcons.chevronRight, color: textColor.withOpacity(0.5), size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageCategoriesPage()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Daily Max
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _dailyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      icon: Icon(LucideIcons.calendar, color: textColor),
                      labelText: 'Daily Max Spend',
                      labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                      border: InputBorder.none,
                      suffixText: settings.currency,
                    ),
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    onChanged: _updateDaily,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Monthly Max
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _monthlyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      icon: Icon(LucideIcons.calendarDays, color: textColor),
                      labelText: 'Monthly Max Spend',
                      labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                      border: InputBorder.none,
                      suffixText: settings.currency,
                    ),
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    onChanged: _updateMonthly,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Currency Selector (All world currencies)
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(LucideIcons.banknote, color: textColor),
                    title: Text('Currency', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(settings.currency, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 8),
                        Icon(LucideIcons.chevronRight, color: textColor.withOpacity(0.5), size: 20),
                      ],
                    ),
                    onTap: () {
                      showCurrencyPicker(
                        context: context,
                        showFlag: true,
                        showCurrencyName: true,
                        showCurrencyCode: true,
                        theme: CurrencyPickerThemeData(
                          backgroundColor: cardBg,
                          titleTextStyle: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                          subtitleTextStyle: TextStyle(color: textColor.withOpacity(0.7)),
                        ),
                        onSelect: (Currency currency) {
                          settingsNotifier.value = settings.copyWith(currency: currency.symbol);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                
                // Export
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(LucideIcons.download, color: textColor),
                    title: Text('Export to CSV', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export functionality coming soon!')),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                
                // Reset Data Section
                Text(
                  'Danger Zone',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Reset All Data
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: ListTile(
                    leading: const Icon(LucideIcons.trash2, color: Colors.red),
                    title: const Text('Reset All Data', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    subtitle: Text('Permanently delete all data', style: TextStyle(color: Colors.red.withOpacity(0.7), fontSize: 12)),
                    onTap: () => _showResetConfirmation(context),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
