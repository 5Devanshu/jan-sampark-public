// lib/features/voter/dashboard/widgets/greeting_banner.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/voter_dashboard_models.dart';

/// Blue gradient header card — shows:
///   • Time-of-day greeting + voter's first name
///   • Ward / Area chip
///   • EPIC verified / unverified badge
class GreetingBanner extends StatelessWidget {
  const GreetingBanner({super.key, required this.profile});

  final VoterProfileSummary profile;

  // ── Time-of-day greeting ──────────────────────
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            Color(0xFF2563EB),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePaddingH,
        AppDimensions.pagePaddingTop,
        AppDimensions.pagePaddingH,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting row ───────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting,',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textOnPrimary.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.firstName,
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.textOnPrimary,
                        fontSize: 26,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // ── Avatar ─────────────────────────
              _AvatarBubble(
                photoUrl: profile.photoUrl,
                name:     profile.fullName,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Ward chip + EPIC badge ──────────────
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (profile.wardName != null)
                _InfoChip(
                  icon:  Icons.location_on_outlined,
                  label: profile.wardName!,
                ),
              if (profile.areaName != null)
                _InfoChip(
                  icon:  Icons.map_outlined,
                  label: profile.areaName!,
                ),
              _EpicBadge(isVerified: profile.epicVerified),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Avatar bubble ─────────────────────────────

class _AvatarBubble extends StatelessWidget {
  const _AvatarBubble({required this.photoUrl, required this.name});

  final String? photoUrl;
  final String  name;

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : '?';

    return Container(
      width:  56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white.withOpacity(0.4),
          width: 2.5,
        ),
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? Image.network(
                photoUrl!,
                fit:        BoxFit.cover,
                errorBuilder: (_, __, ___) => _InitialsCircle(initials: initials),
              )
            : _InitialsCircle(initials: initials),
      ),
    );
  }
}

class _InitialsCircle extends StatelessWidget {
  const _InitialsCircle({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.labelMedium.copyWith(
          color:      AppColors.textOnPrimary,
          fontSize:   20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Info chip ─────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String   label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        AppColors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppColors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textOnPrimary),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color:      AppColors.textOnPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── EPIC badge ────────────────────────────────

class _EpicBadge extends StatelessWidget {
  const _EpicBadge({required this.isVerified});
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isVerified
            ? const Color(0xFF065F46).withOpacity(0.6)
            : const Color(0xFF92400E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isVerified
              ? AppColors.successBorder.withOpacity(0.6)
              : AppColors.warningBorder.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_outlined : Icons.info_outline,
            size:  12,
            color: AppColors.textOnPrimary,
          ),
          const SizedBox(width: 5),
          Text(
            isVerified ? 'EPIC Verified' : 'Not Verified',
            style: AppTextStyles.caption.copyWith(
              color:      AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}