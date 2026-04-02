import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../leader/complaints/repositories/leader_complaint_repository.dart';

/// Corporator complaint repository extends Leader's by adding
/// resolve, verify-donation, and reassign endpoints.
class CorporatorComplaintRepository extends BaseRepository {
  const CorporatorComplaintRepository(super.dio);

  // ─────────────────────────────────────────────
  // List (same shape as Leader)
  // ─────────────────────────────────────────────

  Future<ApiResponse<ComplaintListResponse>> fetchComplaints({
    int     page         = 1,
    int     pageSize     = 20,
    String? statusFilter,
    String? categoryId,
    String? priority,
    bool?   escalated,
    String? wardId,
    String? assignedToType, // 'leader' | 'corporator'
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointComplaints,
        queryParameters: {
          'page':      page,
          'page_size': pageSize,
          if (statusFilter   != null) 'status':           statusFilter,
          if (categoryId     != null) 'category_id':      categoryId,
          if (priority       != null) 'priority':         priority,
          if (escalated      != null) 'escalated':        escalated,
          if (wardId         != null) 'ward_id':          wardId,
          if (assignedToType != null) 'assigned_to_type': assignedToType,
        },
      );
      return ComplaintListResponse.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────
  // Detail (shared)
  // ─────────────────────────────────────────────

  Future<ApiResponse<ComplaintDetail>> fetchDetail(
      String id) async {
    return safeCall(() async {
      final res = await dio.get(
          '${AppConstants.endpointComplaints}/$id');
      return ComplaintDetail.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────
  // Resolve
  // ─────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> resolve(
    String id, {
    required String resolutionNotes,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${AppConstants.endpointComplaints}/$id/resolve',
        data: {'resolution_notes': resolutionNotes},
      );
      return res.data as Map<String, dynamic>;
    });
  }

  // ─────────────────────────────────────────────
  // Close (after resolution review)
  // ─────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> close(
      String id) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${AppConstants.endpointComplaints}/$id/close',
      );
      return res.data as Map<String, dynamic>;
    });
  }

  // ─────────────────────────────────────────────
  // Reject (corporator-level)
  // ─────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> reject(
    String id, {
    required String reason,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${AppConstants.endpointComplaints}/$id/reject',
        data: {'reason': reason},
      );
      return res.data as Map<String, dynamic>;
    });
  }

  // ─────────────────────────────────────────────
  // Reassign to a different leader
  // ─────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> reassign(
    String id, {
    required String leaderId,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${AppConstants.endpointComplaints}/$id/reassign',
        data: {'leader_id': leaderId},
      );
      return res.data as Map<String, dynamic>;
    });
  }

  // ─────────────────────────────────────────────
  // Add resolution note
  // ─────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> addNote(
    String id, {
    required String noteText,
    bool isInternal = false,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${AppConstants.endpointComplaints}/$id/note',
        data: {
          'note_text':   noteText,
          'is_internal': isInternal,
        },
      );
      return res.data as Map<String, dynamic>;
    });
  }
}

final corporatorComplaintRepositoryProvider =
    Provider<CorporatorComplaintRepository>((ref) {
  return CorporatorComplaintRepository(ref.watch(dioProvider));
});