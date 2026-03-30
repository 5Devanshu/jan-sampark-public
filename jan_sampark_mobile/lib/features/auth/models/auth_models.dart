/// Request and response models for all auth API calls.

// ─────────────────────────────────────────────
// OTP
// ─────────────────────────────────────────────

class SendOtpRequest {
  const SendOtpRequest({required this.mobile});
  final String mobile;

  Map<String, dynamic> toJson() => {'mobile': mobile};
}

class SendOtpResponse {
  const SendOtpResponse({
    required this.success,
    required this.message,
    required this.expiresInMinutes,
  });

  final bool success;
  final String message;
  final int expiresInMinutes;

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      success:          json['success'] as bool? ?? true,
      message:          json['message'] as String? ?? '',
      expiresInMinutes: json['expires_in_minutes'] as int? ?? 10,
    );
  }
}

class VerifyOtpRequest {
  const VerifyOtpRequest({
    required this.mobile,
    required this.otp,
  });

  final String mobile;
  final String otp;

  Map<String, dynamic> toJson() => {
        'mobile': mobile,
        'otp':    otp,
      };
}

class VerifyOtpResponse {
  const VerifyOtpResponse({
    required this.success,
    required this.verifiedToken,
    required this.message,
  });

  final bool success;
  final String verifiedToken;
  final String message;

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success:        json['success'] as bool? ?? true,
      verifiedToken:  json['verified_token'] as String? ?? '',
      message:        json['message'] as String? ?? '',
    );
  }
}

// ─────────────────────────────────────────────
// Registration
// ─────────────────────────────────────────────

class RegisterRequest {
  const RegisterRequest({
    required this.mobile,
    required this.verifiedToken,
    required this.fullName,
    required this.password,
    required this.gender,
    required this.dateOfBirth,
    required this.language,
    required this.religion,
    required this.wardId,
    required this.areaId,
    this.education,
    this.occupation,
    this.annualIncomeRange,
    this.familyAdults,
    this.familyKids,
  });

  final String mobile;
  final String verifiedToken;
  final String fullName;
  final String password;
  final String gender;
  final String dateOfBirth;
  final String language;
  final String religion;
  final String wardId;
  final String areaId;
  final String? education;
  final String? occupation;
  final String? annualIncomeRange;
  final int? familyAdults;
  final int? familyKids;

  Map<String, dynamic> toJson() => {
        'mobile':              mobile,
        'verified_token':      verifiedToken,
        'full_name':           fullName,
        'password':            password,
        'gender':              gender,
        'date_of_birth':       dateOfBirth,
        'language':            language,
        'religion':            religion,
        'ward_id':             wardId,
        'area_id':             areaId,
        if (education != null)          'education':            education,
        if (occupation != null)         'occupation':           occupation,
        if (annualIncomeRange != null)  'annual_income_range':  annualIncomeRange,
        if (familyAdults != null)       'family_adults':        familyAdults,
        if (familyKids != null)         'family_kids':          familyKids,
      };
}

// ─────────────────────────────────────────────
// Login
// ─────────────────────────────────────────────

class LoginRequest {
  const LoginRequest({
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

class LoginResponse {
  const LoginResponse({
    required this.success,
    required this.userId,
    required this.role,
    required this.fullName,
    required this.accessToken,
    required this.refreshToken,
    required this.message,
  });

  final bool success;
  final String userId;
  final String role;
  final String fullName;
  final String accessToken;
  final String refreshToken;
  final String message;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success:       json['success']       as bool?   ?? true,
      userId:        json['user_id']        as String? ?? '',
      role:          json['role']           as String? ?? '',
      fullName:      json['full_name']      as String? ?? '',
      accessToken:   json['access_token']   as String? ?? '',
      refreshToken:  json['refresh_token']  as String? ?? '',
      message:       json['message']        as String? ?? '',
    );
  }
}

// ─────────────────────────────────────────────
// Area / Ward (used during registration)
// ─────────────────────────────────────────────

class AreaModel {
  const AreaModel({
    required this.id,
    required this.areaName,
    required this.areaCode,
  });

  final String id;
  final String areaName;
  final String areaCode;

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id:       json['id']        as String? ?? '',
      areaName: json['area_name'] as String? ?? '',
      areaCode: json['area_code'] as String? ?? '',
    );
  }
}

class WardModel {
  const WardModel({
    required this.id,
    required this.wardName,
    required this.wardCode,
    required this.areaId,
  });

  final String id;
  final String wardName;
  final String wardCode;
  final String areaId;

  factory WardModel.fromJson(Map<String, dynamic> json) {
    return WardModel(
      id:       json['id']        as String? ?? '',
      wardName: json['ward_name'] as String? ?? '',
      wardCode: json['ward_code'] as String? ?? '',
      areaId:   json['area_id']   as String? ?? '',
    );
  }
}