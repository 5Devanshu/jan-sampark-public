import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Wrapper around SharedPreferences for non-sensitive local data.
///
/// Stores user preferences (language, onboarding state) and
/// cached display values (full name for greeting).
/// Never store tokens here — use SecureStorage instead.
///
/// Must be initialised before use by calling LocalStorage.init().
/// Called once in main.dart before runApp().
class LocalStorage {
  LocalStorage._();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─────────────────────────────────────────────
  // Language
  // ─────────────────────────────────────────────

  static String getLanguage() =>
      _prefs.getString(AppConstants.prefLanguage) ?? 'en';

  static Future<void> setLanguage(String code) =>
      _prefs.setString(AppConstants.prefLanguage, code);

  // ─────────────────────────────────────────────
  // Onboarding
  // ─────────────────────────────────────────────

  static bool isOnboardingDone() =>
      _prefs.getBool(AppConstants.prefOnboardingDone) ?? false;

  static Future<void> setOnboardingDone() =>
      _prefs.setBool(AppConstants.prefOnboardingDone, true);

  // ─────────────────────────────────────────────
  // Cached User Display Values
  // ─────────────────────────────────────────────

  static String? getUserFullName() =>
      _prefs.getString(AppConstants.prefUserFullName);

  static Future<void> setUserFullName(String name) =>
      _prefs.setString(AppConstants.prefUserFullName, name);

  static String? getLastKnownRole() =>
      _prefs.getString(AppConstants.prefLastKnownRole);

  static Future<void> setLastKnownRole(String role) =>
      _prefs.setString(AppConstants.prefLastKnownRole, role);

  // ─────────────────────────────────────────────
  // Notification Permission
  // ─────────────────────────────────────────────

  static bool hasAskedNotifPermission() =>
      _prefs.getBool(AppConstants.prefNotifPermAsked) ?? false;

  static Future<void> setNotifPermissionAsked() =>
      _prefs.setBool(AppConstants.prefNotifPermAsked, true);

  // ─────────────────────────────────────────────
  // Clear All — called on logout
  // ─────────────────────────────────────────────

  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
