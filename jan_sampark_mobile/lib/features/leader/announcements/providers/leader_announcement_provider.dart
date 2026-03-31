import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/dio_client.dart';

// ─────────────────────────────────────────────
// Reuse voter announcement list provider
// ─────────────────────────────────────────────

export '../../../voter/announcements/providers/announcement_provider.dart'
    show
        announcementListProvider,
        announcementDetailProvider,
        AnnouncementListNotifier;

// ─────────────────────────────────────────────
// Create Announcement State
// ─────────────────────────────────────────────

class CreateAnnouncementState {
  const CreateAnnouncementState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage = '',
  });

  final bool isLoading;
  final bool isSuccess;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;

  CreateAnnouncementState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return CreateAnnouncementState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CreateAnnouncementNotifier
    extends StateNotifier<CreateAnnouncementState> {
  CreateAnnouncementNotifier(this._dio)
    : super(const CreateAnnouncementState());

  final dio;

  Future<bool> create({
    required String title,
    required String content,
    required String category,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: '', isSuccess: false);

    try {
      await _dio.post(
        AppConstants.endpointAnnouncements,
        data: {'title': title, 'content': content, 'category': category},
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const CreateAnnouncementState();
}

final createAnnouncementProvider =
    StateNotifierProvider.autoDispose<
      CreateAnnouncementNotifier,
      CreateAnnouncementState
    >((ref) {
      return CreateAnnouncementNotifier(ref.watch(dioProvider));
    });
