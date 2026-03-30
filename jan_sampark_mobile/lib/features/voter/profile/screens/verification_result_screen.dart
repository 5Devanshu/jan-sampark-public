// lib/features/voter/profile/screens/verification_result_screen.dart
//
// Shows the ECI voter record found by the search.
// Voter confirms it's theirs → POST /voter/save → success screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../../shared_widgets/buttons/secondary_button.dart';
import '../models/voter_profile_models.dart';
import '../providers/voter_profile_provider.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_field_row.dart';
import '../widgets/verification_step_indicator.dart';

class VerificationResultScreen extends ConsumerWidget {
  const VerificationResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verif = ref.watch(verificationProvider);

    // If still searching, show loader
    if (verif.step == VerificationStep.searching) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final result = verif.searchResult;
    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: const Center(child: Text('No result found')),
      );
    }

    final isSaving = verif.step == VerificationStep.saving;

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title:   const Text('Confirm Your Record'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            VerificationStepIndicator(
              currentStep: 3,
              totalSteps:  3,
              labels: const ['Captcha', 'Search', 'Confirm'],
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
                children: [
                  // ── Match found badge ────────────
                  Container(
                    padding:     const EdgeInsets.all(14),
                    decoration:  BoxDecoration(
                      color:        AppColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.successBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: AppColors.success, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Voter record found in ECI database',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Is this you?',
                    style: AppTextStyles.heading3,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Review the details below carefully. '
                    'If this is your record, tap "Yes, this is me" '
                    'to link it to your profile.',
                    style: AppTextStyles.bodySecondary,
                  ),

                  const SizedBox(height: 16),

                  // ── Identity ─────────────────────
                  ProfileInfoSection(
                    title: 'Identity',
                    icon:  Icons.badge_outlined,
                    children: [
                      ProfileFieldRow(
                          label: 'Name',
                          value: result.displayName),
                      ProfileFieldRow(
                          label: 'EPIC Number',
                          value: result.epicNumber ?? '—'),
                      ProfileFieldRow(
                          label: 'Age',
                          value: result.age != null
                              ? '${result.age} years' : '—'),
                      ProfileFieldRow(
                        label:  'Gender',
                        value:  result.gender == 'M' ? 'Male'
                            : result.gender == 'F' ? 'Female'
                            : result.gender ?? '—',
                        isLast: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Family ───────────────────────
                  if (result.relativeName != null)
                    ProfileInfoSection(
                      title: 'Family',
                      icon:  Icons.family_restroom_outlined,
                      children: [
                        ProfileFieldRow(
                          label:  result.relationType ?? 'Relative',
                          value:  result.relativeName ?? '—',
                          isLast: true,
                        ),
                      ],
                    ),

                  if (result.relativeName != null)
                    const SizedBox(height: 12),

                  // ── Constituency ─────────────────
                  ProfileInfoSection(
                    title: 'Constituency',
                    icon:  Icons.how_to_vote_outlined,
                    children: [
                      ProfileFieldRow(
                          label: 'Assembly',
                          value: result.assemblyName ?? '—'),
                      ProfileFieldRow(
                          label: 'District',
                          value: result.district ?? '—'),
                      ProfileFieldRow(
                          label: 'State',
                          value: result.stateName ?? '—'),
                      ProfileFieldRow(
                        label:  'Part No.',
                        value:  result.partNumber ?? '—',
                        isLast: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Polling station ───────────────
                  if (result.pollingStation != null)
                    ProfileInfoSection(
                      title: 'Polling Station',
                      icon:  Icons.location_on_outlined,
                      children: [
                        ProfileFieldRow(
                            label: 'Station',
                            value: result.pollingStation ?? '—'),
                        ProfileFieldRow(
                          label:  'Address',
                          value:  result.stationAddress ?? '—',
                          isLast: true,
                        ),
                      ],
                    ),

                  if (verif.step == VerificationStep.error &&
                      verif.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:        AppColors.errorLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.errorBorder),
                      ),
                      child: Text(
                        verif.errorMessage!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // ── Action buttons ──────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  PrimaryButton(
                    label:     'Yes, this is me — Link My Profile',
                    onPressed: isSaving
                        ? null
                        : () async {
                            await ref
                                .read(verificationProvider.notifier)
                                .saveVerification();
                            final step =
                                ref.read(verificationProvider).step;
                            if (step == VerificationStep.success && context.mounted) {
                              context.pushReplacementNamed(
                                  RouteNames.verificationSuccess);
                            }
                          },
                    isLoading: isSaving,
                    icon:      Icons.verified_user,
                  ),
                  const SizedBox(height: 8),
                  SecondaryButton(
                    label:     'Not me — Search Again',
                    onPressed: isSaving
                        ? null
                        : () {
                            context.pop();
                            context.pop();
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}