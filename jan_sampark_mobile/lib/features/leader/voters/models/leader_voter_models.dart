import '../../../../core/utils/date_formatter.dart';

class VoterListItem {
  const VoterListItem({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.wardName,
    required this.areaName,
    required this.isActive,
    required this.epicVerified,
    required this.complaintsCount,
    required this.createdAt,
    this.gender,
    this.language,
  });

  final String id;
  final String fullName;
  final String mobile;
  final String wardName;
  final String areaName;
  final bool isActive;
  final bool epicVerified;
  final int complaintsCount;
  final DateTime createdAt;
  final String? gender;
  final String? language;

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  factory VoterListItem.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>? ?? {};
    return VoterListItem(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      wardName: loc['ward_name'] as String? ?? '',
      areaName: loc['area_name'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      epicVerified: json['epic_verified'] as bool? ?? false,
      complaintsCount: json['complaints_count'] as int? ?? 0,
      gender: json['gender'] as String?,
      language: json['language'] as String?,
      createdAt:
          DateFormatter.fromApiString(json['created_at'] as String?) ??
          DateTime.now(),
    );
  }
}

class VoterListResponse {
  const VoterListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final List<VoterListItem> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory VoterListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => VoterListItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return VoterListResponse(
      data: list,
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

// ─────────────────────────────────────────────
// Full Voter Profile (detail view)
// ─────────────────────────────────────────────

class VoterProfile {
  const VoterProfile({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.isActive,
    required this.epicVerified,
    required this.complaintsCount,
    required this.createdAt,
    this.gender,
    this.dateOfBirth,
    this.language,
    this.religion,
    this.education,
    this.occupation,
    this.annualIncomeRange,
    this.familyAdults,
    this.familyKids,
    this.wardName,
    this.areaName,
    this.epicNumber,
    this.idDocumentType,
  });

  final String id;
  final String fullName;
  final String mobile;
  final bool isActive;
  final bool epicVerified;
  final int complaintsCount;
  final DateTime createdAt;
  final String? gender;
  final String? dateOfBirth;
  final String? language;
  final String? religion;
  final String? education;
  final String? occupation;
  final String? annualIncomeRange;
  final int? familyAdults;
  final int? familyKids;
  final String? wardName;
  final String? areaName;
  final String? epicNumber;
  final String? idDocumentType;

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  factory VoterProfile.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>? ?? {};
    final demo = json['demographics'] as Map<String, dynamic>? ?? {};
    final idDoc = json['id_document'] as Map<String, dynamic>? ?? {};
    final metrics = json['metrics'] as Map<String, dynamic>? ?? {};

    return VoterProfile(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      epicVerified: json['epic_verified'] as bool? ?? false,
      complaintsCount:
          metrics['complaints_count'] ?? json['complaints_count'] as int? ?? 0,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      language: json['language'] as String?,
      wardName: loc['ward_name'] as String?,
      areaName: loc['area_name'] as String?,
      religion: demo['religion'] as String?,
      education: demo['education'] as String?,
      occupation: demo['occupation'] as String?,
      annualIncomeRange: demo['annual_income_range'] as String?,
      familyAdults: demo['family_adults'] as int?,
      familyKids: demo['family_kids'] as int?,
      epicNumber: idDoc['epic_number'] as String?,
      idDocumentType: idDoc['document_type'] as String?,
      createdAt:
          DateFormatter.fromApiString(json['created_at'] as String?) ??
          DateTime.now(),
    );
  }
}
