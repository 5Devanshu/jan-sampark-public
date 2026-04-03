import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/exceptions/ops_exception.dart';
import '../../../core/network/ops_api_response.dart';
import '../../../core/providers/ops_auth_provider.dart';
import '../models/ops_auth_models.dart';
import '../repositories/ops_auth_repository.dart';

// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────

enum OpsLoginStatus { idle, loading, success, error }

class OpsLoginState {
  const OpsLoginState({
    this.status       = OpsLoginStatus.idle,
    this.errorMessage = '',
  });

  final OpsLoginStatus status;
  final String         errorMessage;

  bool get isLoading => status == OpsLoginStatus.loading;
  bool get hasError  => status == OpsLoginStatus.error;
  bool get isSuccess => status == OpsLoginStatus.success;

  OpsLoginState copyWith({
    OpsLoginStatus? status,
    String?         errorMessage,
  }) {
    return OpsLoginState(
      status:       status       ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class OpsLoginNotifier extends StateNotifier<OpsLoginState> {
  OpsLoginNotifier(this._repo, this._authNotifier)
      : super(const OpsLoginState());

  final OpsAuthRepository _repo;
  final OpsAuthNotifier   _authNotifier;

  Future<bool> login({
    required String mobile,
    required String password,
  }) async {
    state = state.copyWith(
      status:       OpsLoginStatus.loading,
      errorMessage: '',
    );

    final response = await _repo.login(
      mobile:   mobile,
      password: password,
    );

    if (response is OpsSuccess<OpsLoginResponse>) {
      final data = response.data;

      // Reject non-ops roles immediately
      if (data.role != 'ops') {
        state = state.copyWith(
          status:       OpsLoginStatus.error,
          errorMessage: 'Access denied. '
              'This console is for Ops accounts only.',
        );
        return false;
      }

      await _authNotifier.setAuthenticated(
        accessToken:  data.accessToken,
        refreshToken: data.refreshToken,
        userId:       data.userId,
        role:         data.role,
        fullName:     data.fullName,
        mobile:       data.mobile,
      );

      state = state.copyWith(status: OpsLoginStatus.success);
      return true;
    } else if (response is OpsError) {
      final e = response.exception;
      final message = switch (e) {
        OpsApiException(statusCode: 401) =>
            'Incorrect mobile number or password.',
        OpsApiException(statusCode: 403) =>
            'Your account has been deactivated.',
        OpsNetworkException() =>
            'Cannot connect to the server. '
            'Check your network and try again.',
        _ => e.message,
      };

      state = state.copyWith(
        status:       OpsLoginStatus.error,
        errorMessage: message,
      );
      return false;
    }

    return false;
  }

  void reset() => state = const OpsLoginState();
}

final opsLoginProvider = StateNotifierProvider
    .autoDispose<OpsLoginNotifier, OpsLoginState>((ref) {
  return OpsLoginNotifier(
    ref.watch(opsAuthRepositoryProvider),
    ref.read(opsAuthProvider.notifier),
  );
});