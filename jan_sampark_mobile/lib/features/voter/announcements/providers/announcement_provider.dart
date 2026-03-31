import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../models/announcement_models.dart';
import '../repositories/announcement_repository.dart';

// ─────────────────────────────────────────────
// List State
// ─────────────────────────────────────────────

class AnnouncementListState {
  const AnnouncementListState({
    this.announcements = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.selectedCategory = 'all',
    this.errorMessage = '',
  });

  final List<AnnouncementModel> announcements;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String selectedCategory;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isEmpty => !isLoading && announcements.isEmpty && !hasError;

  AnnouncementListState copyWith({
    List<AnnouncementModel>? announcements,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? selectedCategory,
    String? errorMessage,
  }) {
    return AnnouncementListState(
      announcements: announcements ?? this.announcements,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class AnnouncementListNotifier extends StateNotifier<AnnouncementListState> {
  AnnouncementListNotifier(this._repo) : super(const AnnouncementListState()) {
    load();
  }

  final AnnouncementRepository _repo;

  Future<void> load({String? category}) async {
    final cat = category ?? state.selectedCategory;
    state = state.copyWith(
      isLoading: true,
      errorMessage: '',
      currentPage: 1,
      selectedCategory: cat,
    );

    final response = await _repo.fetchAnnouncements(
      page: 1,
      category: cat == 'all' ? null : cat,
    );

    response.when(
      success: (data) {
        state = state.copyWith(
          announcements: data.data,
          isLoading: false,
          hasMore: data.hasMore,
          currentPage: 1,
        );
      },
      error: (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    final response = await _repo.fetchAnnouncements(
      page: nextPage,
      category: state.selectedCategory == 'all' ? null : state.selectedCategory,
    );

    response.when(
      success: (data) {
        state = state.copyWith(
          announcements: [...state.announcements, ...data.data],
          isLoadingMore: false,
          hasMore: data.hasMore,
          currentPage: nextPage,
        );
      },
      error: (_) => state = state.copyWith(isLoadingMore: false),
    );
  }

  void setCategory(String category) => load(category: category);

  /// Optimistically mark an announcement as acknowledged in the list.
  void markAcknowledged(String id) {
    final updated = state.announcements.map((a) {
      if (a.id == id) {
        return AnnouncementModel(
          id: a.id,
          category: a.category,
          title: a.title,
          contentPreview: a.contentPreview,
          content: a.content,
          status: a.status,
          createdByName: a.createdByName,
          createdByRole: a.createdByRole,
          publishedAt: a.publishedAt,
          viewCount: a.viewCount,
          acknowledgementCount: a.acknowledgementCount + 1,
          isAcknowledged: true,
          createdAt: a.createdAt,
        );
      }
      return a;
    }).toList();
    state = state.copyWith(announcements: updated);
  }
}

final announcementListProvider =
    StateNotifierProvider.autoDispose<
      AnnouncementListNotifier,
      AnnouncementListState
    >((ref) {
      return AnnouncementListNotifier(
        ref.watch(announcementRepositoryProvider),
      );
    });

// ─────────────────────────────────────────────
// Detail Provider
// ─────────────────────────────────────────────

final announcementDetailProvider = FutureProvider.autoDispose
    .family<AnnouncementModel, String>((ref, id) async {
      final repo = ref.watch(announcementRepositoryProvider);
      final response = await repo.fetchDetail(id);
      return response.when(success: (data) => data, error: (e) => throw e);
    });

// ─────────────────────────────────────────────
// Acknowledge State
// ─────────────────────────────────────────────

class AcknowledgeNotifier extends StateNotifier<bool> {
  AcknowledgeNotifier(this._repo) : super(false);
  final AnnouncementRepository _repo;

  Future<bool> acknowledge(String id) async {
    state = true; // loading
    final response = await _repo.acknowledge(id);
    state = false;
    return response.isSuccess;
  }
}

final acknowledgeProvider =
    StateNotifierProvider.autoDispose<AcknowledgeNotifier, bool>((ref) {
      return AcknowledgeNotifier(ref.watch(announcementRepositoryProvider));
    });
