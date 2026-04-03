import 'package:flutter/material.dart';
import '../../core/theme/ops_text_styles.dart';
import '../../core/theme/ops_dimensions.dart';

/// Standard page heading used at the top of every screen.
///
/// Usage:
///   OpsPageHeader(
///     title:       'Corporators',
///     subtitle:    'Manage corporator accounts.',
///     actions: [
///       ElevatedButton.icon(
///         onPressed: ...,
///         icon:  const Icon(Icons.add_rounded, size: 16),
///         label: const Text('Add Corporator'),
///       ),
///     ],
///   )
class OpsPageHeader extends StatelessWidget {
  const OpsPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.bottom,
  });

  final String   title;
  final String?  subtitle;
  final List<Widget> actions;
  final Widget?  bottom;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: OpsTextStyles.heading1),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!,
                        style: OpsTextStyles.caption),
                  ],
                ],
              ),
            ),

            // Action buttons
            if (actions.isNotEmpty) ...[
              const SizedBox(width: OpsDimensions.space16),
              Wrap(
                spacing: OpsDimensions.space8,
                children: actions,
              ),
            ],
          ],
        ),

        // Bottom widget (e.g. search bar, tab bar)
        if (bottom != null) ...[
          const SizedBox(height: OpsDimensions.space16),
          bottom!,
        ],
      ],
    );
  }
}
