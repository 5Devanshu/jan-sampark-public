import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/event_models.dart';

class EventRepository extends BaseRepository {
  const EventRepository(super.dio);

  // ─────────────────────────────────────────────
  // Fetch Events
  // ─────────────────────────────────────────────

  Future<ApiResponse<EventListResponse>> fetchEvents({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? wardId,
    String? areaId,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointEvents,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (status != null) 'status': status,
          if (wardId != null) 'ward_id': wardId,
          if (areaId != null) 'area_id': areaId,
        },
      );
      return EventListResponse.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<ApiResponse<EventModel>> fetchEventDetail(String eventId) async {
    return safeCall(() async {
      final res = await dio.get('${AppConstants.endpointEvents}/$eventId');
      return EventModel.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────
  // My Registrations
  // ─────────────────────────────────────────────

  Future<ApiResponse<EventListResponse>> fetchMyRegistrations({
    int page = 1,
    int pageSize = 20,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointEvents,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          'registered': true,
        },
      );
      return EventListResponse.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────
  // Register / Cancel
  // ─────────────────────────────────────────────

  Future<ApiResponse<EventRegisterResponse>> registerForEvent(
    String eventId,
  ) async {
    return safeCall(() async {
      final res = await dio.post(
        '${AppConstants.endpointEvents}/$eventId/register',
      );
      return EventRegisterResponse.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> cancelRegistration(
    String eventId,
  ) async {
    return safeCall(() async {
      final res = await dio.delete(
        '${AppConstants.endpointEvents}/$eventId/register',
      );
      return res.data as Map<String, dynamic>;
    });
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.watch(dioProvider));
});
