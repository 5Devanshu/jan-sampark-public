import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/router/route_names.dart';
import '../../../shared_widgets/buttons/primary_button.dart';
import '../../../shared_widgets/buttons/secondary_button.dart';

/// Welcome screen — first screen new users see.
///
/// Shows Jan Sampark logo, tagline, and two actions:
///   Login    → existing users
///   Register → new voter registration
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top blue section ────────────────────
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin:  Alignment.topCenter,
                    end:    Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo container ──────────────
                    Container(
                      width:  110,
                      height: 110,
                      decoration: BoxDecoration(
                        color:        AppColors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color:      Colors.black.withOpacity(0.2),
                            blurRadius: 24,
                            offset:     const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Image.asset(
                        'assets/images/logo_jan_sampark_icon.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.how_to_vote_rounded,
                          color: AppColors.primary,
                          size:  60,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── App name ────────────────────
                    Text(
                      'Jan Sampark',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Tagline ─────────────────────
                    Text(
                      'Your Voice, Your Ward',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white.withOpacity(0.85),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spaceXXL),

                    // ── Feature pills ────────────────
                    Wrap(
                      spacing:   10,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: const [
                        _FeaturePill(label: '🗳️  File Complaints'),
                        _FeaturePill(label: '📣  Stay Informed'),
                        _FeaturePill(label: '🤝  Community Events'),
                        _FeaturePill(label: '💙  Support Campaigns'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom action section ───────────────
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pagePaddingH,
                  vertical:   AppDimensions.spaceXXL,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Connect with your local representative.',
                      style:     AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppDimensions.spaceXL),

                    // ── Login button ────────────────
                    PrimaryButton(
                      label:     'Login',
                      onPressed: () => context.goNamed(RouteNames.login),
                    ),

                    const SizedBox(height: AppDimensions.spaceMD),

                    // ── Register button ─────────────
                    SecondaryButton(
                      label:     'Register as Voter',
                      onPressed: () => context.goNamed(RouteNames.otpSend),
                    ),

                    const SizedBox(height: AppDimensions.spaceXL),

                    // ── Language note ────────────────
                    Text(
                      'Available in English · हिन्दी · मराठी · ગુજરાતી',
                      style:     AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
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

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color:        AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: AppColors.white.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionMedium.copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }
}