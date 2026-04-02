import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../models/helpline_models.dart';
import '../repositories/helpline_repository.dart';

class HelplineState {
  const HelplineState({
    this.helplines = const [],
    this.isLoading = false,
    this.errorMessage = '',
  });

  final List<HelplineModel> helplines;
  final bool isLoading;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isEmpty => !isLoading && helplines.isEmpty && !hasError;

  HelplineState copyWith({
    List<HelplineModel>? helplines,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HelplineState(
      helplines: helplines ?? this.helplines,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HelplineNotifier extends StateNotifier<HelplineState> {
  HelplineNotifier(this._repo) : super(const HelplineState()) {
    load();
  }

  final HelplineRepository _repo;

  Future<void> load({String? category}) async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    final res = await _repo.fetchHelplines(category: category);
    if (res.isError) {
      final e = res.exception;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : e.toString(),
      );
      return;
    }
    state = state.copyWith(
      isLoading: false,
      helplines: res.data?.data ?? const [],
    );
  }
}

final helplineProvider =
    StateNotifierProvider<HelplineNotifier, HelplineState>((ref) {
  return HelplineNotifier(ref.watch(helplineRepositoryProvider));
});
