import '../../../../core/utils/date_formatter.dart';

// ─────────────────────────────────────────────
// Leader List Item
// ─────────────────────────────────────────────

class CorporatorLeaderItem {
  const CorporatorLeaderItem({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.isActive,
    required this.wardName,
    required this.wardId,
    required this.createdAt,
    this.responsibilities = const [],
    this.complaintsAcknowledged = 0,
    this.complaintsEscalated    = 0,
    this.groundVerifications    = 0,
  });

  final String      id;
  final String      fullName;
  final String      mobile;
  final bool        isActive;
  final String      wardName;
  final String      wardId;
  final DateTime    createdAt;
  final List<String> responsibilities;
  final int         complaintsAcknowledged;
  final int         complaintsEscalated;
  final int         groundVerifications;

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  factory CorporatorLeaderItem.fromJson(
      Map<String, dynamic> json) {
    final loc  = json['location']      as Map<String, dynamic>? ?? {};
    final lp   = json['leader_profile'] as Map<String, dynamic>? ?? {};
    final perf = lp['performance']     as Map<String, dynamic>? ?? {};
    final resp = (lp['leader_responsibilities']
                  as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return CorporatorLeaderItem(
      id:       json['id']        as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      mobile:   json['mobile']    as String? ?? '',
      isActive: json['is_active'] as bool?   ?? true,
      wardName: loc['ward_name']  as String? ?? '',
      wardId:   loc['ward_id']    as String? ?? '',
      responsibilities:          resp,
      complaintsAcknowledged:
          perf['complaints_acknowledged']       as int? ?? 0,
      complaintsEscalated:
          perf['complaints_escalated']          as int? ?? 0,
      groundVerifications:
          perf['ground_verifications_completed'] as int? ?? 0,
      createdAt: DateFormatter.fromApiString(
              json['created_at'] as String?) ??
          DateTime.now(),
    );
  }
}

class LeaderListResponse {
  const LeaderListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final List<CorporatorLeaderItem> data;
  final int total;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory LeaderListResponse.fromJson(
      Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => CorporatorLeaderItem.fromJson(
            e as Map<String, dynamic>))
        .toList();
    return LeaderListResponse(
      data:       list,
      total:      json['total']       as int? ?? 0,
      page:       json['page']        as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

// ─────────────────────────────────────────────
// Leader Detail
// ─────────────────────────────────────────────

class CorporatorLeaderDetail {
  const CorporatorLeaderDetail({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.isActive,
    required this.wardId,
    required this.wardName,
    required this.createdAt,
    this.responsibilities       = const [],
    this.complaintsAssigned     = 0,
    this.complaintsAcknowledged = 0,
    this.complaintsEscalated    = 0,
    this.groundVerifications    = 0,
    this.voterInteractions      = 0,
    this.createdByCorporatorId,
  });

  final String      id;
  final String      fullName;
  final String      mobile;
  final bool        isActive;
  final String      wardId;
  final String      wardName;
  final DateTime    createdAt;
  final List<String> responsibilities;
  final int         complaintsAssigned;
  final int         complaintsAcknowledged;
  final int         complaintsEscalated;
  final int         groundVerifications;
  final int         voterInteractions;
  final String?     createdByCorporatorId;

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  double get resolutionRate {
    if (complaintsAssigned == 0) return 0.0;
    return complaintsAcknowledged / complaintsAssigned * 100;
  }

  factory CorporatorLeaderDetail.fromJson(
      Map<String, dynamic> json) {
    final loc  = json['location']       as Map<String, dynamic>? ?? {};
    final lp   = json['leader_profile'] as Map<String, dynamic>? ?? {};
    final perf = lp['performance']      as Map<String, dynamic>? ?? {};
    final resp = (lp['leader_responsibilities']
                  as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return CorporatorLeaderDetail(
      id:       json['id']        as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      mobile:   json['mobile']    as String? ?? '',
      isActive: json['is_active'] as bool?   ?? true,
      wardId:   loc['ward_id']    as String? ?? '',
      wardName: loc['ward_name']  as String? ?? '',
      responsibilities: resp,
      complaintsAssigned:
          perf['complaints_assigned']           as int? ?? 0,
      complaintsAcknowledged:
          perf['complaints_acknowledged']       as int? ?? 0,
      complaintsEscalated:
          perf['complaints_escalated']          as int? ?? 0,
      groundVerifications:
          perf['ground_verifications_completed'] as int? ?? 0,
      voterInteractions:
          perf['voter_interactions']            as int? ?? 0,
      createdByCorporatorId:
          lp['created_by_corporator_id']        as String?,
      createdAt: DateFormatter.fromApiString(
              json['created_at'] as String?) ??
          DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────
// Create Leader Request
// ─────────────────────────────────────────────

class CreateLeaderRequest {
  const CreateLeaderRequest({
    required this.fullName,
    required this.mobile,
    required this.password,
    required this.wardId,
    required this.responsibilities,
  });

  final String      fullName;
  final String      mobile;
  final String      password;
  final String      wardId;
  final List<String> responsibilities;

  Map<String, dynamic> toJson() => {
        'full_name':                  fullName,
        'mobile':                     mobile,
        'password':                   password,
        'ward_id':                    wardId,
        'leader_responsibilities':    responsibilities,
      };
}

// ─────────────────────────────────────────────
// Available responsibilities
// ─────────────────────────────────────────────

const kLeaderResponsibilities = {
  'acknowledge_complaints':
      'Acknowledge Complaints',
  'escalate_complaints':
      'Escalate Complaints',
  'add_complaint_notes':
      'Add Complaint Notes',
  'ground_verification':
      'Ground Verification',
  'create_events':
      'Create Events',
  'create_announcements':
      'Create Announcements',
  'create_chats':
      'Create Community Chats',
};