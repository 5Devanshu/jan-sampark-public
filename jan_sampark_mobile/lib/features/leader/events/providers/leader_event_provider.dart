import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../voter/events/models/event_models.dart';
import '../../../voter/events/repositories/event_repository.dart';

// ─────────────────────────────────────────────
// Reuse voter event list provider
// The leader sees ward events — same endpoint, same model.
// ─────────────────────────────────────────────

export '../../../voter/events/providers/event_provider.dart'
    show eventListProvider, eventDetailProvider;

// ─────────────────────────────────────────────
// Create Event State
// ─────────────────────────────────────────────

class CreateEventState {
  const CreateEventState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage = '',
    this.createdEventId,
  });

  final bool isLoading;
  final bool isSuccess;
  final String errorMessage;
  final String? createdEventId;

  bool get hasError => errorMessage.isNotEmpty;

  CreateEventState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? createdEventId,
  }) {
    return CreateEventState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      createdEventId: createdEventId ?? this.createdEventId,
    );
  }
}

class CreateEventNotifier extends StateNotifier<CreateEventState> {
  CreateEventNotifier(this._dio) : super(const CreateEventState());

  final Dio _dio;

  Future<bool> create({
    required String title,
    required String description,
    required String eventDate,
    required String eventTime,
    required String venueName,
    required String venueAddress,
    int? maxCapacity,
    String? registrationDeadline,
    String? coverImagePath,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: '', isSuccess: false);

    try {
      final fields = <String, dynamic>{
        'title': title,
        'description': description,
        'event_date': eventDate,
        'event_time': eventTime,
        'venue_name': venueName,
        'venue_address': venueAddress,
        if (maxCapacity != null) 'max_capacity': maxCapacity,
        if (registrationDeadline != null)
          'registration_deadline': registrationDeadline,
      };

      dynamic data;
      if (coverImagePath != null && coverImagePath.isNotEmpty) {
        data = FormData.fromMap({
          ...fields,
          'cover_image': await MultipartFile.fromFile(
            coverImagePath,
            filename: coverImagePath.split('/').last,
          ),
        });
      } else {
        data = fields;
      }

      final res = await _dio.post(AppConstants.endpointEvents, data: data);

      final id = (res.data as Map<String, dynamic>)['id'] as String? ?? '';

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        createdEventId: id,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const CreateEventState();
}

final createEventProvider =
    StateNotifierProvider.autoDispose<CreateEventNotifier, CreateEventState>((
      ref,
    ) {
      return CreateEventNotifier(ref.watch(dioProvider));
    });
