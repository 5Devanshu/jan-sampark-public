import 'package:flutter/material.dart';

import '../../../core/theme/ops_colors.dart';
import '../../../core/utils/ops_date_formatter.dart';

// ─────────────────────────────────────────────
// Complaint list item (read-only Ops view)
// ─────────────────────────────────────────────

class OpsComplaintItem {
  const OpsComplaintItem({
    required this.id,
    required this.complaintNumber,
    required this.title,
    required this.status,
    required this.priority,
    required this.categoryName,
    required this.areaName,
    required this.wardName,
    required this.createdAt,
    this.isEscalated        = false,
    this.assignedToName,
    this.corporatorName,
    this.resolutionRate     = 0.0,
    this.escalationReason,
  });

  final String   id;
  final String   complaintNumber;
  final String   title;
  final String   status;
  final String   priority;
  final String   categoryName;
  final String   areaName;
  final String   wardName;
  final DateTime createdAt;
  final bool     isEscalated;
  final String?  assignedToName;
  final String?  corporatorName;
  final double   resolutionRate;
  final String?  escalationReason;

  factory OpsComplaintItem.fromJson(
      Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>? ?? {};

    return OpsComplaintItem(
      id:              json['id']               as String? ?? '',
      complaintNumber: json['complaint_number'] as String? ?? '',
      title:           json['title']            as String? ?? '',
      status:          json['status']           as String? ?? '',
      priority:        json['priority']         as String? ?? '',
      categoryName:    json['category_name']    as String? ?? '',
      areaName:        loc['area_name']         as String? ?? '',
      wardName:        loc['ward_name']         as String? ?? '',
      isEscalated:     json['is_escalated']     as bool?   ?? false,
      assignedToName:  json['assigned_to_name'] as String?,
      corporatorName:  json['corporator_name']  as String?,
      escalationReason: json['escalation_reason'] as String?,
      createdAt: OpsDateFormatter.fromApiString(
              json['created_at'] as String?) ??
          DateTime.now(),
    );
  }
}

class OpsComplaintListResponse {
  const OpsComplaintListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
    this.escalatedCount = 0,
    this.pendingCount   = 0,
  });

  final List<OpsComplaintItem> data;
  final int total;
  final int page;
  final int totalPages;
  final int escalatedCount;
  final int pendingCount;

  bool get hasMore => page < totalPages;

  factory OpsComplaintListResponse.fromJson(
      Map<String, dynamic> json) {
    return OpsComplaintListResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => OpsComplaintItem.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      total:          json['total']           as int? ?? 0,
      page:           json['page']            as int? ?? 1,
      totalPages:     json['total_pages']     as int? ?? 1,
      escalatedCount: json['escalated_count'] as int? ?? 0,
      pendingCount:   json['pending_count']   as int? ?? 0,
    );
  }
}

// ─────────────────────────────────────────────
// Filter
// ─────────────────────────────────────────────

class OpsComplaintFilter {
  const OpsComplaintFilter({
    this.status,
    this.priority,
    this.areaId,
    this.categoryId,
    this.escalatedOnly = false,
    this.search,
  });

  final String? status;
  final String? priority;
  final String? areaId;
  final String? categoryId;
  final bool    escalatedOnly;
  final String? search;

  bool get hasFilters =>
      status      != null ||
      priority    != null ||
      areaId      != null ||
      categoryId  != null ||
      escalatedOnly ||
      (search != null && search!.isNotEmpty);

  OpsComplaintFilter copyWith({
    String? status,
    String? priority,
    String? areaId,
    String? categoryId,
    bool?   escalatedOnly,
    String? search,
    bool    clearStatus   = false,
    bool    clearPriority = false,
    bool    clearArea     = false,
    bool    clearCategory = false,
  }) {
    return OpsComplaintFilter(
      status:       clearStatus   ? null : (status   ?? this.status),
      priority:     clearPriority ? null : (priority ?? this.priority),
      areaId:       clearArea     ? null : (areaId   ?? this.areaId),
      categoryId:   clearCategory ? null : (categoryId ?? this.categoryId),
      escalatedOnly: escalatedOnly ?? this.escalatedOnly,
      search:       search ?? this.search,
    );
  }

  OpsComplaintFilter cleared() =>
      const OpsComplaintFilter();
}

// ─────────────────────────────────────────────
// Status and priority display helpers
// ─────────────────────────────────────────────

const kOpsComplaintStatuses = {
  'pending':      'Pending',
  'acknowledged': 'Acknowledged',
  'in_progress':  'In Progress',
  'escalated':    'Escalated',
  'resolved':     'Resolved',
  'rejected':     'Rejected',
  'closed':       'Closed',
};

const kOpsComplaintPriorities = {
  'low':       'Low',
  'medium':    'Medium',
  'high':      'High',
  'emergency': 'Emergency',
};

Color opsStatusColor(String status) {
  return switch (status) {
    'pending'      => OpsColors.warning,
    'acknowledged' => OpsColors.info,
    'in_progress'  => OpsColors.primary,
    'escalated'    => OpsColors.error,
    'resolved'     => OpsColors.success,
    'rejected'     => OpsColors.textSecondary,
    'closed'       => OpsColors.textDisabled,
    _              => OpsColors.textSecondary,
  };
}

Color opsPriorityColor(String priority) {
  return switch (priority) {
    'emergency' => OpsColors.error,
    'high'      => OpsColors.escalation,
    'medium'    => OpsColors.warning,
    'low'       => OpsColors.success,
    _           => OpsColors.textSecondary,
  };
}
