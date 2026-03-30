import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_storage.dart';
import '../constants/app_constants.dart';

/// Manages the app's display language.
///
/// Supported: English, Hindi, Marathi, Gujarati.
/// Language code is persisted in SharedPreferences and
/// applied to MaterialApp.locale.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final code = LocalStorage.getLanguage();
    return Locale(code);
  }

  Future<void> setLocale(String languageCode) async {
    await LocalStorage.setLanguage(languageCode);
    state = Locale(languageCode);
  }

  String get currentLanguageName =>
      AppConstants.supportedLanguages[state.languageCode] ?? 'English';
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

/// All locales the app supports — passed to MaterialApp.supportedLocales.
const List<Locale> appSupportedLocales = [
  Locale('en'),
  Locale('hi'),
  Locale('mr'),
  Locale('gu'),
];
