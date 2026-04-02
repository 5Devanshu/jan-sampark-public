import '../../../core/utils/date_formatter.dart';

// ─────────────────────────────────────────────
// Notification Model
// ─────────────────────────────────────────────

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.referenceId,
    this.referenceType,
    this.metadata,
  });

  final String   id;
  final String   type;
  final String   title;
  final String   body;
  final bool     isRead;
  final DateTime createdAt;
  final String?  referenceId;
  final String?  referenceType;
  final Map<String, dynamic>? metadata;

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id:            id,
      type:          type,
      title:         title,
      body:          body,
      isRead:        isRead ?? this.isRead,
      createdAt:     createdAt,
      referenceId:   referenceId,
      referenceType: referenceType,
      metadata:      metadata,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id:            json['id']             as String?  ?? '',
      type:          json['type']           as String?  ?? '',
      title:         json['title']          as String?  ?? '',
      body:          json['body']           as String?  ?? '',
      isRead:        json['is_read']        as bool?    ?? false,
      referenceId:   json['reference_id']   as String?,
      referenceType: json['reference_type'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateFormatter.fromApiString(
              json['created_at'] as String?) ??
          DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────
// Paginated Response
// ─────────────────────────────────────────────

class NotificationListResponse {
  const NotificationListResponse({
    required this.data,
    required this.total,
    required this.unreadCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final List<NotificationModel> data;
  final int total;
  final int unreadCount;
  final int page;
  final int pageSize;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory NotificationListResponse.fromJson(
      Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => NotificationModel.fromJson(
            e as Map<String, dynamic>))
        .toList();
    return NotificationListResponse(
      data:        list,
      total:       json['total']        as int? ?? 0,
      unreadCount: json['unread_count'] as int? ?? 0,
      page:        json['page']         as int? ?? 1,
      pageSize:    json['page_size']    as int? ?? 20,
      totalPages:  json['total_pages']  as int? ?? 1,
    );
  }
}