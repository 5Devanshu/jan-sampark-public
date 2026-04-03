import '../../../core/utils/ops_date_formatter.dart';

// ─────────────────────────────────────────────
// Area option (dropdown)
// ─────────────────────────────────────────────

class OpsAreaOption {
  const OpsAreaOption({
    required this.id,
    required this.areaName,
    required this.areaCode,
  });

  final String id;
  final String areaName;
  final String areaCode;

  String get displayName => '$areaName ($areaCode)';

  factory OpsAreaOption.fromJson(Map<String, dynamic> json) {
    return OpsAreaOption(
      id:       json['id']        as String? ?? '',
      areaName: json['area_name'] as String? ?? '',
      areaCode: json['area_code'] as String? ?? '',
    );
  }
}

// ─────────────────────────────────────────────
// Ward option (multi-select)
// ─────────────────────────────────────────────

class OpsWardOption {
  const OpsWardOption({
    required this.id,
    required this.wardName,
    required this.wardCode,
    required this.areaId,
  });

  final String id;
  final String wardName;
  final String wardCode;
  final String areaId;

  String get displayName => '$wardName ($wardCode)';

  factory OpsWardOption.fromJson(Map<String, dynamic> json) {
    return OpsWardOption(
      id:       json['id']        as String? ?? '',
      wardName: json['ward_name'] as String? ?? '',
      wardCode: json['ward_code'] as String? ?? '',
      areaId:   json['area_id']   as String? ?? '',
    );
  }
}

// ─────────────────────────────────────────────
// Corporator list item
// ─────────────────────────────────────────────

class OpsCorporatorItem {
  const OpsCorporatorItem({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.isActive,
    required this.areaId,
    required this.areaName,
    required this.areaCode,
    required this.wardsCount,
    required this.createdAt,
    this.leadersCount      = 0,
    this.complaintsTotal   = 0,
    this.complaintsResolved = 0,
    this.resolutionRate    = 0.0,
  });

  final String   id;
  final String   fullName;
  final String   mobile;
  final bool     isActive;
  final String   areaId;
  final String   areaName;
  final String   areaCode;
  final int      wardsCount;
  final DateTime createdAt;
  final int      leadersCount;
  final int      complaintsTotal;
  final int      complaintsResolved;
  final double   resolutionRate;

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'C';
  }

  factory OpsCorporatorItem.fromJson(Map<String, dynamic> json) {
    final loc  = json['location']    as Map<String, dynamic>? ?? {};
    final perf = json['performance'] as Map<String, dynamic>? ?? {};
    final comp = perf['complaints']  as Map<String, dynamic>? ?? {};

    return OpsCorporatorItem(
      id:                json['id']          as String? ?? '',
      fullName:          json['full_name']   as String? ?? '',
      mobile:            json['mobile']      as String? ?? '',
      isActive:          json['is_active']   as bool?   ?? true,
      areaId:            loc['area_id']      as String? ?? '',
      areaName:          loc['area_name']    as String? ?? '—',
      areaCode:          loc['area_code']    as String? ?? '',
      wardsCount:        json['wards_count'] as int?    ?? 0,
      leadersCount:      json['leaders_count'] as int?  ?? 0,
      complaintsTotal:   comp['total']       as int?    ?? 0,
      complaintsResolved: comp['resolved']   as int?    ?? 0,
      resolutionRate: _d(comp['resolution_rate']),
      createdAt: OpsDateFormatter.fromApiString(
              json['created_at'] as String?) ??
          DateTime.now(),
    );
  }

  static double _d(dynamic v) {
    if (v is double) return v;
    if (v is int)    return v.toDouble();
    return 0.0;
  }
}

