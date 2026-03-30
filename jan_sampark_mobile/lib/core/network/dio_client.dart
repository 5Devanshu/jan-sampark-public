import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constants.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'refresh_interceptor.dart';

/// The singleton Dio HTTP client for Jan Sampark.
///
/// Interceptor chain (execution order on request):
///   1. AuthInterceptor    — inject Bearer token
///   2. ErrorInterceptor   — map DioException → AppException
///   3. RefreshInterceptor — auto-refresh on 401
///   4. PrettyDioLogger    — dev-only request/response logging
///
/// On response the chain runs in reverse:
///   RefreshInterceptor → ErrorInterceptor → AuthInterceptor
///
/// Usage:
///   final dio = ref.watch(dioProvider);
///   final response = await dio.get('/complaints');
class DioClient {
  DioClient._();

  static Dio? _instance;

  /// Callback set by the router when the session expires.
  /// Navigates the user to the login screen.
  static void Function()? _onSessionExpired;

  static void setSessionExpiredCallback(void Function() callback) {
    _onSessionExpired = callback;
  }

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl:         AppConstants.baseUrl,
        connectTimeout:  Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout:  Duration(milliseconds: AppConstants.receiveTimeoutMs),
        sendTimeout:     Duration(milliseconds: AppConstants.sendTimeoutMs),
        headers: {
          'Accept':       'application/json',
          'Content-Type': 'application/json',
        },
        responseType:    ResponseType.json,
        validateStatus:  (status) => status != null && status < 500,
      ),
    );

    // ── Interceptors ─────────────────────────────
    // Order matters — they run in registration order on request
    // and in reverse on response/error

    dio.interceptors.addAll([
      AuthInterceptor(),

      RefreshInterceptor(
        dio,
        onSessionExpired: () => _onSessionExpired?.call(),
      ),

      ErrorInterceptor(),

      // Pretty logger — disabled in release mode
      if (const bool.fromEnvironment('dart.vm.product') == false)
        PrettyDioLogger(
          requestHeader:  false,
          requestBody:    true,
          responseHeader: false,
          responseBody:   true,
          error:          true,
          compact:        true,
          maxWidth:       90,
        ),
    ]);

    return dio;
  }

  /// Call this when logging out to reset the interceptor state.
  static void reset() {
    _instance = null;
  }
}

// ─────────────────────────────────────────────
// Riverpod Provider
// ─────────────────────────────────────────────

/// Provides the singleton Dio instance to the entire app.
///
/// Usage:
///   final dio = ref.watch(dioProvider);
final dioProvider = Provider<Dio>((ref) {
  return DioClient.instance;
});

// ─────────────────────────────────────────────
// Base Repository
// ─────────────────────────────────────────────

/// Base class for all repository classes.
/// Provides [dio] and the [safeCall] helper.
///
/// Usage:
///   class AuthRepository extends BaseRepository {
///     AuthRepository(super.dio);
///
///     Future<ApiResponse<LoginResponse>> login(...) async {
///       return safeCall(() async {
///         final res = await dio.post('/auth/login', data: data);
///         return LoginResponse.fromJson(res.data);
///       });
///     }
///   }
abstract class BaseRepository {
  const BaseRepository(this.dio);

  final Dio dio;

  /// Wraps any Dio call in a try/catch and returns [ApiResponse].
  ///
  /// Converts [DioException] → [AppException] → [ApiResponse.error].
  /// Converts successful results → [ApiResponse.success].
  Future<ApiResponse<T>> safeCall<T>(
    Future<T> Function() call,
  ) async {
    try {
      final result = await call();
      return ApiResponse.success(result);
    } on DioException catch (e) {
      final appException = e.error is AppException
          ? e.error as AppException
          : UnknownException(e.message);
      return ApiResponse.error(appException, statusCode: e.response?.statusCode);
    } on AppException catch (e) {
      return ApiResponse.error(e, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error(UnknownException(e.toString()));
    }
  }
}

// ─────────────────────────────────────────────
// Imports needed in this file
// ─────────────────────────────────────────────
import '../exceptions/app_exception.dart';
import 'api_response.dart';