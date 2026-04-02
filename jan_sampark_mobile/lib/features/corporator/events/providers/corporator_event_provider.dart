import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../voter/events/models/event_models.dart';

// Reuse voter providers
export '../../../voter/events/providers/event_provider.dart'
    show eventListProvider, eventDetailProvider;

// ─────────────────────────────────────────────
// Create Event (reuse Leader's but corporator-scoped)
// ─────────────────────────────────────────────

export '../../../leader/events/providers/leader_event_provider.dart'
    show createEventProvider, CreateEventState;

// ─────────────────────────────────────────────
// Attendance state
// ─────────────────────────────────────────────

class AttendanceState {
  const AttendanceState({
    this.isLoading    = false,
    this.isSuccess    = false,
    this.errorMessage = '',
    this.attendeeCount = 0,
  });
  final bool   isLoading;
  final bool   isSuccess;
  final String errorMessage;
  final int    attendeeCount;
  bool get hasError => errorMessage.isNotEmpty;
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  AttendanceNotifier(this._dio) : super(const AttendanceState());
  final Dio _dio;

  Future<bool> markAttendance({
    required String eventId,
    required int    count,
  }) async {
    state = const AttendanceState(isLoading: true);
    try {
      await _dio.patch(
        '${AppConstants.endpointEvents}/$eventId/attendance',
        data: {'actual_attendees': count},
      );
      state = AttendanceState(
          isSuccess: true, attendeeCount: count);
      return true;
    } catch (e) {
      state = AttendanceState(
        errorMessage:
            e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const AttendanceState();
}

final attendanceProvider = StateNotifierProvider
    .autoDispose<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier(ref.watch(dioProvider));
});