import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../buttons/primary_button.dart';

/// Empty state placeholder for lists with no data.
///
/// Usage:
///   EmptyStateWidget(
///     icon:       Icons.report_problem_outlined,
///     title:      'No Complaints Yet',
///     subtitle:   'File your first complaint to get started.',
///     actionLabel: 'File Complaint',
///     onAction:   () => context.goNamed(RouteNames.fileComplaint),
///   )
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.iconSize = 64,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──────────────────────────────
            Container(
              width:  iconSize + 24,
              height: iconSize + 24,
              decoration: BoxDecoration(
                color:        AppColors.primaryLight,
                borderRadius: BorderRadius.circular(iconSize),
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size:  iconSize,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceXL),

            // ── Title ─────────────────────────────
            Text(
              title,
              style:     AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),

            // ── Subtitle ──────────────────────────
            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.spaceSM),
              Text(
                subtitle!,
                style:     AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ],

            // ── Action button ─────────────────────
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.spaceXL),
              PrimaryButton(
                label:     actionLabel!,
                onPressed: onAction,
                width:     200,
                height:    AppDimensions.buttonHeightMD,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading placeholder for list screens.
class ShimmerListPlaceholder extends StatelessWidget {
  const ShimmerListPlaceholder({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 100,
  });

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics:     const NeverScrollableScrollPhysics(),
      itemCount:   itemCount,
      padding:     const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical:   AppDimensions.pagePaddingTop,
      ),
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spaceMD),
      itemBuilder: (_, __) => _ShimmerCard(height: itemHeight),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard({required this.height});
  final double height;

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            gradient: LinearGradient(
              begin: Alignment(_anim.value - 1, 0),
              end:   Alignment(_anim.value + 1, 0),
              colors: const [
                AppColors.shimmerBase,
                AppColors.shimmerHighlight,
                AppColors.shimmerBase,
              ],
            ),
          ),
        );
      },
    );
  }
}