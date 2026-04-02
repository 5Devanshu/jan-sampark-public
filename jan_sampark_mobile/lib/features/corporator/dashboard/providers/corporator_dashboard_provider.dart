import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../models/corporator_models.dart';
import '../repositories/corporator_dashboard_repository.dart';

class CorporatorDashboardState {
  const CorporatorDashboardState({
    this.dashboard,
    this.isLoading    = false,
    this.errorMessage = '',
    this.selectedPeriod = '30d',
  });

  final AreaDashboard? dashboard;
  final bool   isLoading;
  final String errorMessage;
  final String selectedPeriod;

  bool get hasError => errorMessage.isNotEmpty;
  bool get hasData  => dashboard != null;

  CorporatorDashboardState copyWith({
    AreaDashboard? dashboard,
    bool?   isLoading,
    String? errorMessage,
    String? selectedPeriod,
  }) {
    return CorporatorDashboardState(
      dashboard:      dashboard      ?? this.dashboard,
      isLoading:      isLoading      ?? this.isLoading,
      errorMessage:   errorMessage   ?? this.errorMessage,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }
}

class CorporatorDashboardNotifier
    extends StateNotifier<CorporatorDashboardState> {
  CorporatorDashboardNotifier(this._repo)
      : super(const CorporatorDashboardState()) {
    load();
  }

  final CorporatorDashboardRepository _repo;

  Future<void> load({String? period}) async {
    state = state.copyWith(
      isLoading:      true,
      errorMessage:   '',
      selectedPeriod: period ?? state.selectedPeriod,
    );

    final response = await _repo.fetchDashboard();

    response.when(
      success: (data) {
        state = state.copyWith(
          dashboard: data,
          isLoading: false,
        );
      },
      error: (e) {
        state = state.copyWith(
          isLoading:    false,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
      },
    );
  }

  void setPeriod(String period) => load(period: period);
}

final corporatorDashboardProvider = StateNotifierProvider
    .autoDispose<CorporatorDashboardNotifier,
        CorporatorDashboardState>((ref) {
  return CorporatorDashboardNotifier(
      ref.watch(corporatorDashboardRepositoryProvider));
});