class OpsCorporatorListResponse {
  const OpsCorporatorListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final List<OpsCorporatorItem> data;
  final int total;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory OpsCorporatorListResponse.fromJson(
      Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => OpsCorporatorItem.fromJson(
            e as Map<String, dynamic>))
        .toList();
    return OpsCorporatorListResponse(
      data:       list,
      total:      json['total']       as int? ?? 0,
      page:       json['page']        as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

// ─────────────────────────────────────────────
// Corporator detail
// ─────────────────────────────────────────────

class OpsCorporatorDetail {
  const OpsCorporatorDetail({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.isActive,
    required this.areaId,
    required this.areaName,
    required this.areaCode,
    required this.createdAt,
    this.assignedWardIds       = const [],
    this.assignedWardNames     = const [],
    this.leadersCount          = 0,
    this.complaintsTotal       = 0,
    this.complaintsResolved    = 0,
    this.complaintsEscalated   = 0,
    this.resolutionRate        = 0.0,
    this.totalCampaigns        = 0,
    this.totalRaised           = 0.0,
    this.totalEvents           = 0,
    this.totalAnnouncements    = 0,
    this.totalPolls            = 0,
    this.createdByCorporatorId,
  });

  final String   id;
  final String   fullName;
  final String   mobile;
  final bool     isActive;
  final String   areaId;
  final String   areaName;
  final String   areaCode;
  final DateTime createdAt;
  final List<String> assignedWardIds;
  final List<String> assignedWardNames;
  final int      leadersCount;
  final int      complaintsTotal;
  final int      complaintsResolved;
  final int      complaintsEscalated;
  final double   resolutionRate;
  final int      totalCampaigns;
  final double   totalRaised;
  final int      totalEvents;
  final int      totalAnnouncements;
  final int      totalPolls;
  final String?  createdByCorporatorId;

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'C';
  }

  factory OpsCorporatorDetail.fromJson(
      Map<String, dynamic> json) {
    final loc  = json['location']          as Map<String, dynamic>? ?? {};
    final cp   = json['corporator_profile'] as Map<String, dynamic>? ?? {};
    final perf = cp['performance']         as Map<String, dynamic>? ?? {};
    final comp = perf['complaints']        as Map<String, dynamic>? ?? {};

    final wardIds = (cp['assigned_ward_ids'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final wardNames =
        (cp['assigned_ward_names'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();

    return OpsCorporatorDetail(
      id:                  json['id']          as String? ?? '',
      fullName:            json['full_name']   as String? ?? '',
      mobile:              json['mobile']      as String? ?? '',
      isActive:            json['is_active']   as bool?   ?? true,
      areaId:              loc['area_id']      as String? ?? '',
      areaName:            loc['area_name']    as String? ?? '—',
      areaCode:            loc['area_code']    as String? ?? '',
      assignedWardIds:     wardIds,
      assignedWardNames:   wardNames,
      leadersCount:        json['leaders_count'] as int?  ?? 0,
      complaintsTotal:     comp['total']       as int?    ?? 0,
      complaintsResolved:  comp['resolved']    as int?    ?? 0,
      complaintsEscalated: comp['escalated']   as int?    ?? 0,
      resolutionRate:
          OpsCorporatorItem._d(comp['resolution_rate']),
      totalCampaigns:     perf['campaigns']    as int?    ?? 0,
      totalRaised:
          OpsCorporatorItem._d(perf['total_raised']),
      totalEvents:        perf['events']       as int?    ?? 0,
      totalAnnouncements: perf['announcements'] as int?   ?? 0,
      totalPolls:         perf['polls']        as int?    ?? 0,
      createdByCorporatorId:
          cp['created_by_ops_id'] as String?,
      createdAt: OpsDateFormatter.fromApiString(
              json['created_at'] as String?) ??
          DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────
// Create request
// ─────────────────────────────────────────────

class OpsCreateCorporatorRequest {
  const OpsCreateCorporatorRequest({
    required this.fullName,
    required this.mobile,
    required this.password,
    required this.areaId,
    required this.assignedWardIds,
  });

  final String      fullName;
  final String      mobile;
  final String      password;
  final String      areaId;
  final List<String> assignedWardIds;

  Map<String, dynamic> toJson() => {
        'full_name':          fullName,
        'mobile':             mobile,
        'password':           password,
        'area_id':            areaId,
        'assigned_ward_ids':  assignedWardIds,
      };
}