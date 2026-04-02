import 'package:flutter/material.dart';
import '../../core/theme/ops_text_styles.dart';

class OpsSectionHeader extends StatelessWidget {
  const OpsSectionHeader({
    super.key,
    required this.title,
    this.action,
  });
  final String  title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: OpsTextStyles.heading2),
        ),
        if (action != null) action!,
      ],
    );
  }
}