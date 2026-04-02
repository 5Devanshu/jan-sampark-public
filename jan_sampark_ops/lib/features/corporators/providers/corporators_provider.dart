import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/ops_dio_client.dart';
import '../../../core/constants/ops_constants.dart';
import '../models/corporator_model.dart';

// ─────────────────────────────────────────────
// List State
// ─────────────────────────────────────────────

class CorporatorsState {
  const CorporatorsState({
    this.corporators  = const [],
    this.isLoading    = false,
    this.isLoadingMore = false,
    this.hasMore      = true,
    this.currentPage  = 1,
    this.searchQuery  = '',
    this.errorMessage = '',
  });

  final List<CorporatorListItem> corporators;
  final bool   isLoading;
  final bool   isLoadingMore;
  final bool   hasMore;
  final int    currentPage;
  final String searchQuery;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isEmpty  =>
      !isLoading && corporators.isEmpty && !hasError;

  CorporatorsState copyWith({
    List<CorporatorListItem>? corporators,
    bool?   isLoading,
    bool?   isLoadingMore,
    bool?   hasMore,
    int?    currentPage,
    String? searchQuery,
    String? errorMessage,
  }) {
    return CorporatorsState(
      corporators:   corporators   ?? this.corporators,
      isLoading:     isLoading     ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore:       hasMore       ?? this.hasMore,
      currentPage:   currentPage   ?? this.currentPage,
      searchQuery:   searchQuery   ?? this.searchQuery,
      errorMessage:  errorMessage  ?? this.errorMessage,
    );
  }
}

class CorporatorsNotifier extends StateNotifier<CorporatorsState> {
  CorporatorsNotifier(this._ref)
      : super(const CorporatorsState()) {
    load();
  }

  final Ref _ref;

  Future<void> load({String? search}) async {
    final q = search ?? state.searchQuery;
    state = state.copyWith(
      isLoading:    true,
      errorMessage: '',
      currentPage:  1,
      searchQuery:  q,
    );

    try {
      final dio = _ref.read(opsDioProvider);
      final res = await dio.get(
        OpsConstants.endpointCorporators,
        queryParameters: {
          'page':      1,
          'page_size': OpsConstants.defaultPageSize,
          if (q.isNotEmpty) 'search': q,
        },
      );
      final data = CorporatorListResponse.fromJson(
          res.data as Map<String, dynamic>);
      state = state.copyWith(
        corporators: data.data,
        isLoading:   false,
        hasMore:     data.hasMore,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading:    false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    try {
      final dio = _ref.read(opsDioProvider);
      final res = await dio.get(
        OpsConstants.endpointCorporators,
        queryParameters: {
          'page':      nextPage,
          'page_size': OpsConstants.defaultPageSize,
          if (state.searchQuery.isNotEmpty)
            'search': state.searchQuery,
        },
      );
      final data = CorporatorListResponse.fromJson(
          res.data as Map<String, dynamic>);
      state = state.copyWith(
        corporators:   [...state.corporators, ...data.data],
        isLoadingMore: false,
        hasMore:       data.hasMore,
        currentPage:   nextPage,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void search(String q) => load(search: q);
}

final corporatorsProvider = StateNotifierProvider
    .autoDispose<CorporatorsNotifier, CorporatorsState>((ref) {
  return CorporatorsNotifier(ref);
});

// ─────────────────────────────────────────────
// Detail
// ─────────────────────────────────────────────

final corporatorDetailProvider = FutureProvider.autoDispose
    .family<CorporatorDetail, String>((ref, id) async {
  final dio = ref.watch(opsDioProvider);
  final res = await dio.get(
      '${OpsConstants.endpointCorporators}/$id');
  return CorporatorDetail.fromJson(
      res.data as Map<String, dynamic>);
});

// ─────────────────────────────────────────────
// Area + Ward options for create form
// ─────────────────────────────────────────────

final opsAreasProvider =
    FutureProvider.autoDispose<List<OpsAreaOption>>((ref) async {
  final dio = ref.watch(opsDioProvider);
  final res = await dio.get(OpsConstants.endpointAreas);
  final data = res.data as Map<String, dynamic>;
  return (data['data'] as List<dynamic>? ?? [])
      .map((e) =>
          OpsAreaOption.fromJson(e as Map<String, dynamic>))
      .toList();
});

final opsWardsForAreaProvider = FutureProvider.autoDispose
    .family<List<OpsWardOption>, String>((ref, areaId) async {
  if (areaId.isEmpty) return [];
  final dio = ref.watch(opsDioProvider);
  final res = await dio.get(
    OpsConstants.endpointWards,
    queryParameters: {'area_id': areaId},
  );
  final data = res.data as Map<String, dynamic>;
  return (data['data'] as List<dynamic>? ?? [])
      .map((e) =>
          OpsWardOption.fromJson(e as Map<String, dynamic>))
      .toList();
});