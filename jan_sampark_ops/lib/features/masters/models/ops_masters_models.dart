import '../../../core/utils/ops_date_formatter.dart';

// ─────────────────────────────────────────────
// Area
// ─────────────────────────────────────────────

class OpsArea {
  const OpsArea({
    required this.id,
    required this.areaName,
    required this.areaCode,
    required this.isActive,
    required this.createdAt,
    this.wardsCount      = 0,
    this.votersCount     = 0,
    this.leadersCount    = 0,
    this.corporatorName,
    this.description,
  });

  final String   id;
  final String   areaName;
  final String   areaCode;
  final bool     isActive;
  final DateTime createdAt;
  final int      wardsCount;
  final int      votersCount;
  final int      leadersCount;
  final String?  corporatorName;
  final String?  description;

  OpsArea copyWith({bool? isActive}) => OpsArea(
        id:             id,
        areaName:       areaName,
        areaCode:       areaCode,
        isActive:       isActive ?? this.isActive,
        createdAt:      createdAt,
        wardsCount:     wardsCount,
        votersCount:    votersCount,
        leadersCount:   leadersCount,
        corporatorName: corporatorName,
        description:    description,
      );

  factory OpsArea.fromJson(Map<String, dynamic> json) {
    return OpsArea(
      id:          json['id']          as String? ?? '',
      areaName:    json['area_name']   as String? ?? '',
      areaCode:    json['area_code']   as String? ?? '',
      isActive:    json['is_active']   as bool?   ?? true,
      wardsCount:  json['wards_count'] as int?    ?? 0,
      votersCount: json['voters_count'] as int?   ?? 0,
      leadersCount: json['leaders_count'] as int? ?? 0,
      corporatorName: json['corporator_name'] as String?,
      description: json['description']       as String?,
      createdAt: OpsDateFormatter.fromApiString(
              json['created_at'] as String?) ??
          DateTime.now(),
    );
  }
}

class OpsAreaListResponse {
  const OpsAreaListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final List<OpsArea> data;
  final int total;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory OpsAreaListResponse.fromJson(Map<String, dynamic> json) {
    return OpsAreaListResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => OpsArea.fromJson(e as Map<String, dynamic>))
          .toList(),
      total:      json['total']       as int? ?? 0,
      page:       json['page']        as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

// ─────────────────────────────────────────────
// Ward
// ─────────────────────────────────────────────

class OpsWard {
  const OpsWard({
    required this.id,
    required this.wardName,
    required this.wardCode,
    required this.areaId,
    required this.areaName,
    required this.isActive,
    required this.createdAt,
    this.votersCount  = 0,
    this.leadersCount = 0,
    this.description,
  });

  final String   id;
  final String   wardName;
  final String   wardCode;
  final String   areaId;
  final String   areaName;
  final bool     isActive;
  final DateTime createdAt;
  final int      votersCount;
  final int      leadersCount;
  final String?  description;

  OpsWard copyWith({bool? isActive}) => OpsWard(
        id:           id,
        wardName:     wardName,
        wardCode:     wardCode,
        areaId:       areaId,
        areaName:     areaName,
        isActive:     isActive ?? this.isActive,
        createdAt:    createdAt,
        votersCount:  votersCount,
        leadersCount: leadersCount,
        description:  description,
      );

  factory OpsWard.fromJson(Map<String, dynamic> json) {
    return OpsWard(
      id:           json['id']           as String? ?? '',
      wardName:     json['ward_name']    as String? ?? '',
      wardCode:     json['ward_code']    as String? ?? '',
      areaId:       json['area_id']      as String? ?? '',
      areaName:     json['area_name']    as String? ?? '—',
      isActive:     json['is_active']    as bool?   ?? true,
      votersCount:  json['voters_count'] as int?    ?? 0,
      leadersCount: json['leaders_count'] as int?   ?? 0,
      description:  json['description'] as String?,
      createdAt: OpsDateFormatter.fromApiString(
              json['created_at'] as String?) ??
          DateTime.now(),
    );
  }
}

class OpsWardListResponse {
  const OpsWardListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final List<OpsWard> data;
  final int total;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory OpsWardListResponse.fromJson(Map<String, dynamic> json) {
    return OpsWardListResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => OpsWard.fromJson(e as Map<String, dynamic>))
          .toList(),
      total:      json['total']       as int? ?? 0,
      page:       json['page']        as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

// ─────────────────────────────────────────────
// Complaint Category
// ─────────────────────────────────────────────

class OpsCategory {
  const OpsCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    this.complaintsCount = 0,
    this.iconName,
    this.sortOrder       = 0,
  });

