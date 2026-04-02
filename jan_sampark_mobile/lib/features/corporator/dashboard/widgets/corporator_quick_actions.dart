import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';

class CorporatorQuickActions extends StatelessWidget {
  const CorporatorQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap:     true,
      physics:        const NeverScrollableScrollPhysics(),
      mainAxisSpacing:  AppDimensions.spaceMD,
      crossAxisSpacing: AppDimensions.spaceMD,
      childAspectRatio: 0.85,
      children: [
        _ActionTile(
          icon:  Icons.report_problem_outlined,
          label: 'Complaints',
          color: AppColors.primary,
          route: RouteNames.corporatorComplaints,
        ),
        _ActionTile(
          icon:  Icons.people_outline,
          label: 'Leaders',
          color: AppColors.primaryAccent,
          route: RouteNames.leadersManagement,
        ),
        _ActionTile(
          icon:  Icons.volunteer_activism_outlined,
          label: 'Campaigns',
          color: AppColors.success,
          route: RouteNames.campaignManagement,
        ),
        _ActionTile(
          icon:  Icons.event_outlined,
          label: 'Events',
          color: const Color(0xFF0891B2),
          route: RouteNames.eventsManagement,
        ),
        _ActionTile(
          icon:  Icons.forum_outlined,
          label: 'Chats',
          color: const Color(0xFF7C3AED),
          route: RouteNames.chatsManagement,
        ),
        _ActionTile(
          icon:  Icons.campaign_outlined,
          label: 'Announce',
          color: const Color(0xFFEA580C),
          route: RouteNames.announcementsManagement,
        ),
        _ActionTile(
          icon:  Icons.poll_outlined,
          label: 'Polls',
          color: const Color(0xFFDB2777),
          route: RouteNames.pollsManagement,
        ),
        _ActionTile(
          icon:  Icons.phone_outlined,
          label: 'Helpline',
          color: AppColors.escalation,
          route: RouteNames.helplineManagement,
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });

  final IconData icon;
  final String   label;
  final Color    color;
  final String   route;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.goNamed(route),
      child: Container(
        decoration: BoxDecoration(
          color:        AppColors.white,
          borderRadius: BorderRadius.circular(
              AppDimensions.cardRadius),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:  44,
              height: 44,
              decoration: BoxDecoration(
                color:        color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style:     AppTextStyles.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
