import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import '../models/notification_models.dart';

class NotificationRepository extends BaseRepository {
  const NotificationRepository(super.dio);

  // ─────────────────────────────────────────────
  // Fetch
  // ─────────────────────────────────────────────

  Future<ApiResponse<NotificationListResponse>> fetchNotifications({
    int  page     = 1,
    int  pageSize = 20,
    bool? unreadOnly,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointNotifications,
        queryParameters: {
          'page':      page,
          'page_size': pageSize,
          if (unreadOnly != null) 'unread_only': unreadOnly,
        },
      );
      return NotificationListResponse.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────
  // Unread count only (for the bell badge)
  // ─────────────────────────────────────────────

  Future<ApiResponse<int>> fetchUnreadCount() async {
    return safeCall(() async {
      final res = await dio.get(
        '${AppConstants.endpointNotifications}/unread-count',
      );
      final data = res.data as Map<String, dynamic>;
      return data['unread_count'] as int? ?? 0;
    });
  }

  // ─────────────────────────────────────────────
  // Mark single as read
  // ─────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> markRead(
      String notificationId) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${AppConstants.endpointNotifications}/$notificationId/read',
      );
      return res.data as Map<String, dynamic>;
    });
  }

  // ─────────────────────────────────────────────
  // Mark all as read
  // ─────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> markAllRead() async {
    return safeCall(() async {
      final res = await dio.patch(
        '${AppConstants.endpointNotifications}/read-all',
      );
      return res.data as Map<String, dynamic>;
    });
  }

  // ─────────────────────────────────────────────
  // Delete single
  // ─────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> deleteNotification(
      String notificationId) async {
    return safeCall(() async {
      final res = await dio.delete(
        '${AppConstants.endpointNotifications}/$notificationId',
      );
      return res.data as Map<String, dynamic>;
    });
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(dioProvider));
});