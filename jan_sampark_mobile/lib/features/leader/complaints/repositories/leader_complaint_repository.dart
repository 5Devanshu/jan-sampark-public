import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_constants.dart';

// ─────────────────────────────────────────────
// Complaint List Response (reuse voter model)
// ─────────────────────────────────────────────

import '../../../voter/campaigns/models/campaign_models.dart'
    show CampaignModel;

class ComplaintListItem {
  const ComplaintListItem({
    required this.id,
    required this.complaintNumber,
    required this.categoryName,
    required this.title,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.wardName,
    this.areaName,
    this.assignedToName,
    this.assignedToType,
    this.isEscalated = false,
    this.escalationPriority,
    this.submittedByVoterName,
    this.images = const [],
  });

  final String id;
  final String complaintNumber;
  final String categoryName;
  final String title;
  final String status;
  final String priority;
  final DateTime createdAt;
  final String? wardName;
  final String? areaName;
  final String? assignedToName;
  final String? assignedToType;
  final bool isEscalated;
  final String? escalationPriority;
  final String? submittedByVoterName;
  final List<String> images;

  factory ComplaintListItem.fromJson(Map<String, dynamic> json) {
    return ComplaintListItem(
      id: json['id'] as String? ?? '',
      complaintNumber: json['complaint_number'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      wardName: json['ward_name'] as String?,
      areaName: json['area_name'] as String?,
      assignedToName: json['assigned_to_name'] as String?,
      assignedToType: json['assigned_to_type'] as String?,
      isEscalated: json['escalated'] as bool? ?? false,
      escalationPriority: json['escalation_priority'] as String?,
      submittedByVoterName: json['submitted_by_voter_name'] as String?,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class ComplaintListResponse {
  const ComplaintListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final List<ComplaintListItem> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory ComplaintListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => ComplaintListItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return ComplaintListResponse(
      data: list,
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

// ─────────────────────────────────────────────
// Full Complaint Detail
// ─────────────────────────────────────────────

class ComplaintAuditEntry {
  const ComplaintAuditEntry({
    required this.action,
    required this.changedByName,
    required this.changedByRole,
    required this.timestamp,
    this.fromStatus,
    this.toStatus,
    this.reason,
  });

  final String action;
  final String changedByName;
  final String changedByRole;
  final DateTime timestamp;
  final String? fromStatus;
  final String? toStatus;
  final String? reason;

  factory ComplaintAuditEntry.fromJson(Map<String, dynamic> json) {
    return ComplaintAuditEntry(
      action: json['action'] as String? ?? '',
      changedByName: json['changed_by_name'] as String? ?? '',
      changedByRole: json['changed_by_role'] as String? ?? '',
      fromStatus: json['from_status'] as String?,
      toStatus: json['to_status'] as String?,
      reason: json['reason'] as String?,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class ComplaintNote {
  const ComplaintNote({
    required this.noteId,
    required this.noteText,
    required this.addedByName,
    required this.addedByRole,
    required this.timestamp,
    this.isInternal = false,
  });

  final String noteId;
  final String noteText;
  final String addedByName;
  final String addedByRole;
  final DateTime timestamp;
  final bool isInternal;

  factory ComplaintNote.fromJson(Map<String, dynamic> json) {
    return ComplaintNote(
      noteId: json['note_id'] as String? ?? '',
      noteText: json['note_text'] as String? ?? '',
      addedByName: json['added_by_name'] as String? ?? '',
      addedByRole: json['added_by_role'] as String? ?? '',
      isInternal: json['is_internal'] as bool? ?? false,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class ComplaintDetail {
  const ComplaintDetail({
    required this.id,
    required this.complaintNumber,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.wardId,
    required this.areaId,
    required this.submittedByVoterId,
    required this.escalated,
    required this.createdAt,
    required this.updatedAt,
    this.wardName,
    this.areaName,
    this.assignedToType,
    this.assignedToId,
    this.assignedToName,
    this.submittedByVoterName,
    this.escalationPriority,
    this.escalationReason,
    this.escalationTimestamp,
    this.resolutionNotes,
    this.resolvedAt,
    this.images = const [],
    this.notes = const [],
    this.auditTrail = const [],
  });

  final String id;
  final String complaintNumber;
  final String categoryId;
  final String categoryName;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String wardId;
  final String areaId;
  final String submittedByVoterId;
  final bool escalated;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? wardName;
  final String? areaName;
  final String? assignedToType;
  final String? assignedToId;
  final String? assignedToName;
  final String? submittedByVoterName;
  final String? escalationPriority;
  final String? escalationReason;
  final DateTime? escalationTimestamp;
  final String? resolutionNotes;
  final DateTime? resolvedAt;
  final List<String> images;
  final List<ComplaintNote> notes;
  final List<ComplaintAuditEntry> auditTrail;

  bool get isPending => status == 'pending';
  bool get isAcknowledged => status == 'acknowledged';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';
  bool get isRejected => status == 'rejected';
  bool get isTerminal =>
      status == 'resolved' || status == 'closed' || status == 'rejected';

  factory ComplaintDetail.fromJson(Map<String, dynamic> json) {
    final noteList = (json['notes'] as List<dynamic>? ?? [])
        .map((e) => ComplaintNote.fromJson(e as Map<String, dynamic>))
        .toList();
    final auditList = (json['audit_trail'] as List<dynamic>? ?? [])
        .map((e) => ComplaintAuditEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return ComplaintDetail(
      id: json['id'] as String? ?? '',
      complaintNumber: json['complaint_number'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      wardId: json['ward_id'] as String? ?? '',
      areaId: json['area_id'] as String? ?? '',
      submittedByVoterId: json['submitted_by_voter_id'] as String? ?? '',
      escalated: json['escalated'] as bool? ?? false,
      wardName: json['ward_name'] as String?,
      areaName: json['area_name'] as String?,
      assignedToType: json['assigned_to_type'] as String?,
      assignedToId: json['assigned_to_id'] as String?,
      assignedToName: json['assigned_to_name'] as String?,
      submittedByVoterName: json['submitted_by_voter_name'] as String?,
      escalationPriority: json['escalation_priority'] as String?,
      escalationReason: json['escalation_reason'] as String?,
      resolutionNotes: json['resolution_notes'] as String?,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      notes: noteList,
      auditTrail: auditList,
      escalationTimestamp: DateTime.tryParse(
        json['escalation_timestamp'] as String? ?? '',
      ),
      resolvedAt: DateTime.tryParse(json['resolved_at'] as String? ?? ''),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────

class LeaderComplaintRepository extends BaseRepository {
  const LeaderComplaintRepository(super.dio);

  Future<ApiResponse<ComplaintListResponse>> fetchComplaints({
    int page = 1,
    int pageSize = 20,
    String? statusFilter,
    String? categoryId,
    String? priority,
    bool? escalated,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointComplaints,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (statusFilter != null) 'status': statusFilter,
          if (categoryId != null) 'category_id': categoryId,
          if (priority != null) 'priority': priority,
          if (escalated != null) 'escalated': escalated,
        },
      );
      return ComplaintListResponse.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<ApiResponse<ComplaintDetail>> fetchDetail(String id) async {
    return safeCall(() async {
      final res = await dio.get('${AppConstants.endpointComplaints}/$id');
      return ComplaintDetail.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> acknowledge(
    String id, {
    String? note,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${AppConstants.endpointComplaints}/$id/acknowledge',
        data: {'note': note},
      );
      return res.data as Map<String, dynamic>;
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> escalate(
    String id, {
    required String priority,
    required String reason,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${AppConstants.endpointComplaints}/$id/escalate',
        data: {'priority': priority, 'reason': reason},
      );
      return res.data as Map<String, dynamic>;
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> addNote(
    String id, {
    required String noteText,
    bool isInternal = false,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${AppConstants.endpointComplaints}/$id/note',
        data: {'note_text': noteText, 'is_internal': isInternal},
      );
      return res.data as Map<String, dynamic>;
    });
  }

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

  Future<ApiResponse<Map<String, dynamic>>> updateStatus(
    String id, {
    required String newStatus,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${AppConstants.endpointComplaints}/$id/status',
        data: {'new_status': newStatus},
      );
      return res.data as Map<String, dynamic>;
    });
  }
}

final leaderComplaintRepositoryProvider = Provider<LeaderComplaintRepository>((
  ref,
) {
  return LeaderComplaintRepository(ref.watch(dioProvider));
});
