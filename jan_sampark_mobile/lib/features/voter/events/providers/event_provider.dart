import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../models/event_models.dart';
import '../repositories/event_repository.dart';

// ─────────────────────────────────────────────
// Event List State
// ─────────────────────────────────────────────

class EventListState {
  const EventListState({
    this.events = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage = '',
  });

  final List<EventModel> events;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isEmpty => !isLoading && events.isEmpty && !hasError;

  EventListState copyWith({
    List<EventModel>? events,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
  }) {
    return EventListState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// Event List Notifier
// ─────────────────────────────────────────────

class EventListNotifier extends StateNotifier<EventListState> {
  EventListNotifier(this._repo) : super(const EventListState()) {
    load();
  }

  final EventRepository _repo;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: '', currentPage: 1);

    final response = await _repo.fetchEvents(page: 1);

    response.when(
      success: (data) {
        state = state.copyWith(
          events: data.data,
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

    final response = await _repo.fetchEvents(page: nextPage);

    response.when(
      success: (data) {
        state = state.copyWith(
          events: [...state.events, ...data.data],
          isLoadingMore: false,
          hasMore: data.hasMore,
          currentPage: nextPage,
        );
      },
      error: (_) => state = state.copyWith(isLoadingMore: false),
    );
  }

  /// Optimistically update registration state in the list
  void updateRegistration(String eventId, bool isRegistered) {
    final updated = state.events.map((e) {
      if (e.id == eventId) return e.copyWith(isRegistered: isRegistered);
      return e;
    }).toList();
    state = state.copyWith(events: updated);
  }
}

final eventListProvider =
    StateNotifierProvider.autoDispose<EventListNotifier, EventListState>((ref) {
      return EventListNotifier(ref.watch(eventRepositoryProvider));
    });

// ─────────────────────────────────────────────
// My Registrations
// ─────────────────────────────────────────────

class MyRegistrationsNotifier extends StateNotifier<EventListState> {
  MyRegistrationsNotifier(this._repo) : super(const EventListState()) {
    load();
  }

  final EventRepository _repo;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: '', currentPage: 1);

    final response = await _repo.fetchMyRegistrations(page: 1);

    response.when(
      success: (data) {
        state = state.copyWith(
          events: data.data,
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

    final response = await _repo.fetchMyRegistrations(page: nextPage);

    response.when(
      success: (data) {
        state = state.copyWith(
          events: [...state.events, ...data.data],
          isLoadingMore: false,
          hasMore: data.hasMore,
          currentPage: nextPage,
        );
      },
      error: (_) => state = state.copyWith(isLoadingMore: false),
    );
  }
}

final myRegistrationsProvider =
    StateNotifierProvider.autoDispose<MyRegistrationsNotifier, EventListState>((
      ref,
    ) {
      return MyRegistrationsNotifier(ref.watch(eventRepositoryProvider));
    });

// ─────────────────────────────────────────────
// Event Detail
// ─────────────────────────────────────────────

final eventDetailProvider = FutureProvider.autoDispose
    .family<EventModel, String>((ref, id) async {
      final repo = ref.watch(eventRepositoryProvider);
      final response = await repo.fetchEventDetail(id);
      return response.when(success: (data) => data, error: (e) => throw e);
    });

// ─────────────────────────────────────────────
// Registration State
// ─────────────────────────────────────────────

enum RegistrationStatus { idle, loading, success, cancelled, error }

class RegistrationState {
  const RegistrationState({
    this.status = RegistrationStatus.idle,
    this.message = '',
    this.errorMessage = '',
  });

  final RegistrationStatus status;
  final String message;
  final String errorMessage;

  bool get isLoading => status == RegistrationStatus.loading;
  bool get isSuccess => status == RegistrationStatus.success;
  bool get isCancelled => status == RegistrationStatus.cancelled;
  bool get hasError => status == RegistrationStatus.error;

  RegistrationState copyWith({
    RegistrationStatus? status,
    String? message,
    String? errorMessage,
  }) {
    return RegistrationState(
      status: status ?? this.status,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  RegistrationNotifier(this._repo) : super(const RegistrationState());

  final EventRepository _repo;

  Future<bool> register(String eventId) async {
    state = state.copyWith(
      status: RegistrationStatus.loading,
      errorMessage: '',
    );

    final response = await _repo.registerForEvent(eventId);

    return response.when(
      success: (data) {
        state = state.copyWith(
          status: RegistrationStatus.success,
          message: data.message,
        );
        return true;
      },
      error: (e) {
        state = state.copyWith(
          status: RegistrationStatus.error,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
        return false;
      },
    );
  }

  Future<bool> cancel(String eventId) async {
    state = state.copyWith(
      status: RegistrationStatus.loading,
      errorMessage: '',
    );

    final response = await _repo.cancelRegistration(eventId);

    return response.when(
      success: (_) {
        state = state.copyWith(
          status: RegistrationStatus.cancelled,
          message: 'Registration cancelled.',
        );
        return true;
      },
      error: (e) {
        state = state.copyWith(
          status: RegistrationStatus.error,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
        return false;
      },
    );
  }

  void reset() => state = const RegistrationState();
}

final registrationProvider =
    StateNotifierProvider.autoDispose<RegistrationNotifier, RegistrationState>((
      ref,
    ) {
      return RegistrationNotifier(ref.watch(eventRepositoryProvider));
    });
