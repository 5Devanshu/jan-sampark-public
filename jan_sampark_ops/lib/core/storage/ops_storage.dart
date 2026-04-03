import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/ops_constants.dart';

/// Secure persistent storage for session tokens.
///
/// On Web: flutter_secure_storage uses localStorage
/// (no native keychain available).
/// On Desktop: uses platform keychain if available.
class OpsStorage {
  OpsStorage._();

  static const _storage = FlutterSecureStorage(
    webOptions: WebOptions(
      dbName:       'jan_sampark_ops',
      publicKey:    'js_ops_pub',
    ),
  );

  // ─────────────────────────────────────────────
  // Write
  // ─────────────────────────────────────────────

  static Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(
          key: OpsConstants.keyAccessToken,
          value: accessToken),
      _storage.write(
          key: OpsConstants.keyRefreshToken,
          value: refreshToken),
    ]);
  }

  static Future<void> writeSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
    required String fullName,
    String? mobile,
  }) async {
    await Future.wait([
      _storage.write(
          key: OpsConstants.keyAccessToken,
          value: accessToken),
      _storage.write(
          key: OpsConstants.keyRefreshToken,
          value: refreshToken),
      _storage.write(
          key: OpsConstants.keyUserId,
          value: userId),
      _storage.write(
          key: OpsConstants.keyRole,
          value: role),
      _storage.write(
          key: OpsConstants.keyFullName,
          value: fullName),
      if (mobile != null)
        _storage.write(
            key: OpsConstants.keyMobile,
            value: mobile),
    ]);
  }

  // ─────────────────────────────────────────────
  // Read
  // ─────────────────────────────────────────────

  static Future<String?> readAccessToken() =>
      _storage.read(key: OpsConstants.keyAccessToken);

  static Future<String?> readRefreshToken() =>
      _storage.read(key: OpsConstants.keyRefreshToken);

  static Future<String?> readUserId() =>
      _storage.read(key: OpsConstants.keyUserId);

  static Future<String?> readRole() =>
      _storage.read(key: OpsConstants.keyRole);

  static Future<String?> readFullName() =>
      _storage.read(key: OpsConstants.keyFullName);

  static Future<String?> readMobile() =>
      _storage.read(key: OpsConstants.keyMobile);

  // ─────────────────────────────────────────────
  // Session check
  // ─────────────────────────────────────────────

  static Future<bool> hasValidSession() async {
    final token = await readAccessToken();
    final role  = await readRole();
    return token != null && token.isNotEmpty && role == 'ops';
  }

  // ─────────────────────────────────────────────
  // Clear
  // ─────────────────────────────────────────────

  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}