import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.currencyCode,
    required this.languageCode,
    required this.notificationsEnabled,
    required this.pinEnabled,
    required this.biometricsEnabled,
  });

  final ThemeMode themeMode;
  final String currencyCode;
  final String languageCode;
  final bool notificationsEnabled;
  final bool pinEnabled;
  final bool biometricsEnabled;

  static const AppSettings defaults = AppSettings(
    themeMode: ThemeMode.system,
    currencyCode: 'USD',
    languageCode: 'en',
    notificationsEnabled: true,
    pinEnabled: false,
    biometricsEnabled: false,
  );

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? currencyCode,
    String? languageCode,
    bool? notificationsEnabled,
    bool? pinEnabled,
    bool? biometricsEnabled,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        currencyCode: currencyCode ?? this.currencyCode,
        languageCode: languageCode ?? this.languageCode,
        notificationsEnabled:
            notificationsEnabled ?? this.notificationsEnabled,
        pinEnabled: pinEnabled ?? this.pinEnabled,
        biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'themeMode': themeMode.name,
        'currencyCode': currencyCode,
        'languageCode': languageCode,
        'notificationsEnabled': notificationsEnabled,
        'pinEnabled': pinEnabled,
        'biometricsEnabled': biometricsEnabled,
      };

  factory AppSettings.fromJson(Map<String, Object?> json) => AppSettings(
        themeMode: ThemeMode.values.byName(json['themeMode'] as String),
        currencyCode: json['currencyCode'] as String,
        languageCode: json['languageCode'] as String,
        notificationsEnabled: json['notificationsEnabled'] as bool,
        pinEnabled: json['pinEnabled'] as bool,
        biometricsEnabled: json['biometricsEnabled'] as bool,
      );
}
