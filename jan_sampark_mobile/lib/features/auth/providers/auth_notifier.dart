import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';
import '../../../core/exceptions/app_exception.dart';

// ─────────────────────────────────────────────
// Login State
// ─────────────────────────────────────────────

enum LoginStatus { idle, loading, success, error }

class LoginState {
  const LoginState({
    this.status       = LoginStatus.idle,
    this.errorMessage = '',
  });

  final LoginStatus status;
  final String errorMessage;

  bool get isLoading => status == LoginStatus.loading;
  bool get hasError  => status == LoginStatus.error;

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      status:       status       ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// Login Notifier
// ─────────────────────────────────────────────

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier(this._repo, this._authNotifier)
      : super(const LoginState());

  final AuthRepository _repo;
  final AuthNotifier   _authNotifier;

  Future<bool> login({
    required String mobile,
    required String password,
  }) async {
    state = state.copyWith(
      status:       LoginStatus.loading,
      errorMessage: '',
    );

    final response = await _repo.login(
      LoginRequest(mobile: mobile.trim(), password: password),
    );

    return response.when(
      success: (data) async {
        await _authNotifier.setAuthenticated(
          accessToken:  data.accessToken,
          refreshToken: data.refreshToken,
          userId:       data.userId,
          role:         data.role,
          fullName:     data.fullName,
        );
        state = state.copyWith(status: LoginStatus.success);
        return true;
      },
      error: (e) {
        state = state.copyWith(
          status:       LoginStatus.error,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
        return false;
      },
    );
  }

  void reset() => state = const LoginState();
}

final loginProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(
    ref.watch(authRepositoryProvider),
    ref.read(authProvider.notifier),
  );
});

// ─────────────────────────────────────────────
// Registration State
// ─────────────────────────────────────────────

enum RegisterStatus { idle, loading, success, error }

class RegisterState {
  const RegisterState({
    this.status       = RegisterStatus.idle,
    this.errorMessage = '',
  });

  final RegisterStatus status;
  final String errorMessage;

  bool get isLoading => status == RegisterStatus.loading;
  bool get hasError  => status == RegisterStatus.error;

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
  }) {
    return RegisterState(
      status:       status       ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// Registration Notifier
// ─────────────────────────────────────────────

class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier(this._repo, this._authNotifier)
      : super(const RegisterState());

  final AuthRepository _repo;
  final AuthNotifier   _authNotifier;

  Future<bool> register({
    required RegisterRequest request,
    String? documentPath,
  }) async {
    state = state.copyWith(
      status:       RegisterStatus.loading,
      errorMessage: '',
    );

    final response = await _repo.register(
      request:      request,
      documentPath: documentPath,
    );

    return response.when(
      success: (data) async {
        await _authNotifier.setAuthenticated(
          accessToken:  data.accessToken,
          refreshToken: data.refreshToken,
          userId:       data.userId,
          role:         data.role,
          fullName:     data.fullName,
        );
        state = state.copyWith(status: RegisterStatus.success);
        return true;
      },
      error: (e) {
        state = state.copyWith(
          status:       RegisterStatus.error,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
        return false;
      },
    );
  }

  void reset() => state = const RegisterState();
}

final registerProvider =
    StateNotifierProvider.autoDispose<RegisterNotifier, RegisterState>(
        (ref) {
  return RegisterNotifier(
    ref.watch(authRepositoryProvider),
    ref.read(authProvider.notifier),
  );
});

// ─────────────────────────────────────────────
// Areas / Wards State (for registration step 2)
// ─────────────────────────────────────────────

final areasProvider =
    FutureProvider.autoDispose<List<AreaModel>>((ref) async {
  final repo     = ref.watch(authRepositoryProvider);
  final response = await repo.fetchAreas();
  return response.when(
    success: (data) => data,
    error:   (e) => throw e,
  );
});

final wardsForAreaProvider =
    FutureProvider.autoDispose.family<List<WardModel>, String>(
        (ref, areaId) async {
  if (areaId.isEmpty) return [];
  final repo     = ref.watch(authRepositoryProvider);
  final response = await repo.fetchWardsByArea(areaId);
  return response.when(
    success: (data) => data,
    error:   (e) => throw e,
  );
});