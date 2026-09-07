import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  final double dailyMax;
  final double monthlyMax;
  final String currency;
  final bool isFirstTime;

  UserSettings({
    required this.dailyMax,
    required this.monthlyMax,
    required this.currency,
    required this.isFirstTime,
  });

  UserSettings copyWith({
    double? dailyMax,
    double? monthlyMax,
    String? currency,
    bool? isFirstTime,
  }) {
    return UserSettings(
      dailyMax: dailyMax ?? this.dailyMax,
      monthlyMax: monthlyMax ?? this.monthlyMax,
      currency: currency ?? this.currency,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }
}

late final ValueNotifier<UserSettings> settingsNotifier;
late SharedPreferences _prefs;

Future<void> initSettings() async {
  _prefs = await SharedPreferences.getInstance();
  
  final dailyMax = _prefs.getDouble('dailyMax') ?? 150.0;
  final monthlyMax = _prefs.getDouble('monthlyMax') ?? 3000.0;
  final currency = _prefs.getString('currency') ?? '\$';
  final isFirstTime = _prefs.getBool('isFirstTime') ?? true;

  settingsNotifier = ValueNotifier(
    UserSettings(
      dailyMax: dailyMax,
      monthlyMax: monthlyMax,
      currency: currency,
      isFirstTime: isFirstTime,
    ),
  );

  settingsNotifier.addListener(() {
    final settings = settingsNotifier.value;
    _prefs.setDouble('dailyMax', settings.dailyMax);
    _prefs.setDouble('monthlyMax', settings.monthlyMax);
    _prefs.setString('currency', settings.currency);
    _prefs.setBool('isFirstTime', settings.isFirstTime);
  });
}
