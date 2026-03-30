// lib/features/voter/dashboard/widgets/leaderboard_preview_card.dart
//
// Compact ranked list of top community leaders / corporators.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/voter_dashboard_models.dart';

class LeaderboardPreviewCard extends StatelessWidget {
  const LeaderboardPreviewCard({
    super.key,
    required this.entries,
  });

  final List<DashboardLeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
      ),
      child: Container(
        decoration: BoxDecoration(
          color:        AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border:       Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color:      AppColors.shadow,
              blurRadius: 8,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Container(
                    padding:     const EdgeInsets.all(7),
                    decoration:  BoxDecoration(
                      color:        const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.emoji_events_outlined,
                      color: Color(0xFFD97706),
                      size:  18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Community Leaderboard', style: AppTextStyles.labelMedium),
                ],
              ),
            ),

            Divider(color: AppColors.borderGrey, height: 1),

            // ── Entries ────────────────────────────
            ...entries.asMap().entries.map((e) {
              final i     = e.key;
              final entry = e.value;
              return _LeaderboardRow(
                entry:    entry,
                isLast:   i == entries.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.entry,
    required this.isLast,
  });

  final DashboardLeaderboardEntry entry;
  final bool                      isLast;

  Color get _rankColor {
    return switch (entry.rank) {
      1 => const Color(0xFFD97706),   // Gold
      2 => const Color(0xFF6B7280),   // Silver
      3 => const Color(0xFFB45309),   // Bronze
      _ => AppColors.textDisabled,
    };
  }

  IconData get _roleIcon {
    return entry.role == 'corporator'
        ? Icons.account_balance_outlined
        : Icons.person_pin_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // ── Rank ─────────────────────────────
              SizedBox(
                width: 28,
                child: Text(
                  '#${entry.rank}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color:      _rankColor,
                    fontWeight: entry.rank <= 3
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(width: 10),

              // ── Avatar ───────────────────────────
              _MiniAvatar(
                photoUrl: entry.photoUrl,
                name:     entry.fullName,
                rank:     entry.rank,
              ),

              const SizedBox(width: 10),

              // ── Name + role ──────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.fullName,
                      style:    AppTextStyles.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Icon(
                          _roleIcon,
                          size:  10,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          entry.role[0].toUpperCase() +
                              entry.role.substring(1),
                          style: AppTextStyles.captionSmall,
                        ),
                        if (entry.wardName != null) ...[
                          Text(' · ',
                              style: AppTextStyles.captionSmall),
                          Expanded(
                            child: Text(
                              entry.wardName!,
                              style:    AppTextStyles.captionSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── Points ───────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:        AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size:  12,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${entry.points}',
                      style: AppTextStyles.captionSmall.copyWith(
                        color:      AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: AppColors.borderGrey, height: 1),
      ],
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({
    required this.photoUrl,
    required this.name,
    required this.rank,
  });

  final String? photoUrl;
  final String  name;
  final int     rank;

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : '?';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: Container(
            width:  36,
            height: 36,
            color:  AppColors.primaryLight,
            child: photoUrl != null && photoUrl!.isNotEmpty
                ? Image.network(photoUrl!, fit: BoxFit.cover)
                : Center(
                    child: Text(
                      initials,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
          ),
        ),
        if (rank <= 3)
          Positioned(
            bottom: -2,
            right:  -2,
            child: Container(
              width:  14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rank == 1
                    ? const Color(0xFFD97706)
                    : rank == 2
                        ? const Color(0xFF6B7280)
                        : const Color(0xFFB45309),
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color:    Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}