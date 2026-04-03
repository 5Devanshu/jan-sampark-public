import 'package:flutter/material.dart';
import '../../core/theme/ops_colors.dart';
import '../../core/theme/ops_text_styles.dart';
import '../../core/theme/ops_dimensions.dart';

/// Full-area empty state with icon, title, subtitle, and
/// optional action button.
///
/// Usage:
///   OpsEmptyState(
///     icon:        Icons.people_outline,
///     title:       'No Corporators Found',
///     subtitle:    'Add the first corporator to get started.',
///     actionLabel: 'Add Corporator',
///     onAction:    () => ...,
///   )
class OpsEmptyState extends StatelessWidget {
  const OpsEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String   title;
  final String?  subtitle;
  final IconData? icon;
  final String?  actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(OpsDimensions.pagePadding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            if (icon != null) ...[
              Container(
                width:  64,
                height: 64,
                decoration: BoxDecoration(
                  color:        OpsColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon,
                    color: OpsColors.primary, size: 32),
              ),
              const SizedBox(height: 20),
            ],

            // Title
            Text(
              title,
              style:     OpsTextStyles.heading3,
              textAlign: TextAlign.center,
            ),

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style:     OpsTextStyles.body.copyWith(
                  color: OpsColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
