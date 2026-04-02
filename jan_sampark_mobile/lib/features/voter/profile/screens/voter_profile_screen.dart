// lib/features/voter/profile/screens/voter_profile_screen.dart
//
// Main Profile tab — shows full voter profile with all sections.
// Tapping "Edit" opens EditProfileScreen.
// Tapping "Verify EPIC" opens verification flow.
// Tapping "OCR Status" opens OcrStatusScreen.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../models/voter_profile_models.dart';
import '../providers/voter_profile_provider.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_field_row.dart';
import '../widgets/ocr_status_banner.dart';

class VoterProfileScreen extends ConsumerStatefulWidget {
  const VoterProfileScreen({super.key});

  @override
  ConsumerState<VoterProfileScreen> createState() =>
      _VoterProfileScreenState();
}

class _VoterProfileScreenState extends ConsumerState<VoterProfileScreen> {
  bool _isUploadingPhoto = false;

  Future<void> _handlePhotoTap(File image) async {
    setState(() => _isUploadingPhoto = true);
    final error = await ref
        .read(voterProfileProvider.notifier)
        .uploadPhoto(image);
    setState(() => _isUploadingPhoto = false);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await SecureStorage.clearAll();
      if (mounted) context.go('/welcome');
    }
  }

  String _formatLabel(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return raw.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(voterProfileProvider);
    final ocrAsync     = ref.watch(ocrStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      body: profileAsync.when(
        loading: () => _ProfileSkeleton(),
        error:   (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(voterProfileProvider),
        ),
        data: (profile) => RefreshIndicator(
          onRefresh: () => ref.read(voterProfileProvider.notifier).refresh(),
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── Transparent SliverAppBar so back button works ─
              SliverAppBar(
                pinned:          true,
                backgroundColor: AppColors.primaryDark,
                elevation:       0,
                scrolledUnderElevation: 0,
                expandedHeight:  0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: AppColors.textOnPrimary),
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go('/voter/home'),
                ),
                title: Text(
                  'My Profile',
                  style: AppTextStyles.appBarTitle.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout_outlined,
                        color: AppColors.textOnPrimary),
                    onPressed: _handleLogout,
                    tooltip: 'Log Out',
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header card ───────────────────
                    ProfileHeaderCard(
                      profile:          profile,
                      onPhotoTap:       _handlePhotoTap,
                      isUploadingPhoto: _isUploadingPhoto,
                    ),

                    const SizedBox(height: AppDimensions.spaceXL),

                    // ── OCR status banner ─────────────
                    ocrAsync.whenOrNull(
                      data: (ocr) => ocr != null
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppDimensions.spaceXL),
                              child: OcrStatusBanner(
                                ocrStatus:    ocr,
                                onViewDetail: () => context.pushNamed(
                                  RouteNames.voterOcrStatus,
                                ),
                                onRetry: () async {
                                  final err = await ref
                                      .read(ocrStatusProvider.notifier)
                                      .retry();
                                  if (err != null && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(err),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                              ),
                            )
                          : null,
                    ) ?? const SizedBox.shrink(),

                    // ── EPIC verification card ─────────
                    _EpicVerificationCard(
                      isVerified:  profile.epicVerified,
                      onVerifyTap: () => context.pushNamed(
                        RouteNames.verificationIntro,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spaceXL),

                    // ── Basic info section ─────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.pagePaddingH,
                      ),
                      child: ProfileInfoSection(
                        title:  'Basic Information',
                        icon:   Icons.person_outline,
                        onEdit: () => context.pushNamed(
                          RouteNames.editProfile,
                          queryParameters: {'section': 'basic'},
                        ),
                        children: [
                          ProfileFieldRow(
                            label: 'Full Name',
                            value: profile.fullName,
                          ),
                          ProfileFieldRow(
                            label: 'Mobile',
                            value: profile.mobile,
                          ),
                          ProfileFieldRow(
                            label: 'Language',
                            value: _formatLabel(profile.language),
                          ),
                          ProfileFieldRow(
                            label:  'Member Since',
                            value:  profile.createdAt != null
                                ? DateFormat('d MMM yyyy').format(profile.createdAt!)
                                : '—',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spaceMD),

                    // ── Location section ───────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.pagePaddingH,
                      ),
                      child: ProfileInfoSection(
                        title:  'Location',
                        icon:   Icons.location_on_outlined,
                        onEdit: () => context.pushNamed(
                          RouteNames.editProfile,
                          queryParameters: {'section': 'location'},
                        ),
                        children: [
                          ProfileFieldRow(
                            label: 'Ward',
                            value: profile.location.wardName ?? '—',
                          ),
                          ProfileFieldRow(
                            label: 'Ward Code',
                            value: profile.location.wardCode ?? '—',
                          ),
                          ProfileFieldRow(
                            label:  'Area',
                            value:  profile.location.areaName ?? '—',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spaceMD),

                    // ── Demographics section ───────────
                    if (profile.voterProfile != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.pagePaddingH,
                        ),
                        child: ProfileInfoSection(
                          title:  'Demographic Profile',
                          icon:   Icons.people_outline,
                          onEdit: () => context.pushNamed(
                            RouteNames.editProfile,
                            queryParameters: {'section': 'demographics'},
                          ),
                          children: [
                            ProfileFieldRow(
                              label: 'Gender',
                              value: _formatLabel(profile.voterProfile!.gender),
                            ),
                            ProfileFieldRow(
                              label: 'Date of Birth',
                              value: profile.voterProfile!.dateOfBirth != null
                                  ? _formatDob(profile.voterProfile!.dateOfBirth!)
                                  : '—',
                            ),
                            ProfileFieldRow(
                              label: 'Age',
                              value: profile.voterProfile!.age != null
                                  ? '${profile.voterProfile!.age} years'
                                  : '—',
                            ),
                            ProfileFieldRow(
                              label: 'Religion',
                              value: _formatLabel(profile.voterProfile!.religion),
                            ),
                            ProfileFieldRow(
                              label: 'Education',
                              value: _formatLabel(profile.voterProfile!.education),
                            ),
                            ProfileFieldRow(
                              label: 'Occupation',
                              value: _formatLabel(profile.voterProfile!.occupation),
                            ),
                            ProfileFieldRow(
                              label: 'Profession',
                              value: _formatLabel(profile.voterProfile!.profession),
                            ),
                            ProfileFieldRow(
                              label: 'Annual Income',
                              value: _formatLabel(
                                  profile.voterProfile!.annualIncomeRange),
                            ),
                            ProfileFieldRow(
                              label: 'Family — Adults',
                              value: profile.voterProfile!.familyAdults != null
                                  ? '${profile.voterProfile!.familyAdults}'
                                  : '—',
                            ),
                            ProfileFieldRow(
                              label:  'Family — Kids',
                              value:  profile.voterProfile!.familyKids != null
                                  ? '${profile.voterProfile!.familyKids}'
                                  : '—',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: AppDimensions.spaceXXL),

                    // ── Footer ─────────────────────────
                    Center(
                      child: Text(
                        'Jan Sampark v1.0.0',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDob(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('d MMMM yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

// ─────────────────────────────────────────────
// EPIC verification CTA card
// ─────────────────────────────────────────────

class _EpicVerificationCard extends StatelessWidget {
  const _EpicVerificationCard({
    required this.isVerified,
    required this.onVerifyTap,
  });

  final bool         isVerified;
  final VoidCallback onVerifyTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: isVerified
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                  colors: [Color(0xFF065F46), Color(0xFF047857)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color:      AppColors.shadow,
              blurRadius: 12,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:  AppColors.white.withOpacity(0.15),
                shape:  BoxShape.circle,
              ),
              child: Icon(
                isVerified ? Icons.verified_user : Icons.how_to_vote_outlined,
                color: AppColors.white,
                size:  28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVerified
                        ? 'EPIC Card Verified ✓'
                        : 'Verify Your Voter ID Card',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isVerified
                        ? 'Your voter identity is linked to '
                          'the ECI database.'
                        : 'Link your EPIC card to unlock all features '
                          'and confirm your identity.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            if (!isVerified) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onVerifyTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:        AppColors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Verify',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Skeleton + Error
// ─────────────────────────────────────────────

class _ProfileSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:      AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(height: 260, color: AppColors.white),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _box(h: 90, r: 12),
                  const SizedBox(height: 12),
                  _box(h: 180, r: 12),
                  const SizedBox(height: 12),
                  _box(h: 140, r: 12),
                  const SizedBox(height: 12),
                  _box(h: 280, r: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box({required double h, required double r}) => Container(
        height:      h,
        width:       double.infinity,
        margin:      const EdgeInsets.only(bottom: 4),
        decoration:  BoxDecoration(
          color:        AppColors.white,
          borderRadius: BorderRadius.circular(r),
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
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
            const Icon(Icons.error_outline,
                size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Could not load profile',
                style: AppTextStyles.heading3, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Retry', onPressed: onRetry, width: 140),
          ],
        ),
      ),
    );
  }
}