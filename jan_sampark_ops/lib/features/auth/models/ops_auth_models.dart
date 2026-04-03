/// Request and response models for Ops Console auth.

// ─────────────────────────────────────────────
// Login
// ─────────────────────────────────────────────

class OpsLoginRequest {
  const OpsLoginRequest({
    required this.mobile,
    required this.password,
  });

  final String mobile;
  final String password;

  Map<String, dynamic> toJson() => {
        'mobile':   mobile,
        'password': password,
      };
}

class OpsLoginResponse {
  const OpsLoginResponse({
    required this.success,
    required this.userId,
    required this.role,
    required this.fullName,
    required this.mobile,
    required this.accessToken,
    required this.refreshToken,
    required this.message,
  });

  final bool   success;
  final String userId;
  final String role;
  final String fullName;
  final String mobile;
  final String accessToken;
  final String refreshToken;
  final String message;

  factory OpsLoginResponse.fromJson(Map<String, dynamic> json) {
    return OpsLoginResponse(
      success:       json['success']       as bool?   ?? true,
      userId:        json['user_id']        as String? ?? '',
      role:          json['role']           as String? ?? '',
      fullName:      json['full_name']      as String? ?? '',
      mobile:        json['mobile']         as String? ?? '',
      accessToken:   json['access_token']   as String? ?? '',
      refreshToken:  json['refresh_token']  as String? ?? '',
      message:       json['message']        as String? ?? '',
    );
  }
}
