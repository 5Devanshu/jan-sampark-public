import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../voter/polls/models/poll_models.dart';

// Reuse voter poll list
export '../../../voter/polls/providers/poll_provider.dart'
    show pollListProvider, pollResultsProvider, pollDetailProvider;

// ─────────────────────────────────────────────
// Create Poll State
// ─────────────────────────────────────────────

class CreatePollState {
  const CreatePollState({
    this.isLoading    = false,
    this.isSuccess    = false,
    this.errorMessage = '',
    this.createdId,
  });
  final bool    isLoading;
  final bool    isSuccess;
  final String  errorMessage;
  final String? createdId;
  bool get hasError => errorMessage.isNotEmpty;

  CreatePollState copyWith({
    bool?   isLoading,
    bool?   isSuccess,
    String? errorMessage,
    String? createdId,
  }) {
    return CreatePollState(
      isLoading:    isLoading    ?? this.isLoading,
      isSuccess:    isSuccess    ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      createdId:    createdId    ?? this.createdId,
    );
  }
}

class CreatePollNotifier extends StateNotifier<CreatePollState> {
  CreatePollNotifier(this._ref)
      : super(const CreatePollState());

  final Ref _ref;

  Future<bool> create({
    required String       question,
    required String       pollType,
    required bool         isAnonymous,
    required bool         showResults,
    List<String>          options        = const [],
    String?               closesAt,
  }) async {
    state = state.copyWith(
      isLoading: true, errorMessage: '', isSuccess: false,
    );

    try {
      final dio = _ref.read(dioProvider);

      final data = <String, dynamic>{
        'question':     question,
        'poll_type':    pollType,
        'is_anonymous': isAnonymous,
        'show_results': showResults,
        if (options.isNotEmpty)
          'options': options
              .map((o) => {'option_text': o})
              .toList(),
        if (closesAt != null) 'closes_at': closesAt,
      };

      final res = await dio.post(
        AppConstants.endpointPolls,
        data: data,
      );

      final id =
          (res.data as Map<String, dynamic>)['id'] as String? ?? '';

      state = state.copyWith(
        isLoading: false, isSuccess: true, createdId: id,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading:    false,
        errorMessage: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const CreatePollState();
}

final createPollProvider = StateNotifierProvider
    .autoDispose<CreatePollNotifier, CreatePollState>((ref) {
  return CreatePollNotifier(ref);
});