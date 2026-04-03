/// Typed exception hierarchy for the Ops Console.
sealed class OpsException implements Exception {
  const OpsException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// 4xx client errors returned by the API.
class OpsApiException extends OpsException {
  const OpsApiException({
    required this.statusCode,
    required String message,
    this.detail,
  }) : super(message);

  final int     statusCode;
  final String? detail;

  bool get isUnauthorised => statusCode == 401;
  bool get isForbidden    => statusCode == 403;
  bool get isNotFound     => statusCode == 404;
  bool get isConflict     => statusCode == 409;
  bool get isValidation   => statusCode == 422;
}

/// Network connectivity / timeout errors.
class OpsNetworkException extends OpsException {
  const OpsNetworkException([
    super.message = 'No internet connection. Please try again.',
  ]);
}

/// Token expired and refresh failed.
class OpsAuthException extends OpsException {
  const OpsAuthException([
    super.message = 'Session expired. Please sign in again.',
  ]);
}

/// Unexpected / unknown errors.
class OpsUnknownException extends OpsException {
  const OpsUnknownException([
    super.message = 'An unexpected error occurred.',
  ]);
}