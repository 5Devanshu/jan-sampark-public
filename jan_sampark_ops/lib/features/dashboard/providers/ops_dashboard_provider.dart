import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ops_dashboard_models.dart';
import '../repositories/ops_dashboard_repository.dart';

// ─────────────────────────────────────────────
// Period selection
// ─────────────────────────────────────────────

const opsPeriodOptions = {
  '7d':  '7 Days',
  '30d': '30 Days',
  '90d': '90 Days',
};

final opsDashboardPeriodProvider =
    StateProvider<String>((ref) => '30d');

// ─────────────────────────────────────────────
// Dashboard state
// ─────────────────────────────────────────────

class OpsDashboardState {
  const OpsDashboardState({
    this.data,
    this.isLoading    = false,
    this.errorMessage = '',
  });

  final OpsDashboardData? data;
  final bool              isLoading;
  final String            errorMessage;

  bool get hasData  => data != null;
  bool get hasError => errorMessage.isNotEmpty;

  OpsDashboardState copyWith({
    OpsDashboardData? data,
    bool?             isLoading,
    String?           errorMessage,
  }) {
    return OpsDashboardState(
      data:         data         ?? this.data,
      isLoading:    isLoading    ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class OpsDashboardNotifier
    extends StateNotifier<OpsDashboardState> {
  OpsDashboardNotifier(this._repo)
      : super(const OpsDashboardState()) {
    load();
  }

  final OpsDashboardRepository _repo;
  String _period = '30d';

  Future<void> load({String? period}) async {
    _period = period ?? _period;
    state = state.copyWith(
      isLoading:    true,
      errorMessage: '',
    );

    final response =
        await _repo.fetchDashboard(period: _period);

    response.when(
      success: (data) {
        state = state.copyWith(
          data:      data,
          isLoading: false,
        );
      },
      error: (e) {
        state = state.copyWith(
          isLoading:    false,
          errorMessage: e.message,
        );
      },
    );
  }

  void setPeriod(String period) => load(period: period);
}

final opsDashboardProvider = StateNotifierProvider
    .autoDispose<OpsDashboardNotifier, OpsDashboardState>((ref) {
  final notifier = OpsDashboardNotifier(
      ref.watch(opsDashboardRepositoryProvider));

  // Reload when period changes
  ref.listen<String>(opsDashboardPeriodProvider, (_, period) {
    notifier.setPeriod(period);
  });

  return notifier;
});