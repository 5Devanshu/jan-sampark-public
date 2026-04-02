// lib/features/voter/profile/providers/voter_profile_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../models/voter_profile_models.dart';
import '../repositories/voter_profile_repository.dart';

// ─────────────────────────────────────────────
// Profile Notifier
// ─────────────────────────────────────────────

class VoterProfileNotifier extends AsyncNotifier<VoterProfile> {
  @override
  Future<VoterProfile> build() =>
      ref.read(voterProfileRepositoryProvider).fetchProfile().then((r) {
        if (r.isError) throw r.exception ?? Exception('Unknown error');
        return r.data!;
      });

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(voterProfileRepositoryProvider).fetchProfile().then((r) {
        if (r.isError) throw r.exception ?? Exception('Unknown error');
        return r.data!;
      }),
    );
  }

  /// Update profile fields and return error message or null on success.
  Future<String?> updateProfile(ProfileUpdateRequest req) async {
    final repo = ref.read(voterProfileRepositoryProvider);
    final res  = await repo.updateProfile(req);
    if (res.isError) return _errorMessage(res.exception);
    state = AsyncValue.data(res.data!);
    return null;
  }

  /// Upload profile photo and return error message or null on success.
  Future<String?> uploadPhoto(File imageFile) async {
    final repo = ref.read(voterProfileRepositoryProvider);
    final res  = await repo.uploadPhoto(imageFile);
    if (res.isError) return _errorMessage(res.exception);
    // Patch local state with new photo URL
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(
        current.copyWith(profilePhotoUrl: res.data),
      );
    }
    return null;
  }
}

final voterProfileProvider =
    AsyncNotifierProvider<VoterProfileNotifier, VoterProfile>(
  VoterProfileNotifier.new,
);

// ─────────────────────────────────────────────
// OCR Status Notifier
// ─────────────────────────────────────────────

class OcrStatusNotifier extends AsyncNotifier<OcrJobStatus?> {
  @override
  Future<OcrJobStatus?> build() async {
    final repo = ref.read(voterProfileRepositoryProvider);
    final res  = await repo.fetchOcrStatus();
    if (res.isError) return null;
    return res.data;
  }

  Future<String?> retry() async {
    final repo = ref.read(voterProfileRepositoryProvider);
    final res  = await repo.retryOcr();
    if (res.isError) return _errorMessage(res.exception);
    // Re-fetch status after queuing retry
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final r = await repo.fetchOcrStatus();
      return r.data;
    });
    return null;
  }
}

final ocrStatusProvider =
    AsyncNotifierProvider<OcrStatusNotifier, OcrJobStatus?>(
  OcrStatusNotifier.new,
);

// ─────────────────────────────────────────────
// EPIC Verification Flow Notifier
// ─────────────────────────────────────────────

enum VerificationStep { idle, loadingCaptcha, captchaReady, searching, result, saving, success, error }

class VerificationState {
  const VerificationState({
    this.step              = VerificationStep.idle,
    this.captcha,
    this.searchResult,
    this.errorMessage,
    this.sessionId,
  });

  final VerificationStep step;
  final CaptchaData?     captcha;
  final EciVoterResult?  searchResult;
  final String?          errorMessage;
  final String?          sessionId;

  VerificationState copyWith({
    VerificationStep? step,
    CaptchaData?      captcha,
    EciVoterResult?   searchResult,
    String?           errorMessage,
    String?           sessionId,
  }) =>
      VerificationState(
        step:         step          ?? this.step,
        captcha:      captcha       ?? this.captcha,
        searchResult: searchResult  ?? this.searchResult,
        errorMessage: errorMessage  ?? this.errorMessage,
        sessionId:    sessionId     ?? this.sessionId,
      );
}

class VerificationNotifier extends Notifier<VerificationState> {
  @override
  VerificationState build() => const VerificationState();

  final _repo = voterProfileRepositoryProvider;

  Future<void> loadCaptcha() async {
    state = state.copyWith(step: VerificationStep.loadingCaptcha, errorMessage: null);
    final res = await ref.read(_repo).fetchCaptcha();
    if (res.isError) {
      state = state.copyWith(
        step:         VerificationStep.error,
        errorMessage: _errorMessage(res.exception),
      );
      return;
    }
    state = state.copyWith(
      step:      VerificationStep.captchaReady,
      captcha:   res.data,
      sessionId: res.data!.sessionId,
    );
  }

  Future<void> searchByEpic({
    required String epic,
    required String stateCode,
    required String captchaText,
  }) async {
    if (state.sessionId == null) return;
    state = state.copyWith(step: VerificationStep.searching, errorMessage: null);
    final res = await ref.read(_repo).searchByEpic(
      sessionId: state.sessionId!,
      epic:      epic,
      state:     stateCode,
      captcha:   captchaText,
    );
    if (res.isError) {
      state = state.copyWith(
        step:         VerificationStep.error,
        errorMessage: _errorMessage(res.exception),
      );
      return;
    }
    state = state.copyWith(
      step:         VerificationStep.result,
      searchResult: res.data,
    );
  }

  Future<void> searchByDetails({
    required String name,
    required String stateCode,
    required String district,
    required String captchaText,
    String? fatherName,
    int?    age,
    String? gender,
  }) async {
    if (state.sessionId == null) return;
    state = state.copyWith(step: VerificationStep.searching, errorMessage: null);
    final res = await ref.read(_repo).searchByDetails(
      sessionId:  state.sessionId!,
      name:       name,
      state:      stateCode,
      district:   district,
      captcha:    captchaText,
      fatherName: fatherName,
      age:        age,
      gender:     gender,
    );
    if (res.isError) {
      state = state.copyWith(
        step:         VerificationStep.error,
        errorMessage: _errorMessage(res.exception),
      );
      return;
    }
    state = state.copyWith(
      step:         VerificationStep.result,
      searchResult: res.data,
    );
  }

  Future<void> saveVerification() async {
    final result = state.searchResult;
    if (result == null || state.sessionId == null) return;

    state = state.copyWith(step: VerificationStep.saving, errorMessage: null);
    final res = await ref.read(_repo).saveVerification(
      sessionId:  state.sessionId!,
      epicNumber: result.epicNumber ?? '',
      stateCode:  result.stateCode  ?? '',
      eciData:    result.rawJson    ?? {},
    );
    if (res.isError) {
      state = state.copyWith(
        step:         VerificationStep.error,
        errorMessage: _errorMessage(res.exception),
      );
      return;
    }
    state = state.copyWith(step: VerificationStep.success);
    // Refresh profile so epicVerified flips to true
    ref.invalidate(voterProfileProvider);
  }

  void reset() => state = const VerificationState();
}

final verificationProvider =
    NotifierProvider<VerificationNotifier, VerificationState>(
  VerificationNotifier.new,
);

String _errorMessage(Exception? e) {
  if (e == null) return 'Something went wrong.';
  if (e is AppException) return e.message;
  return e.toString();
}
