import '../../../../core/utils/date_formatter.dart';
import '../../../../core/constants/app_constants.dart';

class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.category,
    required this.title,
    required this.contentPreview,
    required this.status,
    required this.createdByName,
    required this.createdByRole,
    this.content,
    this.publishedAt,
    this.viewCount = 0,
    this.acknowledgementCount = 0,
    this.isAcknowledged = false,
    this.createdAt,
  });

  final String id;
  final String category;
  final String title;
  final String contentPreview;
  final String status;
  final String createdByName;
  final String createdByRole;
  final String? content;
  final DateTime? publishedAt;
  final int viewCount;
  final int acknowledgementCount;
  final bool isAcknowledged;
  final DateTime? createdAt;

  String get categoryLabel =>
      AppConstants.announcementCategoryLabels[category] ?? category;

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    // Handle nested metrics object
    final metrics = json['metrics'] as Map<String, dynamic>? ?? {};

    return AnnouncementModel(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      title: json['title'] as String? ?? '',
      contentPreview: json['content_preview'] as String? ?? '',
      content: json['content'] as String?,
      status: json['status'] as String? ?? '',
      createdByName: json['created_by_name'] as String? ?? '',
      createdByRole: json['created_by_role'] as String? ?? '',
      publishedAt: DateFormatter.fromApiString(json['published_at'] as String?),
      viewCount: metrics['view_count'] ?? json['view_count'] as int? ?? 0,
      acknowledgementCount:
          metrics['acknowledgement_count'] ??
          json['acknowledgement_count'] as int? ??
          0,
      isAcknowledged: json['is_acknowledged'] as bool? ?? false,
      createdAt: DateFormatter.fromApiString(json['created_at'] as String?),
    );
  }
}

class AnnouncementListResponse {
  const AnnouncementListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final List<AnnouncementModel> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory AnnouncementListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return AnnouncementListResponse(
      data: list,
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}