  final String   id;
  final String   name;
  final String   description;
  final bool     isActive;
  final DateTime createdAt;
  final int      complaintsCount;
  final String?  iconName;
  final int      sortOrder;

  OpsCategory copyWith({bool? isActive}) => OpsCategory(
        id:              id,
        name:            name,
        description:     description,
        isActive:        isActive ?? this.isActive,
        createdAt:       createdAt,
        complaintsCount: complaintsCount,
        iconName:        iconName,
        sortOrder:       sortOrder,
      );

  factory OpsCategory.fromJson(Map<String, dynamic> json) {
    return OpsCategory(
      id:              json['id']               as String? ?? '',
      name:            json['name']             as String? ?? '',
      description:     json['description']      as String? ?? '',
      isActive:        json['is_active']        as bool?   ?? true,
      complaintsCount: json['complaints_count'] as int?    ?? 0,
      iconName:        json['icon_name']        as String?,
      sortOrder:       json['sort_order']       as int?    ?? 0,
      createdAt: OpsDateFormatter.fromApiString(
              json['created_at'] as String?) ??
          DateTime.now(),
    );
  }
}

class OpsCategoryListResponse {
  const OpsCategoryListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final List<OpsCategory> data;
  final int total;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory OpsCategoryListResponse.fromJson(
      Map<String, dynamic> json) {
    return OpsCategoryListResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) =>
              OpsCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      total:      json['total']       as int? ?? 0,
      page:       json['page']        as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

// ─────────────────────────────────────────────
// Helpline
// ─────────────────────────────────────────────

class OpsHelpline {
  const OpsHelpline({
    required this.id,
    required this.name,
    required this.number,
    required this.category,
    required this.isSystem,
    required this.isActive,
    required this.createdAt,
    this.description,
    this.areaId,
    this.areaName,
  });

  final String   id;
  final String   name;
  final String   number;
  final String   category;
  final bool     isSystem;
  final bool     isActive;
  final DateTime createdAt;
  final String?  description;
  final String?  areaId;
  final String?  areaName;

  OpsHelpline copyWith({bool? isActive}) => OpsHelpline(
        id:          id,
        name:        name,
        number:      number,
        category:    category,
        isSystem:    isSystem,
        isActive:    isActive ?? this.isActive,
        createdAt:   createdAt,
        description: description,
        areaId:      areaId,
        areaName:    areaName,
      );

  factory OpsHelpline.fromJson(Map<String, dynamic> json) {
    return OpsHelpline(
      id:          json['id']          as String? ?? '',
      name:        json['name']        as String? ?? '',
      number:      json['number']      as String? ?? '',
      category:    json['category']    as String? ?? 'other',
      isSystem:    json['is_system']   as bool?   ?? false,
      isActive:    json['is_active']   as bool?   ?? true,
      description: json['description'] as String?,
      areaId:      json['area_id']     as String?,
      areaName:    json['area_name']   as String?,
      createdAt: OpsDateFormatter.fromApiString(
              json['created_at'] as String?) ??
          DateTime.now(),
    );
  }
}

class OpsHelplineListResponse {
  const OpsHelplineListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final List<OpsHelpline> data;
  final int total;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory OpsHelplineListResponse.fromJson(
      Map<String, dynamic> json) {
    return OpsHelplineListResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) =>
              OpsHelpline.fromJson(e as Map<String, dynamic>))
          .toList(),
      total:      json['total']       as int? ?? 0,
      page:       json['page']        as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

// ─────────────────────────────────────────────
// Helpline category labels
// ─────────────────────────────────────────────

const kHelplineCategories = {
  'police':      'Police',
  'fire':        'Fire',
  'medical':     'Medical / Ambulance',
  'electricity': 'Electricity',
  'water':       'Water Supply',
  'women':       'Women Helpline',
  'child':       'Child Helpline',
  'municipal':   'Municipal Services',
  'transport':   'Transport',
  'disaster':    'Disaster Management',
  'other':       'Other',
};