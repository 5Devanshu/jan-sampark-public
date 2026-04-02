// lib/features/voter/dashboard/widgets/quick_actions_grid.dart
//
// 4 × 2 grid of icon-based quick action shortcuts.
// Each tile navigates to a feature section.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';

/// Model describing one quick action button.
class _QuickAction {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  final String   label;
  final IconData icon;
  final Color    bgColor;
  final Color    iconColor;
  final void Function(BuildContext context) onTap;
}

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  static List<_QuickAction> _actions(BuildContext ctx) => [
    _QuickAction(
      label:     'File Complaint',
      icon:      Icons.report_problem_outlined,
      bgColor:   AppColors.errorLight,
      iconColor: AppColors.error,
      onTap:     (_) => ctx.pushNamed(RouteNames.voterComplaints),
    ),
    _QuickAction(
      label:     'Campaigns',
      icon:      Icons.campaign_outlined,
      bgColor:   AppColors.primaryLight,
      iconColor: AppColors.primary,
      onTap:     (_) => ctx.pushNamed(RouteNames.voterCampaigns),
    ),
    _QuickAction(
      label:     'Events',
      icon:      Icons.event_outlined,
      bgColor:   const Color(0xFFEDE9FE),   // Violet tint
      iconColor: const Color(0xFF6D28D9),
      onTap:     (_) => ctx.pushNamed(RouteNames.voterEvents),
    ),
    _QuickAction(
      label:     'Chats',
      icon:      Icons.chat_bubble_outline,
      bgColor:   const Color(0xFFD1FAE5),   // Emerald tint
      iconColor: const Color(0xFF065F46),
      onTap:     (_) => ctx.pushNamed(RouteNames.voterChats),
    ),
    _QuickAction(
      label:     'Announcements',
      icon:      Icons.notifications_none_outlined,
      bgColor:   AppColors.warningLight,
      iconColor: AppColors.warning,
      onTap:     (_) => ctx.pushNamed(RouteNames.voterAnnouncements),
    ),
    _QuickAction(
      label:     'Polls',
      icon:      Icons.poll_outlined,
      bgColor:   const Color(0xFFFFECE2),   // Orange tint
      iconColor: AppColors.escalation,
      onTap:     (_) => ctx.pushNamed(RouteNames.voterPolls),
    ),
    _QuickAction(
      label:     'Helpline',
      icon:      Icons.support_agent_outlined,
      bgColor:   const Color(0xFFECFDF5),
      iconColor: AppColors.success,
      onTap:     (_) => ctx.pushNamed(RouteNames.helpline),
    ),
    _QuickAction(
      label:     'My Profile',
      icon:      Icons.person_outline,
      bgColor:   AppColors.surfaceGrey,
      iconColor: AppColors.textSecondary,
      onTap:     (_) => ctx.pushNamed(RouteNames.voterProfile),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final actions = _actions(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
      ),
      child: GridView.builder(
        shrinkWrap:  true,
        physics:     const NeverScrollableScrollPhysics(),
        itemCount:   actions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:    4,
          mainAxisSpacing:   12,
          crossAxisSpacing:  12,
          childAspectRatio:  0.85,
        ),
        itemBuilder: (context, i) => _QuickActionTile(action: actions[i]),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});
  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        () => action.onTap(context),
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width:  52,
            height: 52,
            decoration: BoxDecoration(
              color:        action.bgColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color:      AppColors.shadow,
                  blurRadius: 6,
                  offset:     const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              action.icon,
              color: action.iconColor,
              size:  24,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            action.label,
            style:     AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
            maxLines:  2,
            overflow:  TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}