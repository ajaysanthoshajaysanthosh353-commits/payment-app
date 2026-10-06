import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localeStorageKey = 'selectedLocale';

final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(
  const Locale('en', 'US'),
);

Future<void> loadSavedLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString(_localeStorageKey);
  localeNotifier.value = _parseLocale(savedLocale);
}

Future<void> saveLocale(Locale locale) async {
  final prefs = await SharedPreferences.getInstance();
  final normalizedKey = locale.countryCode == null || locale.countryCode!.isEmpty
      ? locale.languageCode
      : '${locale.languageCode}_${locale.countryCode!}';

  await prefs.setString(_localeStorageKey, normalizedKey);
  localeNotifier.value = locale;
}

Future<void> saveLocaleFromLanguage(String language) async {
  await saveLocale(_localeForLanguage(language));
}

Locale _parseLocale(String? value) {
  if (value == null || value.trim().isEmpty) {
    return const Locale('en', 'US');
  }

  final normalized = value.trim();
  if (normalized.contains('_')) {
    final parts = normalized.split('_');
    return Locale(parts.first, parts.length > 1 ? parts[1] : null);
  }

  switch (normalized.toLowerCase()) {
    case 'en':
      return const Locale('en', 'US');
    case 'ta':
      return const Locale('ta', 'IN');
    case 'hi':
      return const Locale('hi', 'IN');
    case 'ml':
      return const Locale('ml', 'IN');
    default:
      return const Locale('en', 'US');
  }
}

Locale _localeForLanguage(String language) {
  switch (language.trim().toLowerCase()) {
    case 'english':
      return const Locale('en', 'US');
    case 'tamil':
      return const Locale('ta', 'IN');
    case 'hindi':
      return const Locale('hi', 'IN');
    case 'malayalam':
      return const Locale('ml', 'IN');
    default:
      return const Locale('en', 'US');
  }
}
