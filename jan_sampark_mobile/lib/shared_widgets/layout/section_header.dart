import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../buttons/text_button_link.dart';

/// Section title with an optional "See all" action link.
///
/// Usage:
///   SectionHeader(
///     title:        'Recent Complaints',
///     actionLabel:  'See all',
///     onActionTap:  () => context.goNamed(RouteNames.voterComplaints),
///   )
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTextStyles.heading3),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTextStyles.caption),
              ],
            ],
          ),
        ),
        if (trailing != null)
          trailing!
        else if (actionLabel != null && onActionTap != null)
          TextButtonLink(
            label:     actionLabel!,
            onPressed: onActionTap!,
          ),
      ],
    );
  }
}