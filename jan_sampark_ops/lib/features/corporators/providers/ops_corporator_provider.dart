import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/ops_api_response.dart';
import '../models/ops_corporator_models.dart';
import '../repositories/ops_corporator_repository.dart';

// ─────────────────────────────────────────────
// List Filter
// ─────────────────────────────────────────────

class OpsCorporatorFilter {
  const OpsCorporatorFilter({
    this.search,
    this.areaId,
    this.isActive,
  });

  final String? search;
  final String? areaId;
  final bool?   isActive;

  bool get hasFilters =>
      (search != null && search!.isNotEmpty) ||
      areaId   != null ||
      isActive  != null;

  OpsCorporatorFilter copyWith({
    String? search,
    String? areaId,
    bool?   isActive,
    bool    clearActive = false,
    bool    clearArea   = false,
  }) {
    return OpsCorporatorFilter(
      search:   search   ?? this.search,
      areaId:   clearArea ? null : (areaId ?? this.areaId),
      isActive: clearActive ? null : (isActive ?? this.isActive),
    );
  }

  OpsCorporatorFilter cleared() =>
      const OpsCorporatorFilter();
}

// ─────────────────────────────────────────────
// List State
// ─────────────────────────────────────────────

class OpsCorporatorListState {
  const OpsCorporatorListState({
    this.corporators   = const [],
    this.isLoading     = false,
    this.isLoadingMore = false,
    this.hasMore       = true,
    this.currentPage   = 1,
    this.total         = 0,
    this.filter        = const OpsCorporatorFilter(),
    this.errorMessage  = '',
  });

  final List<OpsCorporatorItem> corporators;
  final bool                    isLoading;
  final bool                    isLoadingMore;
  final bool                    hasMore;
  final int                     currentPage;
  final int                     total;
  final OpsCorporatorFilter     filter;
  final String                  errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isEmpty  =>
      !isLoading && corporators.isEmpty && !hasError;

