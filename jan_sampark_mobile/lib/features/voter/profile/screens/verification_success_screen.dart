// lib/features/voter/profile/screens/verification_success_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';

class VerificationSuccessScreen extends StatelessWidget {
  const VerificationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // ── Success animation placeholder ────
              Container(
                width:  120,
                height: 120,
                decoration: BoxDecoration(
                  color:        AppColors.successLight,
                  shape:        BoxShape.circle,
                  border: Border.all(
                    color: AppColors.successBorder,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.verified_user,
                  size:  60,
                  color: AppColors.success,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'You\'re Verified!',
                style:     AppTextStyles.heading1.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Your Voter ID has been linked to your Jan Sampark '
                'profile. You now have full access to all features.',
                style:     AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // ── Features unlocked ─────────────────
              _FeatureRow(
                icon:  Icons.report_problem_outlined,
                label: 'File complaints with your verified identity',
              ),
              _FeatureRow(
                icon:  Icons.campaign_outlined,
                label: 'Donate to campaigns securely',
              ),
              _FeatureRow(
                icon:  Icons.event_outlined,
                label: 'Register for exclusive events',
              ),
              _FeatureRow(
                icon:  Icons.chat_bubble_outline,
                label: 'Access ward-level community chats',
              ),

              const Spacer(),

              PrimaryButton(
                label:     'Go to My Profile',
                icon:      Icons.person_outline,
                onPressed: () => context.goNamed(RouteNames.voterProfile),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => context.goNamed(RouteNames.voterHome),
                child: Text(
                  'Back to Home',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});
  final IconData icon;
  final String   label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding:    const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:        AppColors.successLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.success, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}