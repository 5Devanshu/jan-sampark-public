/// Typed exception hierarchy for Jan Sampark.
///
/// Every error in the app is one of these — from network failures
/// to validation errors to auth problems. The UI layer maps these
/// to user-facing messages via [AppException.message].
///
/// Usage:
///   try {
///     await repository.login(data);
///   } on AppException catch (e) {
///     showError(e.message);
///   }
sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AppException: $message (code: $statusCode)';
}

// ─────────────────────────────────────────────
// Network Exceptions
// ─────────────────────────────────────────────

/// No internet connection or DNS failure
class NetworkException extends AppException {
  const NetworkException([String? message])
    : super(message ?? 'No internet connection. Please check your network.');
}

/// Request timed out
class TimeoutException extends AppException {
  const TimeoutException([String? message])
    : super(message ?? 'Request timed out. Please try again.');
}

/// Server returned an unexpected response format
class ServerException extends AppException {
  const ServerException([String? message, int? statusCode])
    : super(
        message ?? 'Server error. Please try again later.',
        statusCode: statusCode,
      );
}

// ─────────────────────────────────────────────
// Auth Exceptions
// ─────────────────────────────────────────────

/// 401 — Invalid or expired token, bad credentials
class UnauthorizedException extends AppException {
  const UnauthorizedException([String? message])
    : super(message ?? 'Invalid mobile number or password.', statusCode: 401);
}

/// 403 — Authenticated but not allowed
class ForbiddenException extends AppException {
  const ForbiddenException([String? message])
    : super(
        message ?? 'You do not have permission to perform this action.',
        statusCode: 403,
      );
}

/// Session expired and refresh failed
class SessionExpiredException extends AppException {
  const SessionExpiredException()
    : super('Your session has expired. Please log in again.', statusCode: 401);
}

// ─────────────────────────────────────────────
// Resource Exceptions
// ─────────────────────────────────────────────

/// 404 — Resource not found
class NotFoundException extends AppException {
  const NotFoundException([String? message])
    : super(message ?? 'The requested item was not found.', statusCode: 404);
}

/// 409 — Conflict (duplicate mobile, duplicate vote etc.)
class ConflictException extends AppException {
  const ConflictException([String? message])
    : super(
        message ?? 'A conflict occurred. This item may already exist.',
        statusCode: 409,
      );
}

/// 413 — File too large
class FileTooLargeException extends AppException {
  const FileTooLargeException([String? message])
    : super(
        message ?? 'File size exceeds the maximum allowed limit.',
        statusCode: 413,
      );
}

// ─────────────────────────────────────────────
// Validation Exceptions
// ─────────────────────────────────────────────

/// 400 / 422 — Validation error from backend
class ValidationException extends AppException {
  const ValidationException([String? message])
    : super(
        message ?? 'Please check your input and try again.',
        statusCode: 422,
      );
}

// ─────────────────────────────────────────────
// Rate Limit Exception
// ─────────────────────────────────────────────

/// 429 — Too many requests
class RateLimitException extends AppException {
  const RateLimitException([String? message])
    : super(
        message ?? 'Too many requests. Please wait a moment and try again.',
        statusCode: 429,
      );
}

// ─────────────────────────────────────────────
// Unknown Exception
// ─────────────────────────────────────────────

/// Catch-all for unexpected errors
class UnknownException extends AppException {
  const UnknownException([String? message])
    : super(message ?? 'Something went wrong. Please try again.');
}
