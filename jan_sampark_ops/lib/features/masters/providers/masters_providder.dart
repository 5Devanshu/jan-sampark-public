import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/ops_dio_client.dart';
import '../../../core/constants/ops_constants.dart';

// ─────────────────────────────────────────────
// Area Models
// ─────────────────────────────────────────────

class AreaRecord {
  const AreaRecord({
    required this.id,
    required this.areaName,
    required this.areaCode,
    required this.wardsCount,
    required this.isActive,
  });

  final String id;
  final String areaName;
  final String areaCode;
  final int    wardsCount;
  final bool   isActive;

  factory AreaRecord.fromJson(Map<String, dynamic> json) {
    return AreaRecord(
      id:         json['id']          as String? ?? '',
      areaName:   json['area_name']   as String? ?? '',
      areaCode:   json['area_code']   as String? ?? '',
      wardsCount: json['wards_count'] as int?    ?? 0,
      isActive:   json['is_active']   as bool?   ?? true,
    );
  }
}

// ─────────────────────────────────────────────
// Ward Models
// ─────────────────────────────────────────────

class WardRecord {
  const WardRecord({
    required this.id,
    required this.wardName,
    required this.wardCode,
    required this.areaId,
    required this.areaName,
    required this.isActive,
  });

  final String id;
  final String wardName;
  final String wardCode;
  final String areaId;
  final String areaName;
  final bool   isActive;

  factory WardRecord.fromJson(Map<String, dynamic> json) {
    return WardRecord(
      id:       json['id']        as String? ?? '',
      wardName: json['ward_name'] as String? ?? '',
      wardCode: json['ward_code'] as String? ?? '',
      areaId:   json['area_id']   as String? ?? '',
      areaName: json['area_name'] as String? ?? '',
      isActive: json['is_active'] as bool?   ?? true,
    );
  }
}

// ─────────────────────────────────────────────
// Category Models
// ─────────────────────────────────────────────

class CategoryRecord {
  const CategoryRecord({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.complaintsCount,
  });

  final String id;
  final String name;
  final String description;
  final bool   isActive;
  final int    complaintsCount;

  factory CategoryRecord.fromJson(Map<String, dynamic> json) {
    return CategoryRecord(
      id:              json['id']               as String? ?? '',
      name:            json['name']             as String? ?? '',
      description:     json['description']      as String? ?? '',
      isActive:        json['is_active']        as bool?   ?? true,
      complaintsCount: json['complaints_count'] as int?    ?? 0,
    );
  }
}

// ─────────────────────────────────────────────
// Helpline Models
// ─────────────────────────────────────────────

class HelplineRecord {
  const HelplineRecord({
    required this.id,
    required this.name,
    required this.number,
    required this.category,
    required this.isSystem,
    required this.isActive,
    this.description,
  });

  final String  id;
  final String  name;
  final String  number;
  final String  category;
  final bool    isSystem;
  final bool    isActive;
  final String? description;

  factory HelplineRecord.fromJson(Map<String, dynamic> json) {
    return HelplineRecord(
      id:          json['id']          as String? ?? '',
      name:        json['name']        as String? ?? '',
      number:      json['number']      as String? ?? '',
      category:    json['category']    as String? ?? '',
      isSystem:    json['is_system']   as bool?   ?? false,
      isActive:    json['is_active']   as bool?   ?? true,
      description: json['description'] as String?,
    );
  }
}

// ─────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────

final areasListProvider =
    FutureProvider.autoDispose<List<AreaRecord>>((ref) async {
  final dio = ref.watch(opsDioProvider);
  final res = await dio.get(OpsConstants.endpointAreas,
      queryParameters: {'page_size': 100});
  final data = res.data as Map<String, dynamic>;
  return (data['data'] as List<dynamic>? ?? [])
      .map((e) => AreaRecord.fromJson(e as Map<String, dynamic>))
      .toList();
});

final wardsListProvider =
    FutureProvider.autoDispose<List<WardRecord>>((ref) async {
  final dio = ref.watch(opsDioProvider);
  final res = await dio.get(OpsConstants.endpointWards,
      queryParameters: {'page_size': 200});
  final data = res.data as Map<String, dynamic>;
  return (data['data'] as List<dynamic>? ?? [])
      .map((e) => WardRecord.fromJson(e as Map<String, dynamic>))
      .toList();
});

final categoriesListProvider =
    FutureProvider.autoDispose<List<CategoryRecord>>((ref) async {
  final dio = ref.watch(opsDioProvider);
  final res = await dio.get(OpsConstants.endpointCategories,
      queryParameters: {'page_size': 100});
  final data = res.data as Map<String, dynamic>;
  return (data['data'] as List<dynamic>? ?? [])
      .map((e) =>
          CategoryRecord.fromJson(e as Map<String, dynamic>))
      .toList();
});

final helplineListProvider =
    FutureProvider.autoDispose<List<HelplineRecord>>((ref) async {
  final dio = ref.watch(opsDioProvider);
  final res = await dio.get(OpsConstants.endpointHelpline,
      queryParameters: {'page_size': 100});
  final data = res.data as Map<String, dynamic>;
  return (data['data'] as List<dynamic>? ?? [])
      .map((e) =>
          HelplineRecord.fromJson(e as Map<String, dynamic>))
      .toList();
});