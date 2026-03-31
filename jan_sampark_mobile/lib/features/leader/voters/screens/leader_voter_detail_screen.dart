import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../../shared_widgets/badges/verification_badge.dart';
import '../models/leader_voter_models.dart';
import '../providers/leader_voter_provider.dart';

class LeaderVoterDetailScreen extends ConsumerWidget {
  const LeaderVoterDetailScreen({super.key, required this.voterId});
  final String voterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(leaderVoterProfileProvider(voterId));

    return async.when(
      loading: () => const AppScaffold(
        title: 'Voter Profile',
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => AppScaffold(
        title: 'Voter Profile',
        body: EmptyStateWidget(
          icon: Icons.error_outline_rounded,
          title: 'Failed to load voter',
          subtitle: e.toString(),
        ),
      ),
      data: (voter) => _VoterDetailContent(voter: voter),
    );
  }
}

class _VoterDetailContent extends StatelessWidget {
  const _VoterDetailContent({required this.voter});
  final VoterProfile voter;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Voter Profile',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spaceMD),

            // ── Header card ──────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.spaceXL),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        voter.initials,
                        style: AppTextStyles.display.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceMD),

                  Text(
                    voter.fullName,
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    voter.mobile,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),

                  VerificationBadge(isVerified: voter.epicVerified),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spaceXL),

            // ── Personal details ─────────────────
            _Section(
              title: 'Personal Information',
              rows: [
                if (voter.gender != null)
                  _Row(label: 'Gender', value: voter.gender!),
                if (voter.dateOfBirth != null)
                  _Row(label: 'Date of Birth', value: voter.dateOfBirth!),
                if (voter.language != null)
                  _Row(label: 'Language', value: voter.language!),
                _Row(
                  label: 'Member Since',
                  value: DateFormatter.toDisplayDate(voter.createdAt),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // ── Location ─────────────────────────
            _Section(
              title: 'Location',
              rows: [
                if (voter.wardName != null)
                  _Row(label: 'Ward', value: voter.wardName!),
                if (voter.areaName != null)
                  _Row(label: 'Area', value: voter.areaName!),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // ── Demographics ─────────────────────
            if (voter.religion != null ||
                voter.education != null ||
                voter.occupation != null) ...[
              _Section(
                title: 'Demographics',
                rows: [
                  if (voter.religion != null)
                    _Row(label: 'Religion', value: voter.religion!),
                  if (voter.education != null)
                    _Row(label: 'Education', value: voter.education!),
                  if (voter.occupation != null)
                    _Row(label: 'Occupation', value: voter.occupation!),
                  if (voter.annualIncomeRange != null)
                    _Row(
                      label: 'Income Range',
                      value: voter.annualIncomeRange!,
                    ),
                  if (voter.familyAdults != null)
                    _Row(
                      label: 'Family Size',
                      value:
                          '${voter.familyAdults} adults'
                          '${voter.familyKids != null ? ', ${voter.familyKids} kids' : ''}',
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceMD),
            ],

            // ── Activity ─────────────────────────
            _Section(
              title: 'Activity',
              rows: [
                _Row(
                  label: 'Complaints Filed',
                  value: '${voter.complaintsCount}',
                ),
                _Row(
                  label: 'Account Status',
                  value: voter.isActive ? 'Active' : 'Inactive',
                  valueColor: voter.isActive
                      ? AppColors.success
                      : AppColors.error,
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceXXL),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});
  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(title, style: AppTextStyles.heading3),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          ...rows,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
