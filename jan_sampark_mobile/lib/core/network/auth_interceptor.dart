import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'api_constants.dart';

/// Injects the Bearer token into every outgoing request.
///
/// Skips auth header injection for public endpoints
/// (login, OTP, refresh, areas, wards, complaint-categories, helpline).
///
/// If no token is found in secure storage the request is
/// sent without the header — the server will return 401
/// which the RefreshInterceptor handles.
class AuthInterceptor extends Interceptor {
  /// Endpoints that do not require authentication
  static const _publicPaths = {
    '/auth/login',
    '/auth/register/send-otp',
    '/auth/register/verify-otp',
    '/auth/register/complete',
    '/auth/refresh',
    '/areas',
    '/wards',
    '/complaint-categories',
    '/helpline-numbers',
    '/auth/professions',
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;

    // Skip token injection for public endpoints
    final isPublic = _publicPaths.any((p) => path.contains(p));

    if (!isPublic) {
      final token = await SecureStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers[ApiConstants.headerAuthorization] =
            '${ApiConstants.bearerPrefix}$token';
      }
    }

    return handler.next(options);
  }
}
