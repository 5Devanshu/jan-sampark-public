import '../../../../core/utils/date_formatter.dart';

// ─────────────────────────────────────────────
// Event Model
// ─────────────────────────────────────────────

class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.eventTime,
    required this.venueName,
    required this.venueAddress,
    required this.wardId,
    required this.areaId,
    required this.status,
    required this.createdById,
    required this.createdByRole,
    this.wardName,
    this.areaName,
    this.createdByName,
    this.coverImageUrl,
    this.registrationOpen = true,
    this.registrationDeadline,
    this.maxCapacity,
    this.totalRegistered = 0,
    this.actualAttendees = 0,
    this.participationRate = 0.0,
    this.isRegistered = false,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final String eventDate;
  final String eventTime;
  final String venueName;
  final String venueAddress;
  final String wardId;
  final String areaId;
  final String status;
  final String createdById;
  final String createdByRole;
  final String? wardName;
  final String? areaName;
  final String? createdByName;
  final String? coverImageUrl;
  final bool registrationOpen;
  final String? registrationDeadline;
  final int? maxCapacity;
  final int totalRegistered;
  final int actualAttendees;
  final double participationRate;
  final bool isRegistered;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ── Computed helpers ────────────────────────

  bool get isUpcoming => status == 'upcoming';
  bool get isOngoing => status == 'ongoing';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  bool get isFull => maxCapacity != null && totalRegistered >= maxCapacity!;

  bool get isDeadlinePassed {
    if (registrationDeadline == null) return false;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return today > registrationDeadline!;
  }

  bool get canRegister =>
      isUpcoming &&
      registrationOpen &&
      !isFull &&
      !isDeadlinePassed &&
      !isRegistered;

  int get daysUntilEvent => DateFormatter.daysRemaining(eventDate);

  String get formattedDateTime =>
      DateFormatter.toEventDateTime(eventDate, eventTime);

  int get spotsRemaining => maxCapacity != null
      ? (maxCapacity! - totalRegistered).clamp(0, maxCapacity!)
      : -1; // -1 means unlimited

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      eventDate: json['event_date'] as String? ?? '',
      eventTime: json['event_time'] as String? ?? '',
      venueName: json['venue_name'] as String? ?? '',
      venueAddress: json['venue_address'] as String? ?? '',
      wardId: json['ward_id'] as String? ?? '',
      areaId: json['area_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdById: json['created_by_id'] as String? ?? '',
      createdByRole: json['created_by_role'] as String? ?? '',
      wardName: json['ward_name'] as String?,
      areaName: json['area_name'] as String?,
      createdByName: json['created_by_name'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      registrationOpen: json['registration_open'] as bool? ?? true,
      registrationDeadline: json['registration_deadline'] as String?,
      maxCapacity: json['max_capacity'] as int?,
      totalRegistered: json['total_registered'] as int? ?? 0,
      actualAttendees: json['actual_attendees'] as int? ?? 0,
      participationRate: _toDouble(json['participation_rate']),
      isRegistered: json['is_registered'] as bool? ?? false,
      publishedAt: DateFormatter.fromApiString(json['published_at'] as String?),
      createdAt: DateFormatter.fromApiString(json['created_at'] as String?),
      updatedAt: DateFormatter.fromApiString(json['updated_at'] as String?),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  EventModel copyWith({bool? isRegistered}) {
    return EventModel(
      id: id,
      title: title,
      description: description,
      eventDate: eventDate,
      eventTime: eventTime,
      venueName: venueName,
      venueAddress: venueAddress,
      wardId: wardId,
      areaId: areaId,
      status: status,
      createdById: createdById,
      createdByRole: createdByRole,
      wardName: wardName,
      areaName: areaName,
      createdByName: createdByName,
      coverImageUrl: coverImageUrl,
      registrationOpen: registrationOpen,
      registrationDeadline: registrationDeadline,
      maxCapacity: maxCapacity,
      totalRegistered: isRegistered == true
          ? totalRegistered + 1
          : totalRegistered,
      actualAttendees: actualAttendees,
      participationRate: participationRate,
      isRegistered: isRegistered ?? this.isRegistered,
      publishedAt: publishedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

// ─────────────────────────────────────────────
// Paginated Response
// ─────────────────────────────────────────────

class EventListResponse {
  const EventListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final List<EventModel> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory EventListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return EventListResponse(
      data: list,
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

// ─────────────────────────────────────────────
// Registration Response
// ─────────────────────────────────────────────

class EventRegisterResponse {
  const EventRegisterResponse({
    required this.success,
    required this.message,
    required this.eventId,
    required this.registeredAt,
  });

  final bool success;
  final String message;
  final String eventId;
  final DateTime? registeredAt;

  factory EventRegisterResponse.fromJson(Map<String, dynamic> json) {
    return EventRegisterResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      eventId: json['event_id'] as String? ?? '',
      registeredAt: DateFormatter.fromApiString(
        json['registered_at'] as String?,
      ),
    );
  }
}
