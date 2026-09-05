import 'package:flutter/foundation.dart';

class UserSettings {
  final double dailyMax;
  final double monthlyMax;
  final String currency;

  UserSettings({
    required this.dailyMax,
    required this.monthlyMax,
    required this.currency,
  });

  UserSettings copyWith({
    double? dailyMax,
    double? monthlyMax,
    String? currency,
  }) {
    return UserSettings(
      dailyMax: dailyMax ?? this.dailyMax,
      monthlyMax: monthlyMax ?? this.monthlyMax,
      currency: currency ?? this.currency,
    );
  }
}

final ValueNotifier<UserSettings> settingsNotifier = ValueNotifier(
  UserSettings(
    dailyMax: 150.0,
    monthlyMax: 3000.0,
    currency: '\$',
  ),
);
