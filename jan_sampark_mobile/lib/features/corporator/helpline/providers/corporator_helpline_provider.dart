import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../voter/helpline/models/helpline_models.dart';
import '../../../voter/helpline/repositories/helpline_repository.dart';

// Reuse voter helpline list
export '../../../voter/helpline/providers/helpline_provider.dart'
    show helplineProvider, HelplineNotifier;

// ─────────────────────────────────────────────
// Create Helpline State
// ─────────────────────────────────────────────

class CreateHelplineState {
  const CreateHelplineState({
    this.isLoading    = false,
    this.isSuccess    = false,
    this.errorMessage = '',
  });
  final bool   isLoading;
  final bool   isSuccess;
  final String errorMessage;
  bool get hasError => errorMessage.isNotEmpty;

  CreateHelplineState copyWith({
    bool?   isLoading,
    bool?   isSuccess,
    String? errorMessage,
  }) {
    return CreateHelplineState(
      isLoading:    isLoading    ?? this.isLoading,
      isSuccess:    isSuccess    ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CreateHelplineNotifier
    extends StateNotifier<CreateHelplineState> {
  CreateHelplineNotifier(this._repo)
      : super(const CreateHelplineState());

  final HelplineRepository _repo;

  Future<bool> create({
    required String name,
    required String number,
    required String category,
    String? description,
  }) async {
    state = state.copyWith(
      isLoading:    true,
      errorMessage: '',
      isSuccess:    false,
    );

    try {
      final dio = _repo.dio;
      await dio.post(
        AppConstants.endpointHelpline,
        data: {
          'name':        name,
          'number':      number,
          'category':    category,
          if (description != null && description.isNotEmpty)
            'description': description,
          'is_system': false, // Corporator adds custom numbers
        },
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading:    false,
        errorMessage: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const CreateHelplineState();
}

final createHelplineProvider = StateNotifierProvider
    .autoDispose<CreateHelplineNotifier, CreateHelplineState>(
        (ref) {
  return CreateHelplineNotifier(
      ref.watch(helplineRepositoryProvider));
});

// ─────────────────────────────────────────────
// Delete / Toggle helpline
// ─────────────────────────────────────────────

class HelplineActionNotifier extends StateNotifier<bool> {
  HelplineActionNotifier(this._dio) : super(false);
  final Dio _dio;

  Future<bool> toggleActive(
      String id, {required bool isActive}) async {
    state = true;
    try {
      await _dio.patch(
        '${AppConstants.endpointHelpline}/$id',
        data: {'is_active': isActive},
      );
      state = false;
      return true;
    } catch (_) {
      state = false;
      return false;
    }
  }

  Future<bool> delete(String id) async {
    state = true;
    try {
      await _dio.delete(
          '${AppConstants.endpointHelpline}/$id');
      state = false;
      return true;
    } catch (_) {
      state = false;
      return false;
    }
  }
}

final helplineActionProvider = StateNotifierProvider
    .autoDispose<HelplineActionNotifier, bool>((ref) {
  return HelplineActionNotifier(ref.watch(dioProvider));
});
