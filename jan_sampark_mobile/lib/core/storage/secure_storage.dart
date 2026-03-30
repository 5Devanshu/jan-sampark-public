import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Encrypted key-value storage for JWT tokens and user identity.
///
/// Uses the platform keychain (iOS) / keystore (Android).
/// Never store tokens in SharedPreferences — they are not encrypted.
///
/// All methods are static — call SecureStorage.readAccessToken()
/// from anywhere without instantiating.
class SecureStorage {
  SecureStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ─────────────────────────────────────────────
  // Access Token
  // ─────────────────────────────────────────────

  static Future<void> writeAccessToken(String token) async {
    await _storage.write(key: AppConstants.keyAccessToken, value: token);
  }

  static Future<String?> readAccessToken() async {
    return _storage.read(key: AppConstants.keyAccessToken);
  }

  static Future<void> deleteAccessToken() async {
    await _storage.delete(key: AppConstants.keyAccessToken);
  }

  // ─────────────────────────────────────────────
  // Refresh Token
  // ─────────────────────────────────────────────

  static Future<void> writeRefreshToken(String token) async {
    await _storage.write(key: AppConstants.keyRefreshToken, value: token);
  }

  static Future<String?> readRefreshToken() async {
    return _storage.read(key: AppConstants.keyRefreshToken);
  }

  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: AppConstants.keyRefreshToken);
  }

  // ─────────────────────────────────────────────
  // User Identity
  // ─────────────────────────────────────────────

  static Future<void> writeUserId(String userId) async {
    await _storage.write(key: AppConstants.keyUserId, value: userId);
  }

  static Future<String?> readUserId() async {
    return _storage.read(key: AppConstants.keyUserId);
  }

  static Future<void> writeUserRole(String role) async {
    await _storage.write(key: AppConstants.keyUserRole, value: role);
  }

  static Future<String?> readUserRole() async {
    return _storage.read(key: AppConstants.keyUserRole);
  }

  // ─────────────────────────────────────────────
  // Clear All — called on logout
  // ─────────────────────────────────────────────

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ─────────────────────────────────────────────
  // Convenience — write all auth data at once
  // ─────────────────────────────────────────────

  static Future<void> writeAuthSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String userRole,
  }) async {
    await Future.wait([
      writeAccessToken(accessToken),
      writeRefreshToken(refreshToken),
      writeUserId(userId),
      writeUserRole(userRole),
    ]);
  }

  /// Returns true if a valid access token exists in storage.
  /// Does not validate the JWT signature — just checks presence.
  static Future<bool> hasSession() async {
    final token = await readAccessToken();
    return token != null && token.isNotEmpty;
  }
}
