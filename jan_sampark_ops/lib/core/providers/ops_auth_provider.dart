import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/ops_storage.dart';

// ─────────────────────────────────────────────
// Ops User Model
// ─────────────────────────────────────────────

class OpsCurrentUser {
  const OpsCurrentUser({
    required this.userId,
    required this.fullName,
    required this.role,
    this.mobile,
  });

  final String  userId;
  final String  fullName;
  final String  role;
  final String? mobile;

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty
        ? fullName[0].toUpperCase()
        : 'O';
  }
}

// ─────────────────────────────────────────────
// Auth State
// ─────────────────────────────────────────────

enum OpsAuthStatus { loading, authenticated, unauthenticated }

class OpsAuthState {
  const OpsAuthState({
    this.status = OpsAuthStatus.loading,
    this.user,
  });

  final OpsAuthStatus   status;
  final OpsCurrentUser? user;

  bool get isLoading        => status == OpsAuthStatus.loading;
  bool get isAuthenticated  => status == OpsAuthStatus.authenticated;
  bool get isUnauthenticated => status == OpsAuthStatus.unauthenticated;

  OpsAuthState copyWith({
    OpsAuthStatus?   status,
    OpsCurrentUser?  user,
  }) {
    return OpsAuthState(
      status: status ?? this.status,
      user:   user   ?? this.user,
    );
  }
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class OpsAuthNotifier extends StateNotifier<OpsAuthState> {
  OpsAuthNotifier() : super(const OpsAuthState()) {
    _init();
  }

  Future<void> _init() async {
    final hasSession = await OpsStorage.hasValidSession();
    if (!hasSession) {
      state = state.copyWith(
          status: OpsAuthStatus.unauthenticated);
      return;
    }

    final userId   = await OpsStorage.readUserId()   ?? '';
    final fullName = await OpsStorage.readFullName() ?? '';
    final role     = await OpsStorage.readRole()     ?? '';
    final mobile   = await OpsStorage.readMobile();

    state = state.copyWith(
      status: OpsAuthStatus.authenticated,
      user: OpsCurrentUser(
        userId:   userId,
        fullName: fullName,
        role:     role,
        mobile:   mobile,
      ),
    );
  }

  Future<void> setAuthenticated({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String fullName,
    required String role,
    String? mobile,
  }) async {
    await OpsStorage.writeSession(
      accessToken:  accessToken,
      refreshToken: refreshToken,
      userId:       userId,
      role:         role,
      fullName:     fullName,
      mobile:       mobile,
    );

    state = state.copyWith(
      status: OpsAuthStatus.authenticated,
      user: OpsCurrentUser(
        userId:   userId,
        fullName: fullName,
        role:     role,
        mobile:   mobile,
      ),
    );
  }

  Future<void> signOut() async {
    await OpsStorage.clearSession();
    state = const OpsAuthState(
        status: OpsAuthStatus.unauthenticated);
  }
}

final opsAuthProvider = StateNotifierProvider<OpsAuthNotifier, OpsAuthState>((ref) {
  return OpsAuthNotifier();
});

/// Convenience — current user or null
final opsCurrentUserProvider =
    Provider<OpsCurrentUser?>((ref) {
  return ref.watch(opsAuthProvider).user;
});