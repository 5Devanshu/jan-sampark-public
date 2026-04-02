// lib/features/voter/profile/screens/verification_intro_screen.dart
//
// Explains what EPIC verification is before the voter starts the flow.

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

class VerificationIntroScreen extends ConsumerWidget {
  const VerificationIntroScreen({super.key});

  static const _steps = [
    _StepInfo(
      icon:  Icons.qr_code_2_outlined,
      title: 'Get CAPTCHA',
      desc:  'We fetch a CAPTCHA from the official Election '
             'Commission of India portal to secure your search.',
    ),
    _StepInfo(
      icon:  Icons.manage_search_outlined,
      title: 'Find Your Record',
      desc:  'Search by your EPIC number or personal details. '
             'We query the ECI database directly.',
    ),
    _StepInfo(
      icon:  Icons.verified_outlined,
      title: 'Confirm & Link',
      desc:  'Confirm the record is yours and link it to '
             'your Jan Sampark profile.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title:   const Text('Verify Voter ID'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Step indicator ─────────────────────
            VerificationStepIndicator(
              currentStep: 1,
              totalSteps:  3,
              labels: const ['Captcha', 'Search', 'Confirm'],
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // ── Hero icon ─────────────────────
                    Container(
                      width:   100,
                      height:  100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primary],
                          begin: Alignment.topLeft,
                          end:   Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.how_to_vote_outlined,
                        size:  52,
                        color: AppColors.textOnPrimary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Verify Your Voter Identity',
                      style:     AppTextStyles.heading2,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Connect your Jan Sampark profile to the '
                      'official ECI voter database in 3 quick steps.',
                      style:     AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    // ── Steps list ────────────────────
                    ..._steps.asMap().entries.map((e) =>
                        _StepTile(step: e.key + 1, info: e.value)),

                    const SizedBox(height: 20),

                    // ── Privacy note ──────────────────
                    Container(
                      padding:    const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color:        AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your EPIC number is encrypted before '
                              'storage and is never shared with anyone.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── CTA ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: PrimaryButton(
                label:     'Start Verification',
                icon:      Icons.arrow_forward,
                onPressed: () {
                  ref.read(verificationProvider.notifier).reset();
                  context.pushNamed(RouteNames.captchaScreen);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepInfo {
  const _StepInfo({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String   title;
  final String   desc;
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step, required this.info});
  final int       step;
  final _StepInfo info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width:  44,
            height: 44,
            decoration: BoxDecoration(
              color:        AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(info.icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width:  18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color:  AppColors.primary,
                      shape:  BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$step',
                        style: const TextStyle(
                          color:      AppColors.textOnPrimary,
                          fontSize:   10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(info.title, style: AppTextStyles.bodyMedium),
                ]),
                const SizedBox(height: 3),
                Text(info.desc, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}