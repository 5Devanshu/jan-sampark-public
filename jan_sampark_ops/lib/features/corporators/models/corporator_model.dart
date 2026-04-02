class OpsAreaOption {
  const OpsAreaOption({
    required this.id,
    required this.areaName,
    required this.areaCode,
  });

  final String id;
  final String areaName;
  final String areaCode;

  factory OpsAreaOption.fromJson(Map<String, dynamic> json) {
    return OpsAreaOption(
      id:       json['id']        as String? ?? '',
      areaName: json['area_name'] as String? ?? '',
      areaCode: json['area_code'] as String? ?? '',
    );
  }
}

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

  factory OpsWardOption.fromJson(Map<String, dynamic> json) {
    return OpsWardOption(
      id:       json['id']        as String? ?? '',
      wardName: json['ward_name'] as String? ?? '',
      wardCode: json['ward_code'] as String? ?? '',
      areaId:   json['area_id']   as String? ?? '',
    );
  }
}

class CorporatorListItem {
  const CorporatorListItem({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.isActive,
    required this.areaName,
    required this.wardsCount,
    required this.createdAt,
  });

  final String   id;
  final String   fullName;
  final String   mobile;
  final bool     isActive;
  final String   areaName;
  final int      wardsCount;
  final DateTime createdAt;

  factory CorporatorListItem.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>? ?? {};
    return CorporatorListItem(
      id:          json['id']           as String? ?? '',
      fullName:    json['full_name']     as String? ?? '',
      mobile:      json['mobile']        as String? ?? '',
      isActive:    json['is_active']     as bool?   ?? true,
      areaName:    loc['area_name']      as String? ?? '',
      wardsCount:  json['wards_count']   as int?    ?? 0,
      createdAt: DateTime.tryParse(
              json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class CorporatorListResponse {
  const CorporatorListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final List<CorporatorListItem> data;
  final int total;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory CorporatorListResponse.fromJson(
      Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => CorporatorListItem.fromJson(
            e as Map<String, dynamic>))
        .toList();
    return CorporatorListResponse(
      data:       list,
      total:      json['total']       as int? ?? 0,
      page:       json['page']        as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

class CorporatorDetail {
  const CorporatorDetail({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.isActive,
    required this.areaId,
    required this.areaName,
    required this.createdAt,
    this.assignedWards = const [],
    this.performanceSummary,
  });

  final String   id;
  final String   fullName;
  final String   mobile;
  final bool     isActive;
  final String   areaId;
  final String   areaName;
  final DateTime createdAt;
  final List<String>  assignedWards;
  final Map<String, dynamic>? performanceSummary;

  factory CorporatorDetail.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>? ?? {};
    final cp  = json['corporator_profile'] as Map<String, dynamic>? ?? {};
    final wards = (cp['assigned_ward_ids'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return CorporatorDetail(
      id:         json['id']        as String? ?? '',
      fullName:   json['full_name'] as String? ?? '',
      mobile:     json['mobile']    as String? ?? '',
      isActive:   json['is_active'] as bool?   ?? true,
      areaId:     loc['area_id']    as String? ?? '',
      areaName:   loc['area_name']  as String? ?? '',
      assignedWards: wards,
      performanceSummary: json['performance'] as Map<String, dynamic>?,
      createdAt: DateTime.tryParse(
              json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}