  OpsCorporatorListState copyWith({
    List<OpsCorporatorItem>? corporators,
    bool?                    isLoading,
    bool?                    isLoadingMore,
    bool?                    hasMore,
    int?                     currentPage,
    int?                     total,
    OpsCorporatorFilter?     filter,
    String?                  errorMessage,
  }) {
    return OpsCorporatorListState(
      corporators:   corporators   ?? this.corporators,
      isLoading:     isLoading     ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore:       hasMore       ?? this.hasMore,
      currentPage:   currentPage   ?? this.currentPage,
      total:         total         ?? this.total,
      filter:        filter        ?? this.filter,
      errorMessage:  errorMessage  ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// List Notifier
// ─────────────────────────────────────────────

class OpsCorporatorListNotifier
    extends StateNotifier<OpsCorporatorListState> {
  OpsCorporatorListNotifier(this._repo)
      : super(const OpsCorporatorListState()) {
    load();
  }

  final OpsCorporatorRepository _repo;

  Future<void> load({OpsCorporatorFilter? filter}) async {
    final f = filter ?? state.filter;
    state = state.copyWith(
      isLoading:    true,
      errorMessage: '',
      currentPage:  1,
      filter:       f,
    );

    final response = await _repo.fetchCorporators(
      page:     1,
      search:   f.search,
      areaId:   f.areaId,
      isActive: f.isActive,
    );

    response.when(
      success: (data) => state = state.copyWith(
        corporators:  data.data,
        isLoading:    false,
        hasMore:      data.hasMore,
        currentPage:  1,
        total:        data.total,
      ),
      error: (e) => state = state.copyWith(
        isLoading:    false,
        errorMessage: e.message,
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;
    final f = state.filter;

    final response = await _repo.fetchCorporators(
      page:     nextPage,
      search:   f.search,
      areaId:   f.areaId,
      isActive: f.isActive,
    );

    response.when(
      success: (data) => state = state.copyWith(
        corporators:   [...state.corporators, ...data.data],
        isLoadingMore: false,
        hasMore:       data.hasMore,
        currentPage:   nextPage,
      ),
      error: (_) =>
          state = state.copyWith(isLoadingMore: false),
    );
  }

  void search(String q) {
    load(filter: state.filter.copyWith(search: q));
  }

  void applyFilter(OpsCorporatorFilter filter) =>
      load(filter: filter);

  void clearFilters() =>
      load(filter: const OpsCorporatorFilter());

  /// Optimistically update a single corporator's active state
  /// so the list reflects the change before the next full reload.
  void updateActiveState(String id, bool isActive) {
    final updated = state.corporators.map((c) {
      return c.id == id
          ? OpsCorporatorItem(
              id:                c.id,
              fullName:          c.fullName,
              mobile:            c.mobile,
              isActive:          isActive,
              areaId:            c.areaId,
              areaName:          c.areaName,
              areaCode:          c.areaCode,
              wardsCount:        c.wardsCount,
              createdAt:         c.createdAt,
              leadersCount:      c.leadersCount,
              complaintsTotal:   c.complaintsTotal,
              complaintsResolved: c.complaintsResolved,
              resolutionRate:    c.resolutionRate,
            )
          : c;
    }).toList();
    state = state.copyWith(corporators: updated);
  }
}

final opsCorporatorListProvider = StateNotifierProvider
    .autoDispose<OpsCorporatorListNotifier,
        OpsCorporatorListState>((ref) {
  return OpsCorporatorListNotifier(
      ref.watch(opsCorporatorRepositoryProvider));
});

// ─────────────────────────────────────────────
// Detail
// ─────────────────────────────────────────────

final opsCorporatorDetailProvider = FutureProvider
    .autoDispose
    .family<OpsCorporatorDetail, String>((ref, id) async {
  final repo     = ref.watch(opsCorporatorRepositoryProvider);
  final response = await repo.fetchDetail(id);
  return response.when(
    success: (data) => data,
    error:   (e)    => throw e,
  );
});

// ─────────────────────────────────────────────
// Area options (for create form dropdown)
// ─────────────────────────────────────────────

final opsAreaOptionsProvider =
    FutureProvider.autoDispose<List<OpsAreaOption>>((ref) async {
  final repo     = ref.watch(opsCorporatorRepositoryProvider);
  final response = await repo.fetchAreaOptions();
  return response.when(
    success: (data) => data,
    error:   (e)    => throw e,
  );
});

// ─────────────────────────────────────────────
// Ward options filtered by area (for create form)
// ─────────────────────────────────────────────

final opsWardOptionsProvider = FutureProvider.autoDispose
    .family<List<OpsWardOption>, String>((ref, areaId) async {
  if (areaId.isEmpty) return [];
  final repo     = ref.watch(opsCorporatorRepositoryProvider);
  final response = await repo.fetchWardOptions(areaId);
  return response.when(
    success: (data) => data,
    error:   (e)    => throw e,
  );
});

// ─────────────────────────────────────────────
// Create State
// ─────────────────────────────────────────────

class OpsCreateCorporatorState {
  const OpsCreateCorporatorState({
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

  OpsCreateCorporatorState copyWith({
    bool?   isLoading,
    bool?   isSuccess,
    String? errorMessage,
    String? createdId,
  }) {
    return OpsCreateCorporatorState(
      isLoading:    isLoading    ?? this.isLoading,
      isSuccess:    isSuccess    ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      createdId:    createdId    ?? this.createdId,
    );
  }
}

class OpsCreateCorporatorNotifier
    extends StateNotifier<OpsCreateCorporatorState> {
  OpsCreateCorporatorNotifier(this._repo)
      : super(const OpsCreateCorporatorState());

  final OpsCorporatorRepository _repo;

  Future<bool> create(OpsCreateCorporatorRequest request) async {
    state = state.copyWith(
      isLoading:    true,
      errorMessage: '',
      isSuccess:    false,
    );

    final response = await _repo.create(request);

    return response.when(
      success: (data) {
        final id = data['id'] as String? ?? '';
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          createdId: id,
        );
        return true;
      },
      error: (e) {
        state = state.copyWith(
          isLoading:    false,
          errorMessage: e.message,
        );
        return false;
      },
    );
  }

  void reset() => state = const OpsCreateCorporatorState();
}

final opsCreateCorporatorProvider = StateNotifierProvider
    .autoDispose<OpsCreateCorporatorNotifier,
        OpsCreateCorporatorState>((ref) {
  return OpsCreateCorporatorNotifier(
      ref.watch(opsCorporatorRepositoryProvider));
});

// ─────────────────────────────────────────────
// Action State (toggle active, reset password,
// update wards — all share one notifier per detail screen)
// ─────────────────────────────────────────────

enum OpsCorporatorActionType { none, toggleActive, resetPassword, updateWards }

class OpsCorporatorActionState {
  const OpsCorporatorActionState({
    this.type         = OpsCorporatorActionType.none,
    this.isLoading    = false,
    this.isSuccess    = false,
    this.errorMessage = '',
  });

  final OpsCorporatorActionType type;
  final bool                    isLoading;
  final bool                    isSuccess;
  final String                  errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isIdle   => type == OpsCorporatorActionType.none;

  OpsCorporatorActionState copyWith({
    OpsCorporatorActionType? type,
    bool?                    isLoading,
    bool?                    isSuccess,
    String?                  errorMessage,
  }) {
    return OpsCorporatorActionState(
      type:         type         ?? this.type,
      isLoading:    isLoading    ?? this.isLoading,
      isSuccess:    isSuccess    ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class OpsCorporatorActionNotifier
    extends StateNotifier<OpsCorporatorActionState> {
  OpsCorporatorActionNotifier(this._repo)
      : super(const OpsCorporatorActionState());

  final OpsCorporatorRepository _repo;

  Future<bool> toggleActive(
    String id, {
    required bool isActive,
  }) async {
    state = state.copyWith(
      type:         OpsCorporatorActionType.toggleActive,
      isLoading:    true,
      errorMessage: '',
      isSuccess:    false,
    );

    final response = await _repo.setActive(id, isActive: isActive);
    return _handle(response, OpsCorporatorActionType.toggleActive);
  }

  Future<bool> resetPassword(
    String id, {
    required String newPassword,
  }) async {
    state = state.copyWith(
      type:         OpsCorporatorActionType.resetPassword,
      isLoading:    true,
      errorMessage: '',
      isSuccess:    false,
    );

    final response =
        await _repo.resetPassword(id, newPassword: newPassword);
    return _handle(response, OpsCorporatorActionType.resetPassword);
  }

  Future<bool> updateWards(
    String id, {
    required List<String> wardIds,
  }) async {
    state = state.copyWith(
      type:         OpsCorporatorActionType.updateWards,
      isLoading:    true,
      errorMessage: '',
      isSuccess:    false,
    );

    final response = await _repo.updateWards(id, wardIds: wardIds);
    return _handle(response, OpsCorporatorActionType.updateWards);
  }

  bool _handle(
    OpsApiResponse<Map<String, dynamic>> response,
    OpsCorporatorActionType type,
  ) {
    return response.when(
      success: (_) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          type:      type,
        );
        return true;
      },
      error: (e) {
        state = state.copyWith(
          isLoading:    false,
          errorMessage: e.message,
          type:         type,
        );
        return false;
      },
    );
  }

  void reset() => state = const OpsCorporatorActionState();
}

final opsCorporatorActionProvider = StateNotifierProvider
    .autoDispose<OpsCorporatorActionNotifier,
        OpsCorporatorActionState>((ref) {
  return OpsCorporatorActionNotifier(
      ref.watch(opsCorporatorRepositoryProvider));
});