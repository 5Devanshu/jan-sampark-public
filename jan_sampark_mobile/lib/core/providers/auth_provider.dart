import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';
import '../storage/local_storage.dart';

/// Represents the current authentication state of the app.
enum AuthStatus {
  /// Initial state — checking token in secure storage
  checking,

  /// No token found or token invalid
  unauthenticated,

  /// Valid token found — role is set
  authenticated,
}

/// Current user identity from secure storage.
class CurrentUser {
  const CurrentUser({
    required this.userId,
    required this.role,
    required this.fullName,
  });

  final String userId;
  final String role;
  final String fullName;

  bool get isVoter => role == 'voter';
  bool get isLeader => role == 'leader';
  bool get isCorporator => role == 'corporator';
  bool get isOps => role == 'ops';

  @override
  String toString() =>
      'CurrentUser(userId: $userId, role: $role, name: $fullName)';
}

// ─────────────────────────────────────────────
// Auth State Notifier
// ─────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<CurrentUser?> {
  @override
  Future<CurrentUser?> build() async {
    return _loadFromStorage();
  }

  Future<CurrentUser?> _loadFromStorage() async {
    final token = await SecureStorage.readAccessToken();
    if (token == null || token.isEmpty) return null;

    final userId = await SecureStorage.readUserId();
    final role = await SecureStorage.readUserRole();
    final fullName = LocalStorage.getUserFullName();

    if (userId == null || role == null) return null;

    return CurrentUser(userId: userId, role: role, fullName: fullName ?? '');
  }

  /// Called after successful login or registration.
  Future<void> setAuthenticated({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
    required String fullName,
  }) async {
    await SecureStorage.writeAuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      userRole: role,
    );
    await LocalStorage.setUserFullName(fullName);
    await LocalStorage.setLastKnownRole(role);

    state = AsyncData(
      CurrentUser(userId: userId, role: role, fullName: fullName),
    );
  }

  /// Called on logout or session expiry.
  Future<void> signOut() async {
    await SecureStorage.clearAll();
    await LocalStorage.clearAll();
    state = const AsyncData(null);
  }

  /// Update full name locally after profile edit.
  void updateFullName(String name) {
    LocalStorage.setUserFullName(name);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        CurrentUser(userId: current.userId, role: current.role, fullName: name),
      );
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, CurrentUser?>(
  AuthNotifier.new,
);

// ─────────────────────────────────────────────
// Convenience providers
// ─────────────────────────────────────────────

/// Returns true when the user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.valueOrNull != null;
});

/// Returns the current user or null.
final currentUserProvider = Provider<CurrentUser?>((ref) {
  return ref.watch(authProvider).valueOrNull;
});

/// Returns the current user's role string.
final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.role;
});
