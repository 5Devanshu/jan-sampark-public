import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ops_constants.dart';
import '../../../core/network/ops_api_response.dart';
import '../../../core/network/ops_dio_client.dart';
import '../models/ops_masters_models.dart';

class OpsMastersRepository extends OpsBaseRepository {
  const OpsMastersRepository(super.dio);

  // ═════════════════════════════════════════════
  // AREAS
  // ═════════════════════════════════════════════

  Future<OpsApiResponse<OpsAreaListResponse>> fetchAreas({
    int     page     = 1,
    int     pageSize = OpsConstants.defaultPageSize,
    String? search,
    bool?   isActive,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        OpsConstants.endpointAreas,
        queryParameters: {
          'page':      page,
          'page_size': pageSize,
          if (search   != null && search.isNotEmpty)
            'search':    search,
          if (isActive != null) 'is_active': isActive,
        },
      );
      return OpsAreaListResponse.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  Future<OpsApiResponse<OpsArea>> createArea({
    required String areaName,
    required String areaCode,
    String? description,
  }) async {
    return safeCall(() async {
      final res = await dio.post(
        OpsConstants.endpointAreas,
        data: {
          'area_name':    areaName.trim(),
          'area_code':    areaCode.trim().toUpperCase(),
          if (description != null &&
              description.isNotEmpty)
            'description': description.trim(),
        },
      );
      return OpsArea.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  Future<OpsApiResponse<OpsArea>> updateArea(
    String areaId, {
    String? areaName,
    String? areaCode,
    String? description,
    bool?   isActive,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${OpsConstants.endpointAreas}/$areaId',
        data: {
          if (areaName    != null) 'area_name':   areaName.trim(),
          if (areaCode    != null)
            'area_code': areaCode.trim().toUpperCase(),
          if (description != null)
            'description': description.trim(),
          if (isActive    != null) 'is_active':   isActive,
        },
      );
      return OpsArea.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  Future<OpsApiResponse<Map<String, dynamic>>> deleteArea(
      String areaId) async {
    return safeCall(() async {
      final res = await dio.delete(
          '${OpsConstants.endpointAreas}/$areaId');
      return res.data as Map<String, dynamic>;
    });
  }

  // ═════════════════════════════════════════════
  // WARDS
  // ═════════════════════════════════════════════

  Future<OpsApiResponse<OpsWardListResponse>> fetchWards({
    int     page     = 1,
    int     pageSize = OpsConstants.defaultPageSize,
    String? search,
    String? areaId,
    bool?   isActive,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        OpsConstants.endpointWards,
        queryParameters: {
          'page':      page,
          'page_size': pageSize,
          if (search   != null && search.isNotEmpty)
            'search':    search,
          if (areaId   != null) 'area_id':   areaId,
          if (isActive != null) 'is_active': isActive,
        },
      );
      return OpsWardListResponse.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  Future<OpsApiResponse<OpsWard>> createWard({
    required String wardName,
    required String wardCode,
    required String areaId,
    String? description,
  }) async {
    return safeCall(() async {
      final res = await dio.post(
        OpsConstants.endpointWards,
        data: {
          'ward_name': wardName.trim(),
          'ward_code': wardCode.trim().toUpperCase(),
          'area_id':   areaId,
          if (description != null &&
              description.isNotEmpty)
            'description': description.trim(),
        },
      );
      return OpsWard.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  Future<OpsApiResponse<OpsWard>> updateWard(
    String wardId, {
    String? wardName,
    String? wardCode,
    String? description,
    bool?   isActive,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${OpsConstants.endpointWards}/$wardId',
        data: {
          if (wardName    != null) 'ward_name':   wardName.trim(),
          if (wardCode    != null)
            'ward_code': wardCode.trim().toUpperCase(),
          if (description != null)
            'description': description.trim(),
          if (isActive    != null) 'is_active':   isActive,
        },
      );
      return OpsWard.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  Future<OpsApiResponse<Map<String, dynamic>>> deleteWard(
      String wardId) async {
    return safeCall(() async {
      final res = await dio.delete(
          '${OpsConstants.endpointWards}/$wardId');
      return res.data as Map<String, dynamic>;
    });
  }

  // ═════════════════════════════════════════════
  // COMPLAINT CATEGORIES
  // ═════════════════════════════════════════════

  Future<OpsApiResponse<OpsCategoryListResponse>>
      fetchCategories({
    int     page     = 1,
    int     pageSize = OpsConstants.defaultPageSize,
    String? search,
    bool?   isActive,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        OpsConstants.endpointCategories,
        queryParameters: {
          'page':      page,
          'page_size': pageSize,
          if (search   != null && search.isNotEmpty)
            'search':    search,
          if (isActive != null) 'is_active': isActive,
        },
      );
      return OpsCategoryListResponse.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  Future<OpsApiResponse<OpsCategory>> createCategory({
    required String name,
    required String description,
    String? iconName,
    int     sortOrder = 0,
  }) async {
    return safeCall(() async {
      final res = await dio.post(
        OpsConstants.endpointCategories,
        data: {
          'name':        name.trim(),
          'description': description.trim(),
          if (iconName != null) 'icon_name': iconName,
          'sort_order': sortOrder,
        },
      );
      return OpsCategory.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  Future<OpsApiResponse<OpsCategory>> updateCategory(
    String categoryId, {
    String? name,
    String? description,
    String? iconName,
    int?    sortOrder,
    bool?   isActive,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${OpsConstants.endpointCategories}/$categoryId',
        data: {
          if (name        != null) 'name':        name.trim(),
          if (description != null)
            'description': description.trim(),
          if (iconName    != null) 'icon_name':   iconName,
          if (sortOrder   != null) 'sort_order':  sortOrder,
          if (isActive    != null) 'is_active':   isActive,
        },
      );
      return OpsCategory.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  Future<OpsApiResponse<Map<String, dynamic>>> deleteCategory(
      String categoryId) async {
    return safeCall(() async {
      final res = await dio.delete(
          '${OpsConstants.endpointCategories}/$categoryId');
      return res.data as Map<String, dynamic>;
    });
  }

  // ═════════════════════════════════════════════
  // HELPLINE
  // ═════════════════════════════════════════════

  Future<OpsApiResponse<OpsHelplineListResponse>>
      fetchHelplines({
    int     page     = 1,
    int     pageSize = OpsConstants.defaultPageSize,
    String? search,
    String? category,
    bool?   isSystem,
    bool?   isActive,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        OpsConstants.endpointHelpline,
        queryParameters: {
          'page':      page,
          'page_size': pageSize,
          if (search   != null && search.isNotEmpty)
            'search':    search,
          if (category != null) 'category':  category,
          if (isSystem != null) 'is_system': isSystem,
          if (isActive != null) 'is_active': isActive,
        },
      );
      return OpsHelplineListResponse.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  Future<OpsApiResponse<OpsHelpline>> createHelpline({
    required String name,
    required String number,
    required String category,
    String? description,
    bool    isSystem = true,
  }) async {
    return safeCall(() async {
      final res = await dio.post(
        OpsConstants.endpointHelpline,
        data: {
          'name':      name.trim(),
          'number':    number.trim(),
          'category':  category,
          'is_system': isSystem,
          if (description != null &&
              description.isNotEmpty)
            'description': description.trim(),
        },
      );
      return OpsHelpline.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  Future<OpsApiResponse<OpsHelpline>> updateHelpline(
    String helplineId, {
    String? name,
    String? number,
    String? category,
    String? description,
    bool?   isActive,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${OpsConstants.endpointHelpline}/$helplineId',
        data: {
          if (name        != null) 'name':        name.trim(),
          if (number      != null) 'number':      number.trim(),
          if (category    != null) 'category':    category,
          if (description != null)
            'description': description.trim(),
          if (isActive    != null) 'is_active':   isActive,
        },
      );
      return OpsHelpline.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  Future<OpsApiResponse<Map<String, dynamic>>> deleteHelpline(
      String helplineId) async {
    return safeCall(() async {
      final res = await dio.delete(
          '${OpsConstants.endpointHelpline}/$helplineId');
      return res.data as Map<String, dynamic>;
    });
  }
}

final opsMastersRepositoryProvider =
    Provider<OpsMastersRepository>((ref) {
  return OpsMastersRepository(ref.watch(opsDioProvider));
});