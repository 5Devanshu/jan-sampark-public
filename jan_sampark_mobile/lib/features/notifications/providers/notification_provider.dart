import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/exceptions/app_exception.dart';
import '../models/notification_models.dart';
import '../repositories/notification_repository.dart';

// ─────────────────────────────────────────────
// Unread Count Provider
// Polled periodically from the bell widget.
// ─────────────────────────────────────────────

final unreadCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final repo     = ref.watch(notificationRepositoryProvider);
  final response = await repo.fetchUnreadCount();
  return response.when(
    success: (count) => count,
    error:   (_)     => 0,
  );
});

// ─────────────────────────────────────────────
// Notification List State
// ─────────────────────────────────────────────

class NotificationListState {
  const NotificationListState({
    this.notifications  = const [],
    this.isLoading      = false,
    this.isLoadingMore  = false,
    this.hasMore        = true,
    this.currentPage    = 1,
    this.unreadCount    = 0,
    this.errorMessage   = '',
    this.isMarkingAll   = false,
  });

  final List<NotificationModel> notifications;
  final bool   isLoading;
  final bool   isLoadingMore;
  final bool   hasMore;
  final int    currentPage;
  final int    unreadCount;
  final String errorMessage;
  final bool   isMarkingAll;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isEmpty  =>
      !isLoading && notifications.isEmpty && !hasError;

  NotificationListState copyWith({
    List<NotificationModel>? notifications,
    bool?   isLoading,
    bool?   isLoadingMore,
    bool?   hasMore,
    int?    currentPage,
    int?    unreadCount,
    String? errorMessage,
    bool?   isMarkingAll,
  }) {
    return NotificationListState(
      notifications:  notifications  ?? this.notifications,
      isLoading:      isLoading      ?? this.isLoading,
      isLoadingMore:  isLoadingMore  ?? this.isLoadingMore,
      hasMore:        hasMore        ?? this.hasMore,
      currentPage:    currentPage    ?? this.currentPage,
      unreadCount:    unreadCount    ?? this.unreadCount,
      errorMessage:   errorMessage   ?? this.errorMessage,
      isMarkingAll:   isMarkingAll   ?? this.isMarkingAll,
    );
  }
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class NotificationListNotifier
    extends StateNotifier<NotificationListState> {
  NotificationListNotifier(this._repo)
      : super(const NotificationListState()) {
    load();
  }

  final NotificationRepository _repo;

  // ── Load ────────────────────────────────────

  Future<void> load() async {
    state = state.copyWith(
      isLoading:    true,
      errorMessage: '',
      currentPage:  1,
    );

    final response = await _repo.fetchNotifications(page: 1);

    response.when(
      success: (data) {
        state = state.copyWith(
          notifications: data.data,
          isLoading:     false,
          hasMore:       data.hasMore,
          currentPage:   1,
          unreadCount:   data.unreadCount,
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

  // ── Load More ────────────────────────────────

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    final response = await _repo.fetchNotifications(
        page: nextPage);

    response.when(
      success: (data) {
        state = state.copyWith(
          notifications: [
            ...state.notifications,
            ...data.data,
          ],
          isLoadingMore: false,
          hasMore:       data.hasMore,
          currentPage:   nextPage,
        );
      },
      error: (_) =>
          state = state.copyWith(isLoadingMore: false),
    );
  }

  // ── Mark single read (optimistic) ────────────

  Future<void> markRead(String notificationId) async {
    // Optimistic update first
    final updated = state.notifications.map((n) {
      if (n.id == notificationId && !n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final wasUnread = state.notifications
        .any((n) => n.id == notificationId && !n.isRead);

    state = state.copyWith(
      notifications: updated,
      unreadCount: wasUnread
          ? (state.unreadCount - 1).clamp(0, 9999)
          : state.unreadCount,
    );

    // Fire API — ignore result since UI is already updated
    await _repo.markRead(notificationId);
  }

  // ── Mark all read ─────────────────────────────

  Future<void> markAllRead() async {
    state = state.copyWith(isMarkingAll: true);

    final response = await _repo.markAllRead();

    response.when(
      success: (_) {
        final updated = state.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        state = state.copyWith(
          notifications: updated,
          unreadCount:   0,
          isMarkingAll:  false,
        );
      },
      error: (_) =>
          state = state.copyWith(isMarkingAll: false),
    );
  }

  // ── Dismiss (delete) ─────────────────────────

  Future<void> dismiss(String notificationId) async {
    final wasUnread = state.notifications
        .any((n) => n.id == notificationId && !n.isRead);

    // Optimistic remove
    state = state.copyWith(
      notifications: state.notifications
          .where((n) => n.id != notificationId)
          .toList(),
      unreadCount: wasUnread
          ? (state.unreadCount - 1).clamp(0, 9999)
          : state.unreadCount,
    );

    await _repo.deleteNotification(notificationId);
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final notificationListProvider = StateNotifierProvider
    .autoDispose<NotificationListNotifier,
        NotificationListState>((ref) {
  return NotificationListNotifier(
      ref.watch(notificationRepositoryProvider));
});