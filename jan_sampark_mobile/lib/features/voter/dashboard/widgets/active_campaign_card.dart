// lib/features/voter/dashboard/widgets/active_campaign_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../models/voter_dashboard_models.dart';

class ActiveCampaignCard extends StatelessWidget {
  const ActiveCampaignCard({
    super.key,
    required this.campaign,
    required this.index,
  });

  final DashboardCampaign campaign;
  final int               index;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN', symbol: '₹', decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final progress = campaign.progressPercent;

    return GestureDetector(
      onTap: () => context.pushNamed(
        RouteNames.voterCampaigns,
        queryParameters: {'campaign_id': campaign.id},
      ),
      child: Container(
        margin: EdgeInsets.only(
          left:  index == 0 ? AppDimensions.pagePaddingH : 0,
          right: AppDimensions.spaceMD,
        ),
        width: 240,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner / Gradient placeholder ──────
            Container(
              height:      90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                  colors: [Color(0xFF1D4ED8), Color(0xFF7C3AED)],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.cardRadius),
                ),
                image: campaign.bannerUrl != null
                    ? DecorationImage(
                        image: NetworkImage(campaign.bannerUrl!),
                        fit:   BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3),
                          BlendMode.darken,
                        ),
                      )
                    : null,
              ),
              alignment: Alignment.bottomLeft,
              padding:   const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Active Campaign',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),

            // ── Content ────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.title,
                    style:AppTextStyles.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // ── Progress bar ───────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _currency.format(campaign.collectedAmount),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style:AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value:            progress,
                          minHeight:        6,
                          backgroundColor:  AppColors.borderGrey,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'of ${_currency.format(campaign.targetAmount)} goal',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Deadline ───────────────────────
                  if (campaign.deadline != null)
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size:  12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Ends ${DateFormat('d MMM').format(campaign.deadline!)}',
                          style: AppTextStyles.caption,
                        ),
                      ],
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