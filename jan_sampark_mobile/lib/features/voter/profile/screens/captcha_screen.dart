// lib/features/voter/profile/screens/captcha_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../providers/voter_profile_provider.dart';
import '../widgets/verification_step_indicator.dart';

class CaptchaScreen extends ConsumerStatefulWidget {
  const CaptchaScreen({super.key});

  @override
  ConsumerState<CaptchaScreen> createState() => _CaptchaScreenState();
}

class _CaptchaScreenState extends ConsumerState<CaptchaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(verificationProvider.notifier).loadCaptcha();
    });
  }

  @override
  Widget build(BuildContext context) {
    final verif = ref.watch(verificationProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title:   const Text('CAPTCHA Verification'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            VerificationStepIndicator(
              currentStep: 1,
              totalSteps:  3,
              labels: const ['Captcha', 'Search', 'Confirm'],
            ),
            Expanded(
              child: switch (verif.step) {
                VerificationStep.loadingCaptcha => const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text('Loading CAPTCHA from ECI portal…'),
                      ],
                    ),
                  ),
                VerificationStep.captchaReady => _CaptchaForm(
                    captcha: verif.captcha!,
                  ),
                VerificationStep.error => _CaptchaError(
                    message:  verif.errorMessage ?? 'Something went wrong',
                    onRetry: () =>
                        ref.read(verificationProvider.notifier).loadCaptcha(),
                  ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CAPTCHA Form — once captcha image is loaded
// ─────────────────────────────────────────────

class _CaptchaForm extends ConsumerStatefulWidget {
  const _CaptchaForm({required this.captcha});
  final CaptchaData captcha;

  @override
  ConsumerState<_CaptchaForm> createState() => _CaptchaFormState();
}

class _CaptchaFormState extends ConsumerState<_CaptchaForm> {
  // Search method toggle
  bool _useEpic = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Column(
        children: [
          const SizedBox(height: 8),

          Text(
            'Type the text shown in the image below, '
            'then choose your search method.',
            style:     AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // ── CAPTCHA image ──────────────────────
          Container(
            decoration: BoxDecoration(
              color:        AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGrey),
            ),
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                base64Decode(widget.captcha.captchaImageBase64),
                height: 80,
                fit:    BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 80,
                  child: Center(
                    child: Text('Could not display CAPTCHA image'),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Refresh CAPTCHA ────────────────────
          TextButton.icon(
            onPressed: () =>
                ref.read(verificationProvider.notifier).loadCaptcha(),
            icon:  const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh CAPTCHA'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: 8),

          // ── Search method toggle ───────────────
          Row(
            children: [
              Expanded(
                child: _MethodTab(
                  label:    'Search by EPIC',
                  isActive: _useEpic,
                  onTap:    () => setState(() => _useEpic = true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MethodTab(
                  label:    'Search by Details',
                  isActive: !_useEpic,
                  onTap:    () => setState(() => _useEpic = false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Proceed button ─────────────────────
          PrimaryButton(
            label:     _useEpic ? 'Search by EPIC →' : 'Search by Details →',
            onPressed: () {
              if (_useEpic) {
                context.pushNamed(RouteNames.epicSearch);
              } else {
                context.pushNamed(RouteNames.detailSearch);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _MethodTab extends StatelessWidget {
  const _MethodTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String       label;
  final bool         isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:  const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:        isActive ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.borderGrey,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isActive ? AppColors.white : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _CaptchaError extends StatelessWidget {
  const _CaptchaError({required this.message, required this.onRetry});
  final String       message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Failed to load CAPTCHA',
                style: AppTextStyles.heading3, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Try Again', onPressed: onRetry, width: 160,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }
}