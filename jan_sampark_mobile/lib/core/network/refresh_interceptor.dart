import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import 'api_constants.dart';
import '../exceptions/app_exception.dart';
/// Handles automatic token refresh on 401 responses.
///
/// Flow:
///   1. Request gets a 401 Unauthorized response
///   2. RefreshInterceptor reads the refresh token from secure storage
///   3. Calls POST /auth/refresh with the refresh token
///   4. On success — stores new access token, retries original request
///   5. On failure — clears all tokens, redirects to login
///
/// A lock is used so that if multiple requests return 401
/// simultaneously only one refresh call is made and the others
/// wait for the result.
class RefreshInterceptor extends Interceptor {
  RefreshInterceptor(this._dio, {this.onSessionExpired});

  final Dio _dio;

  /// Called when refresh fails — typically navigates to login screen
  final void Function()? onSessionExpired;

  // Lock to prevent concurrent refresh calls
  bool _isRefreshing = false;
  final List<({
    RequestOptions options,
    ErrorInterceptorHandler handler,
  })> _pendingRequests = [];

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 and only if this is not already a refresh call
    final is401 = err.response?.statusCode == ApiConstants.statusUnauthorized;
    final isRefreshEndpoint = err.requestOptions.path.contains('/auth/refresh');

    if (!is401 || isRefreshEndpoint) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      // Queue this request to retry after refresh completes
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await SecureStorage.readRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        _handleSessionExpired(handler, err);
        return;
      }

      // Call the refresh endpoint
      final refreshResponse = await _dio.post(
        AppConstants.endpointRefresh,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            ApiConstants.headerAuthorization: null, // No token on refresh
          },
        ),
      );

      final newAccessToken =
          refreshResponse.data['access_token'] as String?;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        _handleSessionExpired(handler, err);
        return;
      }

      // Store new access token
      await SecureStorage.writeAccessToken(newAccessToken);

      // Retry original failed request with new token
      final retryOptions = err.requestOptions
        ..headers[ApiConstants.headerAuthorization] =
            '${ApiConstants.bearerPrefix}$newAccessToken';

      final retryResponse = await _dio.fetch(retryOptions);
      handler.resolve(retryResponse);

      // Retry any pending requests that were queued during refresh
      for (final pending in _pendingRequests) {
        try {
          pending.options.headers[ApiConstants.headerAuthorization] =
              '${ApiConstants.bearerPrefix}$newAccessToken';
          final r = await _dio.fetch(pending.options);
          pending.handler.resolve(r);
        } catch (e) {
          pending.handler.next(
            DioException(requestOptions: pending.options, error: e),
          );
        }
      }
    } catch (_) {
      _handleSessionExpired(handler, err);

      // Reject all pending requests too
      for (final pending in _pendingRequests) {
        pending.handler.next(
          DioException(
            requestOptions: pending.options,
            error: const SessionExpiredException(),
          ),
        );
      }
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  void _handleSessionExpired(
    ErrorInterceptorHandler handler,
    DioException err,
  ) {
    SecureStorage.clearAll();
    onSessionExpired?.call();
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        error: const SessionExpiredException(),
        response: err.response,
        type: err.type,
      ),
    );
  }
}

// Bring SessionExpiredException into scope
