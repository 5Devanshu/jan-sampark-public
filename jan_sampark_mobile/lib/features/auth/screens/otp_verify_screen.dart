import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/router/route_names.dart';
import '../../../shared_widgets/buttons/primary_button.dart';
import '../../../shared_widgets/buttons/text_button_link.dart';
import '../../../shared_widgets/inputs/otp_input_field.dart';
import '../providers/otp_notifier.dart';
import '../../../core/constants/app_constants.dart';

/// Screen 2 of registration: enter the 6-digit OTP.
///
/// Shows the mobile number for confirmation, 6-box OTP entry,
/// 60-second resend countdown, and resend link after cooldown.
class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({super.key, required this.mobile});
  final String mobile;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  String _otp = '';

  @override
  void initState() {
    super.initState();
    // Ensure the mobile is set in the notifier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(otpProvider).mobile.isEmpty) {
        ref.read(otpProvider.notifier).sendOtp(widget.mobile);
      }
    });
  }

  Future<void> _onVerify() async {
    if (_otp.length < 6) {
      context.showError('Please enter the complete 6-digit OTP.');
      return;
    }
    await ref.read(otpProvider.notifier).verifyOtp(_otp);
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpProvider);

    // Navigate to registration when OTP is verified
    ref.listen<OtpState>(otpProvider, (_, next) {
      if (next.isVerified && next.verifiedToken.isNotEmpty) {
        context.goNamed(
          RouteNames.register,
          extra: {
            'mobile':          next.mobile,
            'verified_token':  next.verifiedToken,
          },
        );
      }
      if (next.hasError && next.errorMessage.isNotEmpty) {
        context.showError(next.errorMessage);
      }
    });

    final maskedMobile =
        '*' * 6 + widget.mobile.substring(widget.mobile.length - 4);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Blue header ─────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePaddingH,
                AppDimensions.space4XL,
                AppDimensions.pagePaddingH,
                AppDimensions.spaceXXL,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXL),
                  Text(
                    'Verify OTP',
                    style: AppTextStyles.display.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Code sent to +91 $maskedMobile',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),

            // ── OTP content ─────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppDimensions.spaceXXL),

                    Text(
                      'Enter the 6-digit code',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: AppDimensions.spaceSM),
                    Text(
                      'The OTP is valid for '
                      '${AppConstants.otpExpireMinutes} minutes.',
                      style: AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppDimensions.spaceXXL),

                    // OTP input boxes
                    OtpInputField(
                      hasError:    otpState.hasError,
                      isEnabled:   !otpState.isVerifying,
                      onCompleted: (otp) {
                        _otp = otp;
                        _onVerify();
                      },
                      onChanged: (otp) => _otp = otp,
                    ),

                    if (otpState.hasError &&
                        otpState.errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        otpState.errorMessage,
                        style: AppTextStyles.fieldError,
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: AppDimensions.spaceXXL),

                    // Verify button
                    PrimaryButton(
                      label:     'Verify OTP',
                      onPressed: _onVerify,
                      isLoading: otpState.isVerifying,
                    ),

                    const SizedBox(height: AppDimensions.spaceXL),

                    // Resend row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: AppTextStyles.bodySecondary,
                        ),
                        if (!otpState.canResend)
                          Text(
                            'Resend in '
                            '${DateFormatter.countdown(otpState.countdown)}',
                            style: AppTextStyles.captionMedium
                                .copyWith(color: AppColors.primary),
                          )
                        else
                          TextButtonLink(
                            label:     'Resend OTP',
                            onPressed: otpState.isSending
                                ? null
                                : () => ref
                                    .read(otpProvider.notifier)
                                    .resendOtp(),
                            isDisabled: otpState.isSending,
                          ),
                      ],
                    ),

                    // Mock OTP hint (development only)
                    if (const bool.fromEnvironment('dart.vm.product') ==
                        false) ...[
                      const SizedBox(height: AppDimensions.spaceXL),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:        AppColors.warningLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.warningBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.developer_mode,
                                size: 16, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Text(
                              'Dev mode: OTP is 123456',
                              style: AppTextStyles.captionMedium.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

