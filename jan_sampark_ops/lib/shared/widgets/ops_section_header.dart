import 'package:flutter/material.dart';
import '../../core/theme/ops_colors.dart';
import '../../core/theme/ops_text_styles.dart';
import '../../core/theme/ops_dimensions.dart';

/// Section heading with optional trailing action widget.
///
/// Usage:
///   OpsSectionHeader(
///     title:   'Area Summary',
///     subtitle: 'Complaint distribution by area this period',
///     action:  TextButton(onPressed: ..., child: Text('Export')),
///   )
class OpsSectionHeader extends StatelessWidget {
  const OpsSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  final String  title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:       MainAxisSize.min,
              children: [
                Text(title, style: OpsTextStyles.heading3),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!,
                      style: OpsTextStyles.body.copyWith(
                        color: OpsColors.textSecondary,
                      )),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: OpsDimensions.space16),
            action!,
          ],
        ],
      ),
    );
  }
}
