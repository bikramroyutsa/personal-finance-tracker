import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  final double dailyMax;
  final double monthlyMax;
  final String currency;
  final bool isFirstTime;
  final bool enableFloatingBubble;

  UserSettings({
    required this.dailyMax,
    required this.monthlyMax,
    required this.currency,
    required this.isFirstTime,
    this.enableFloatingBubble = false,
  });

  UserSettings copyWith({
    double? dailyMax,
    double? monthlyMax,
    String? currency,
    bool? isFirstTime,
    bool? enableFloatingBubble,
  }) {
    return UserSettings(
      dailyMax: dailyMax ?? this.dailyMax,
      monthlyMax: monthlyMax ?? this.monthlyMax,
      currency: currency ?? this.currency,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      enableFloatingBubble: enableFloatingBubble ?? this.enableFloatingBubble,
    );
  }
}

final ValueNotifier<UserSettings> settingsNotifier = ValueNotifier(
  UserSettings(
    dailyMax: 150.0,
    monthlyMax: 3000.0,
    currency: '\$',
    isFirstTime: false,
    enableFloatingBubble: false,
  ),
);

SharedPreferences? _prefs;
bool _isInitialized = false;

Future<void> initSettings() async {
  if (_isInitialized && _prefs != null) return;
  _prefs = await SharedPreferences.getInstance();
  
  final dailyMax = _prefs!.getDouble('dailyMax') ?? 150.0;
  final monthlyMax = _prefs!.getDouble('monthlyMax') ?? 3000.0;
  final currency = _prefs!.getString('currency') ?? '\$';
  final isFirstTime = _prefs!.getBool('isFirstTime') ?? true;
  final enableFloatingBubble = _prefs!.getBool('enableFloatingBubble') ?? false;

  settingsNotifier.value = UserSettings(
    dailyMax: dailyMax,
    monthlyMax: monthlyMax,
    currency: currency,
    isFirstTime: isFirstTime,
    enableFloatingBubble: enableFloatingBubble,
  );

  if (!_isInitialized) {
    _isInitialized = true;
    settingsNotifier.addListener(() {
      final settings = settingsNotifier.value;
      _prefs?.setDouble('dailyMax', settings.dailyMax);
      _prefs?.setDouble('monthlyMax', settings.monthlyMax);
      _prefs?.setString('currency', settings.currency);
      _prefs?.setBool('isFirstTime', settings.isFirstTime);
      _prefs?.setBool('enableFloatingBubble', settings.enableFloatingBubble);
    });
  }
}
