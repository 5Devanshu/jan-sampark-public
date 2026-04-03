import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/exceptions/ops_exception.dart';
import '../models/ops_masters_models.dart';
import '../repositories/ops_masters_repository.dart';

// ─────────────────────────────────────────────
// Generic Masters List State
// Reused for Areas, Wards, Categories, Helplines.
// ─────────────────────────────────────────────

class MastersListState<T> {
  const MastersListState({
    this.items         = const [],
    this.isLoading     = false,
    this.isLoadingMore = false,
    this.hasMore       = true,
    this.currentPage   = 1,
    this.total         = 0,
    this.searchQuery   = '',
    this.errorMessage  = '',
  });

  final List<T> items;
  final bool    isLoading;
  final bool    isLoadingMore;
  final bool    hasMore;
  final int     currentPage;
  final int     total;
  final String  searchQuery;
  final String  errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isEmpty  =>
      !isLoading && items.isEmpty && !hasError;

  MastersListState<T> copyWith({
    List<T>? items,
    bool?    isLoading,
    bool?    isLoadingMore,
    bool?    hasMore,
    int?     currentPage,
    int?     total,
    String?  searchQuery,
    String?  errorMessage,
  }) {
    return MastersListState<T>(
      items:         items         ?? this.items,
      isLoading:     isLoading     ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore:       hasMore       ?? this.hasMore,
      currentPage:   currentPage   ?? this.currentPage,
      total:         total         ?? this.total,
      searchQuery:   searchQuery   ?? this.searchQuery,
      errorMessage:  errorMessage  ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// Generic action state (create / update / delete)
// ─────────────────────────────────────────────

class MasterActionState {
  const MasterActionState({
    this.isLoading    = false,
    this.isSuccess    = false,
    this.errorMessage = '',
  });

  final bool   isLoading;
  final bool   isSuccess;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;

  MasterActionState copyWith({
    bool?   isLoading,
    bool?   isSuccess,
    String? errorMessage,
  }) {
    return MasterActionState(
      isLoading:    isLoading    ?? this.isLoading,
      isSuccess:    isSuccess    ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

String _mapError(dynamic e) =>
    e is OpsException ? e.message : e.toString();

// ═════════════════════════════════════════════
// AREAS
// ═════════════════════════════════════════════

class OpsAreaListNotifier
    extends StateNotifier<MastersListState<OpsArea>> {
  OpsAreaListNotifier(this._repo)
      : super(const MastersListState()) {
    load();
  }

  final OpsMastersRepository _repo;

  Future<void> load({String? search}) async {
    final q = search ?? state.searchQuery;
    state = state.copyWith(
      isLoading:    true,
      errorMessage: '',
      currentPage:  1,
      searchQuery:  q,
    );

    final response = await _repo.fetchAreas(
        page: 1, search: q);

    response.when(
      success: (data) => state = state.copyWith(
        items:       data.data,
        isLoading:   false,
        hasMore:     data.hasMore,
        currentPage: 1,
        total:       data.total,
      ),
      error: (e) => state = state.copyWith(
        isLoading:    false,
        errorMessage: _mapError(e),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    final response = await _repo.fetchAreas(
      page:   nextPage,
      search: state.searchQuery,
    );

    response.when(
      success: (data) => state = state.copyWith(
        items:         [...state.items, ...data.data],
        isLoadingMore: false,
        hasMore:       data.hasMore,
        currentPage:   nextPage,
      ),
      error: (_) =>
          state = state.copyWith(isLoadingMore: false),
    );
  }

  void search(String q) => load(search: q);

  /// Optimistic toggle — reflects immediately in list.
  void toggleActiveOptimistic(String id, bool isActive) {
    state = state.copyWith(
      items: state.items
          .map((a) => a.id == id
              ? a.copyWith(isActive: isActive)
              : a)
          .toList(),
    );
  }

  /// Prepend a newly created area.
  void prepend(OpsArea area) {
    state = state.copyWith(
      items: [area, ...state.items],
      total: state.total + 1,
    );
  }

  /// Remove by id.
  void remove(String id) {
    state = state.copyWith(
      items: state.items
          .where((a) => a.id != id)
          .toList(),
      total: (state.total - 1).clamp(0, 9999),
    );
  }

  /// Replace updated item in list.
  void replace(OpsArea updated) {
    state = state.copyWith(
      items: state.items
          .map((a) => a.id == updated.id ? updated : a)
          .toList(),
    );
  }
}

final opsAreaListProvider = StateNotifierProvider
    .autoDispose<OpsAreaListNotifier,
        MastersListState<OpsArea>>((ref) {
  return OpsAreaListNotifier(
      ref.watch(opsMastersRepositoryProvider));
});

class OpsAreaActionNotifier
    extends StateNotifier<MasterActionState> {
  OpsAreaActionNotifier(this._repo)
      : super(const MasterActionState());

  final OpsMastersRepository _repo;

  Future<OpsArea?> create({
    required String areaName,
    required String areaCode,
    String? description,
  }) async {
    state = state.copyWith(
        isLoading: true, errorMessage: '', isSuccess: false);
    final response = await _repo.createArea(
      areaName:    areaName,
      areaCode:    areaCode,
      description: description,
    );
    return response.when(
      success: (data) {
        state = state.copyWith(
            isLoading: false, isSuccess: true);
        return data;
      },
      error: (e) {
        state = state.copyWith(
            isLoading: false, errorMessage: _mapError(e));
        return null;
      },
    );
  }

  Future<OpsArea?> update(
    String id, {
    String? areaName,
    String? areaCode,
    String? description,
    bool?   isActive,
  }) async {
    state = state.copyWith(
        isLoading: true, errorMessage: '', isSuccess: false);
    final response = await _repo.updateArea(
      id,
      areaName:    areaName,
      areaCode:    areaCode,
      description: description,
      isActive:    isActive,
    );
    return response.when(
      success: (data) {
        state = state.copyWith(
            isLoading: false, isSuccess: true);
        return data;
      },
      error: (e) {
        state = state.copyWith(
            isLoading: false, errorMessage: _mapError(e));
        return null;
      },
    );
  }

  Future<bool> delete(String id) async {
    state = state.copyWith(
        isLoading: true, errorMessage: '', isSuccess: false);
    final response = await _repo.deleteArea(id);
    return response.when(
      success: (_) {
        state = state.copyWith(
            isLoading: false, isSuccess: true);
        return true;
      },
      error: (e) {
        state = state.copyWith(
            isLoading: false, errorMessage: _mapError(e));
        return false;
      },
    );
  }

  void reset() => state = const MasterActionState();
}

final opsAreaActionProvider = StateNotifierProvider
    .autoDispose<OpsAreaActionNotifier, MasterActionState>(
        (ref) {
  return OpsAreaActionNotifier(
      ref.watch(opsMastersRepositoryProvider));
});

// ═════════════════════════════════════════════
// WARDS
// ═════════════════════════════════════════════

class OpsWardListNotifier
    extends StateNotifier<MastersListState<OpsWard>> {
  OpsWardListNotifier(this._repo)
      : super(const MastersListState()) {
    load();
  }

  final OpsMastersRepository _repo;
  String? _areaFilter;

  Future<void> load({String? search, String? areaId}) async {
    final q  = search ?? state.searchQuery;
    _areaFilter = areaId ?? _areaFilter;
    state = state.copyWith(
      isLoading:    true,
      errorMessage: '',
      currentPage:  1,
      searchQuery:  q,
    );

    final response = await _repo.fetchWards(
      page:   1,
      search: q,
      areaId: _areaFilter,
    );

    response.when(
      success: (data) => state = state.copyWith(
        items:       data.data,
        isLoading:   false,
        hasMore:     data.hasMore,
        currentPage: 1,
        total:       data.total,
      ),
      error: (e) => state = state.copyWith(
        isLoading:    false,
        errorMessage: _mapError(e),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    final response = await _repo.fetchWards(
      page:   nextPage,
      search: state.searchQuery,
      areaId: _areaFilter,
    );

    response.when(
      success: (data) => state = state.copyWith(
        items:         [...state.items, ...data.data],
        isLoadingMore: false,
        hasMore:       data.hasMore,
        currentPage:   nextPage,
      ),
      error: (_) =>
          state = state.copyWith(isLoadingMore: false),
    );
  }

  void search(String q) => load(search: q);
  void filterByArea(String? areaId) =>
      load(areaId: areaId);

  void toggleActiveOptimistic(String id, bool isActive) {
    state = state.copyWith(
      items: state.items
          .map((w) => w.id == id
              ? w.copyWith(isActive: isActive)
              : w)
          .toList(),
    );
  }

  void prepend(OpsWard ward) {
    state = state.copyWith(
      items: [ward, ...state.items],
      total: state.total + 1,
    );
  }

  void remove(String id) {
    state = state.copyWith(
      items: state.items
          .where((w) => w.id != id)
          .toList(),
      total: (state.total - 1).clamp(0, 9999),
    );
  }

  void replace(OpsWard updated) {
    state = state.copyWith(
      items: state.items
          .map((w) => w.id == updated.id ? updated : w)
          .toList(),
    );
  }
}

final opsWardListProvider = StateNotifierProvider
    .autoDispose<OpsWardListNotifier,
        MastersListState<OpsWard>>((ref) {
  return OpsWardListNotifier(
      ref.watch(opsMastersRepositoryProvider));
});

class OpsWardActionNotifier
    extends StateNotifier<MasterActionState> {
  OpsWardActionNotifier(this._repo)
      : super(const MasterActionState());

  final OpsMastersRepository _repo;

  Future<OpsWard?> create({
    required String wardName,
    required String wardCode,
    required String areaId,
    String? description,
  }) async {
    state = state.copyWith(
        isLoading: true, errorMessage: '', isSuccess: false);
    final response = await _repo.createWard(
      wardName:    wardName,
      wardCode:    wardCode,
      areaId:      areaId,
      description: description,
    );
    return response.when(
      success: (data) {
        state = state.copyWith(
            isLoading: false, isSuccess: true);
        return data;
      },
      error: (e) {
        state = state.copyWith(
            isLoading: false, errorMessage: _mapError(e));
        return null;
      },
    );
  }

  Future<OpsWard?> update(
    String id, {
    String? wardName,
    String? wardCode,
    String? description,
    bool?   isActive,
  }) async {
    state = state.copyWith(
        isLoading: true, errorMessage: '', isSuccess: false);
    final response = await _repo.updateWard(
      id,
      wardName:    wardName,
      wardCode:    wardCode,
      description: description,
      isActive:    isActive,
    );
    return response.when(
      success: (data) {
        state = state.copyWith(
            isLoading: false, isSuccess: true);
        return data;
      },
      error: (e) {
        state = state.copyWith(
            isLoading: false, errorMessage: _mapError(e));
        return null;
      },
    );
  }

  Future<bool> delete(String id) async {
    state = state.copyWith(
        isLoading: true, errorMessage: '', isSuccess: false);
    final response = await _repo.deleteWard(id);
    return response.when(
      success: (_) {
        state = state.copyWith(
            isLoading: false, isSuccess: true);
        return true;
      },
      error: (e) {
        state = state.copyWith(
            isLoading: false, errorMessage: _mapError(e));
        return false;
      },
    );
  }

  void reset() => state = const MasterActionState();
}

final opsWardActionProvider = StateNotifierProvider
    .autoDispose<OpsWardActionNotifier, MasterActionState>(
        (ref) {
  return OpsWardActionNotifier(
      ref.watch(opsMastersRepositoryProvider));
});

// ═════════════════════════════════════════════
// CATEGORIES
// ═════════════════════════════════════════════

class OpsCategoryListNotifier
    extends StateNotifier<MastersListState<OpsCategory>> {
  OpsCategoryListNotifier(this._repo)
      : super(const MastersListState()) {
    load();
  }

  final OpsMastersRepository _repo;

  Future<void> load({String? search}) async {
    final q = search ?? state.searchQuery;
    state = state.copyWith(
      isLoading:    true,
      errorMessage: '',
      currentPage:  1,
      searchQuery:  q,
    );

    final response = await _repo.fetchCategories(
        page: 1, search: q);

    response.when(
      success: (data) => state = state.copyWith(
        items:       data.data,
        isLoading:   false,
        hasMore:     data.hasMore,
        currentPage: 1,
        total:       data.total,
      ),
      error: (e) => state = state.copyWith(
        isLoading:    false,
        errorMessage: _mapError(e),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    final response = await _repo.fetchCategories(
      page:   nextPage,
      search: state.searchQuery,
    );

    response.when(
      success: (data) => state = state.copyWith(
        items:         [...state.items, ...data.data],
        isLoadingMore: false,
        hasMore:       data.hasMore,
        currentPage:   nextPage,
      ),
      error: (_) =>
          state = state.copyWith(isLoadingMore: false),
    );
  }

  void search(String q) => load(search: q);

  void toggleActiveOptimistic(String id, bool isActive) {
    state = state.copyWith(
      items: state.items
          .map((c) => c.id == id
              ? c.copyWith(isActive: isActive)
              : c)
          .toList(),
    );
  }

  void prepend(OpsCategory category) {
    state = state.copyWith(
      items: [category, ...state.items],
      total: state.total + 1,
    );
  }

  void remove(String id) {
    state = state.copyWith(
      items: state.items
          .where((c) => c.id != id)
          .toList(),
      total: (state.total - 1).clamp(0, 9999),
    );
  }

  void replace(OpsCategory updated) {
    state = state.copyWith(
      items: state.items
          .map((c) => c.id == updated.id ? updated : c)
          .toList(),
    );
  }
}

final opsCategoryListProvider = StateNotifierProvider
    .autoDispose<OpsCategoryListNotifier,
        MastersListState<OpsCategory>>((ref) {
  return OpsCategoryListNotifier(
      ref.watch(opsMastersRepositoryProvider));
});

class OpsCategoryActionNotifier
    extends StateNotifier<MasterActionState> {
  OpsCategoryActionNotifier(this._repo)
      : super(const MasterActionState());

  final OpsMastersRepository _repo;

  Future<OpsCategory?> create({
    required String name,
    required String description,
    String? iconName,
    int     sortOrder = 0,
  }) async {
    state = state.copyWith(
        isLoading: true, errorMessage: '', isSuccess: false);
    final response = await _repo.createCategory(
      name:        name,
      description: description,
      iconName:    iconName,
      sortOrder:   sortOrder,
    );
    return response.when(
      success: (data) {
        state = state.copyWith(
            isLoading: false, isSuccess: true);
        return data;
      },
      error: (e) {
        state = state.copyWith(
            isLoading: false, errorMessage: _mapError(e));
        return null;
      },
    );
  }

  Future<OpsCategory?> update(
    String id, {
    String? name,
    String? description,
    String? iconName,
    int?    sortOrder,
    bool?   isActive,
  }) async {
    state = state.copyWith(
        isLoading: true, errorMessage: '', isSuccess: false);
    final response = await _repo.updateCategory(
      id,
      name:        name,
      description: description,
      iconName:    iconName,
      sortOrder:   sortOrder,
      isActive:    isActive,
    );
    return response.when(
      success: (data) {
        state = state.copyWith(
            isLoading: false, isSuccess: true);
        return data;
      },
      error: (e) {
        state = state.copyWith(
            isLoading: false, errorMessage: _mapError(e));
        return null;
      },
    );
  }

  Future<bool> delete(String id) async {
    state = state.copyWith(
        isLoading: true, errorMessage: '', isSuccess: false);
    final response = await _repo.deleteCategory(id);
    return response.when(
      success: (_) {
        state = state.copyWith(
            isLoading: false, isSuccess: true);
        return true;
      },
      error: (e) {
        state = state.copyWith(
            isLoading: false, errorMessage: _mapError(e));
        return false;
      },
    );
  }

  void reset() => state = const MasterActionState();
}

final opsCategoryActionProvider = StateNotifierProvider
    .autoDispose<OpsCategoryActionNotifier, MasterActionState>(
        (ref) {
  return OpsCategoryActionNotifier(
      ref.watch(opsMastersRepositoryProvider));
});

// ═════════════════════════════════════════════
// HELPLINES
// ═════════════════════════════════════════════

class OpsHelplineListNotifier
    extends StateNotifier<MastersListState<OpsHelpline>> {
  OpsHelplineListNotifier(this._repo)
      : super(const MastersListState()) {
    load();
  }

  final OpsMastersRepository _repo;
  String? _categoryFilter;
  bool?   _isSystemFilter;

  Future<void> load({
    String? search,
    String? category,
    bool?   isSystem,
  }) async {
    final q = search ?? state.searchQuery;
    _categoryFilter = category ?? _categoryFilter;
    _isSystemFilter = isSystem ?? _isSystemFilter;

    state = state.copyWith(
      isLoading:    true,
      errorMessage: '',
      currentPage:  1,
      searchQuery:  q,
    );

    final response = await _repo.fetchHelplines(
      page:     1,
      search:   q,
      category: _categoryFilter,
      isSystem: _isSystemFilter,
    );

    response.when(
      success: (data) => state = state.copyWith(
        items:       data.data,
        isLoading:   false,
        hasMore:     data.hasMore,
        currentPage: 1,
        total:       data.total,
      ),
      error: (e) => state = state.copyWith(
        isLoading:    false,
        errorMessage: _mapError(e),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    final response = await _repo.fetchHelplines(
      page:     nextPage,
      search:   state.searchQuery,
      category: _categoryFilter,
      isSystem: _isSystemFilter,
    );

    response.when(
      success: (data) => state = state.copyWith(
        items:         [...state.items, ...data.data],
        isLoadingMore: false,
        hasMore:       data.hasMore,
        currentPage:   nextPage,
      ),
      error: (_) =>
          state = state.copyWith(isLoadingMore: false),
    );
  }

  void search(String q) => load(search: q);
  void filterByCategory(String? cat) =>
      load(category: cat);
  void filterBySystem(bool? isSystem) =>
      load(isSystem: isSystem);

  void toggleActiveOptimistic(String id, bool isActive) {
    state = state.copyWith(
      items: state.items
          .map((h) => h.id == id
              ? h.copyWith(isActive: isActive)
              : h)
          .toList(),
    );
  }

  void prepend(OpsHelpline helpline) {
    state = state.copyWith(
      items: [helpline, ...state.items],
      total: state.total + 1,
    );
  }

  void remove(String id) {
    state = state.copyWith(
      items: state.items
          .where((h) => h.id != id)
          .toList(),
      total: (state.total - 1).clamp(0, 9999),
    );
  }

  void replace(OpsHelpline updated) {
    state = state.copyWith(
      items: state.items
          .map((h) => h.id == updated.id ? updated : h)
          .toList(),
    );
  }
}

final opsHelplineListProvider = StateNotifierProvider
    .autoDispose<OpsHelplineListNotifier,
        MastersListState<OpsHelpline>>((ref) {
  return OpsHelplineListNotifier(
      ref.watch(opsMastersRepositoryProvider));
});

class OpsHelplineActionNotifier
    extends StateNotifier<MasterActionState> {
  OpsHelplineActionNotifier(this._repo)
      : super(const MasterActionState());

  final OpsMastersRepository _repo;

  Future<OpsHelpline?> create({
    required String name,
    required String number,
    required String category,
    String? description,
    bool    isSystem = true,
  }) async {
    state = state.copyWith(
        isLoading: true, errorMessage: '', isSuccess: false);
    final response = await _repo.createHelpline(
      name:        name,
      number:      number,
      category:    category,
      description: description,
      isSystem:    isSystem,
    );
    return response.when(
      success: (data) {
        state = state.copyWith(
            isLoading: false, isSuccess: true);
        return data;
      },
      error: (e) {
        state = state.copyWith(
            isLoading: false, errorMessage: _mapError(e));
        return null;
      },
    );
  }

  Future<OpsHelpline?> update(
    String id, {
    String? name,
    String? number,
    String? category,
    String? description,
    bool?   isActive,
  }) async {
    state = state.copyWith(
        isLoading: true, errorMessage: '', isSuccess: false);
    final response = await _repo.updateHelpline(
      id,
      name:        name,
      number:      number,
      category:    category,
      description: description,
      isActive:    isActive,
    );
    return response.when(
      success: (data) {
        state = state.copyWith(
            isLoading: false, isSuccess: true);
        return data;
      },
      error: (e) {
        state = state.copyWith(
            isLoading: false, errorMessage: _mapError(e));
        return null;
      },
    );
  }

  Future<bool> delete(String id) async {
    state = state.copyWith(
        isLoading: true, errorMessage: '', isSuccess: false);
    final response = await _repo.deleteHelpline(id);
    return response.when(
      success: (_) {
        state = state.copyWith(
            isLoading: false, isSuccess: true);
        return true;
      },
      error: (e) {
        state = state.copyWith(
            isLoading: false, errorMessage: _mapError(e));
        return false;
      },
    );
  }

  void reset() => state = const MasterActionState();
}

final opsHelplineActionProvider = StateNotifierProvider
    .autoDispose<OpsHelplineActionNotifier,
        MasterActionState>((ref) {
  return OpsHelplineActionNotifier(
      ref.watch(opsMastersRepositoryProvider));
});