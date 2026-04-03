import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ops_analytics_models.dart';
import '../repositories/ops_analytics_repository.dart';

// ─────────────────────────────────────────────
// Period provider (shared with dashboard)
// ─────────────────────────────────────────────

final opsAnalyticsPeriodProvider =
    StateProvider<String>((ref) => '30d');

const opsAnalyticsPeriodOptions = {
  '7d':  'Last 7 Days',
  '30d': 'Last 30 Days',
  '90d': 'Last 90 Days',
  '365d': 'Last 12 Months',
};

// ─────────────────────────────────────────────
// Analytics State
// ─────────────────────────────────────────────

class OpsAnalyticsState {
  const OpsAnalyticsState({
    this.data,
    this.isLoading    = false,
    this.errorMessage = '',
  });

  final OpsAnalyticsData? data;
  final bool              isLoading;
  final String            errorMessage;

  bool get hasData  => data != null;
  bool get hasError => errorMessage.isNotEmpty;

  OpsAnalyticsState copyWith({
    OpsAnalyticsData? data,
    bool?             isLoading,
    String?           errorMessage,
  }) {
    return OpsAnalyticsState(
      data:         data         ?? this.data,
      isLoading:    isLoading    ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class OpsAnalyticsNotifier
    extends StateNotifier<OpsAnalyticsState> {
  OpsAnalyticsNotifier(this._repo, this._ref)
      : super(const OpsAnalyticsState()) {
    load();
  }

  final OpsAnalyticsRepository _repo;
  final Ref                    _ref;
  String _period = '30d';

  Future<void> load({String? period}) async {
    _period = period ?? _period;
    state = state.copyWith(
      isLoading:    true,
      errorMessage: '',
    );

    final response =
        await _repo.fetchAnalytics(period: _period);

    response.when(
      success: (data) => state = state.copyWith(
        data:      data,
        isLoading: false,
      ),
      error: (e) => state = state.copyWith(
        isLoading:    false,
        errorMessage: e.message,
      ),
    );
  }

  void setPeriod(String period) {
    _ref.read(opsAnalyticsPeriodProvider.notifier).state =
        period;
    load(period: period);
  }
}

final opsAnalyticsProvider = StateNotifierProvider
    .autoDispose<OpsAnalyticsNotifier,
        OpsAnalyticsState>((ref) {
  final notifier = OpsAnalyticsNotifier(
    ref.watch(opsAnalyticsRepositoryProvider),
    ref,
  );

  ref.listen<String>(opsAnalyticsPeriodProvider,
      (_, period) {
    notifier.load(period: period);
  });

  return notifier;
});

// ─────────────────────────────────────────────
// Sorted area performance for table
// ─────────────────────────────────────────────

enum AreaSortField {
  name, voters, complaints, resolved,
  escalated, resolutionRate, raised,
}

class AreaSortState {
  const AreaSortState({
    this.field     = AreaSortField.resolutionRate,
    this.ascending = false,
  });
  final AreaSortField field;
  final bool          ascending;

  AreaSortState toggle(AreaSortField f) {
    if (field == f) {
      return AreaSortState(field: f, ascending: !ascending);
    }
    return AreaSortState(field: f, ascending: false);
  }
}

final areaSortProvider =
    StateProvider<AreaSortState>((ref) => const AreaSortState());

final sortedAreaPerformanceProvider =
    Provider<List<OpsAreaPerformance>>((ref) {
  final data  = ref.watch(opsAnalyticsProvider).data;
  final sort  = ref.watch(areaSortProvider);
  if (data == null) return [];

  final list = List<OpsAreaPerformance>.from(
      data.areaPerformance);

  list.sort((a, b) {
    int cmp;
    cmp = switch (sort.field) {
      AreaSortField.name           =>
          a.areaName.compareTo(b.areaName),
      AreaSortField.voters         =>
          a.votersTotal.compareTo(b.votersTotal),
      AreaSortField.complaints     =>
          a.complaintsTotal.compareTo(b.complaintsTotal),
      AreaSortField.resolved       =>
          a.complaintsResolved.compareTo(b.complaintsResolved),
      AreaSortField.escalated      =>
          a.complaintsEscalated.compareTo(b.complaintsEscalated),
      AreaSortField.resolutionRate =>
          a.resolutionRate.compareTo(b.resolutionRate),
      AreaSortField.raised         =>
          a.campaignRaised.compareTo(b.campaignRaised),
    };
    return sort.ascending ? cmp : -cmp;
  });

  return list;
});