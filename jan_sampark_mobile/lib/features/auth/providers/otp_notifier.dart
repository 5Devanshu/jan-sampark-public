import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';
import '../../../core/exceptions/app_exception.dart';

// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────

enum OtpStep { idle, sending, sent, verifying, verified, error }

class OtpState {
  const OtpState({
    this.step             = OtpStep.idle,
    this.mobile           = '',
    this.verifiedToken    = '',
    this.errorMessage     = '',
    this.countdown        = 0,
    this.canResend        = false,
  });

  final OtpStep step;
  final String  mobile;
  final String  verifiedToken;
  final String  errorMessage;
  final int     countdown;
  final bool    canResend;

  bool get isSending   => step == OtpStep.sending;
  bool get isSent      => step == OtpStep.sent;
  bool get isVerifying => step == OtpStep.verifying;
  bool get isVerified  => step == OtpStep.verified;
  bool get hasError    => step == OtpStep.error;

  OtpState copyWith({
    OtpStep? step,
    String?  mobile,
    String?  verifiedToken,
    String?  errorMessage,
    int?     countdown,
    bool?    canResend,
  }) {
    return OtpState(
      step:          step          ?? this.step,
      mobile:        mobile        ?? this.mobile,
      verifiedToken: verifiedToken ?? this.verifiedToken,
      errorMessage:  errorMessage  ?? this.errorMessage,
      countdown:     countdown     ?? this.countdown,
      canResend:     canResend     ?? this.canResend,
    );
  }
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class OtpNotifier extends StateNotifier<OtpState> {
  OtpNotifier(this._repo) : super(const OtpState());

  final AuthRepository _repo;
  Timer? _timer;

  // ── Send OTP ───────────────────────────────

  Future<void> sendOtp(String mobile) async {
    state = state.copyWith(
      step:   OtpStep.sending,
      mobile: mobile,
      errorMessage: '',
    );

    final response = await _repo.sendOtp(
      SendOtpRequest(mobile: mobile.trim()),
    );

    response.when(
      success: (_) {
        state = state.copyWith(step: OtpStep.sent, canResend: false);
        _startCountdown();
      },
      error: (e) {
        state = state.copyWith(
          step:         OtpStep.error,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
      },
    );
  }

  // ── Verify OTP ─────────────────────────────

  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(
      step:         OtpStep.verifying,
      errorMessage: '',
    );

    final response = await _repo.verifyOtp(
      VerifyOtpRequest(mobile: state.mobile, otp: otp),
    );

    response.when(
      success: (data) {
        _timer?.cancel();
        state = state.copyWith(
          step:          OtpStep.verified,
          verifiedToken: data.verifiedToken,
        );
      },
      error: (e) {
        state = state.copyWith(
          step:         OtpStep.error,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
      },
    );
  }

  // ── Resend OTP ─────────────────────────────

  Future<void> resendOtp() async {
    if (!state.canResend) return;
    await sendOtp(state.mobile);
  }

  // ── Countdown Timer ────────────────────────

  void _startCountdown() {
    _timer?.cancel();
    state = state.copyWith(
        countdown: AppConstants.otpResendCooldownSecs,
        canResend: false);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.countdown <= 1) {
        _timer?.cancel();
        state = state.copyWith(countdown: 0, canResend: true);
      } else {
        state = state.copyWith(countdown: state.countdown - 1);
      }
    });
  }

  // ── Reset ──────────────────────────────────

  void reset() {
    _timer?.cancel();
    state = const OtpState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final otpProvider =
    StateNotifierProvider.autoDispose<OtpNotifier, OtpState>((ref) {
  return OtpNotifier(ref.watch(authRepositoryProvider));
});

