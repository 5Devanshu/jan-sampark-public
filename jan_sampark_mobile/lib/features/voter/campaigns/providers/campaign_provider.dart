import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/file_picker_helper.dart';
import '../models/campaign_models.dart';
import '../repositories/campaign_repository.dart';

// ─────────────────────────────────────────────
// Campaign List State
// ─────────────────────────────────────────────

class CampaignListState {
  const CampaignListState({
    this.campaigns = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage = '',
  });

  final List<CampaignModel> campaigns;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;

  CampaignListState copyWith({
    List<CampaignModel>? campaigns,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
  }) {
    return CampaignListState(
      campaigns: campaigns ?? this.campaigns,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// Campaign List Notifier
// ─────────────────────────────────────────────

class CampaignListNotifier extends StateNotifier<CampaignListState> {
  CampaignListNotifier(this._repo) : super(const CampaignListState()) {
    load();
  }

  final CampaignRepository _repo;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: '', currentPage: 1);

    final response = await _repo.fetchCampaigns(page: 1);

    response.when(
      success: (data) {
        state = state.copyWith(
          campaigns: data.data,
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

    final response = await _repo.fetchCampaigns(page: nextPage);

    response.when(
      success: (data) {
        state = state.copyWith(
          campaigns: [...state.campaigns, ...data.data],
          isLoadingMore: false,
          hasMore: data.hasMore,
          currentPage: nextPage,
        );
      },
      error: (e) {
        state = state.copyWith(isLoadingMore: false);
      },
    );
  }
}

final campaignListProvider =
    StateNotifierProvider.autoDispose<CampaignListNotifier, CampaignListState>((
      ref,
    ) {
      return CampaignListNotifier(ref.watch(campaignRepositoryProvider));
    });

// ─────────────────────────────────────────────
// Campaign Detail
// ─────────────────────────────────────────────

final campaignDetailProvider = FutureProvider.autoDispose
    .family<CampaignModel, String>((ref, id) async {
      final repo = ref.watch(campaignRepositoryProvider);
      final response = await repo.fetchCampaignDetail(id);
      return response.when(success: (data) => data, error: (e) => throw e);
    });

// ─────────────────────────────────────────────
// My Donations State
// ─────────────────────────────────────────────

class MyDonationsState {
  const MyDonationsState({
    this.donations = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage = '',
  });

  final List<DonationModel> donations;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;

  MyDonationsState copyWith({
    List<DonationModel>? donations,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
  }) {
    return MyDonationsState(
      donations: donations ?? this.donations,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MyDonationsNotifier extends StateNotifier<MyDonationsState> {
  MyDonationsNotifier(this._repo) : super(const MyDonationsState()) {
    load();
  }

  final CampaignRepository _repo;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: '', currentPage: 1);

    final response = await _repo.fetchMyDonations(page: 1);

    response.when(
      success: (data) {
        state = state.copyWith(
          donations: data.data,
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

    final response = await _repo.fetchMyDonations(page: nextPage);

    response.when(
      success: (data) {
        state = state.copyWith(
          donations: [...state.donations, ...data.data],
          isLoadingMore: false,
          hasMore: data.hasMore,
          currentPage: nextPage,
        );
      },
      error: (_) {
        state = state.copyWith(isLoadingMore: false);
      },
    );
  }
}

final myDonationsProvider =
    StateNotifierProvider.autoDispose<MyDonationsNotifier, MyDonationsState>((
      ref,
    ) {
      return MyDonationsNotifier(ref.watch(campaignRepositoryProvider));
    });

// ─────────────────────────────────────────────
// Donate State
// ─────────────────────────────────────────────

enum DonateStatus { idle, loading, success, error }

class DonateState {
  const DonateState({
    this.status = DonateStatus.idle,
    this.donation,
    this.errorMessage = '',
  });

  final DonateStatus status;
  final DonationModel? donation;
  final String errorMessage;

  bool get isLoading => status == DonateStatus.loading;
  bool get isSuccess => status == DonateStatus.success;
  bool get hasError => status == DonateStatus.error;

  DonateState copyWith({
    DonateStatus? status,
    DonationModel? donation,
    String? errorMessage,
  }) {
    return DonateState(
      status: status ?? this.status,
      donation: donation ?? this.donation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DonateNotifier extends StateNotifier<DonateState> {
  DonateNotifier(this._repo) : super(const DonateState());

  final CampaignRepository _repo;

  Future<bool> submit({
    required DonateRequest request,
    required PickedFile screenshot,
  }) async {
    state = state.copyWith(status: DonateStatus.loading, errorMessage: '');

    final response = await _repo.submitDonation(
      request: request,
      screenshotPath: screenshot.path,
    );

    return response.when(
      success: (data) {
        state = state.copyWith(status: DonateStatus.success, donation: data);
        return true;
      },
      error: (e) {
        state = state.copyWith(
          status: DonateStatus.error,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
        return false;
      },
    );
  }

  void reset() => state = const DonateState();
}

final donateProvider =
    StateNotifierProvider.autoDispose<DonateNotifier, DonateState>((ref) {
      return DonateNotifier(ref.watch(campaignRepositoryProvider));
    });
