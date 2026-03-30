// lib/features/voter/profile/widgets/profile_field_row.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A single label + value row used inside profile info sections.
class ProfileFieldRow extends StatelessWidget {
  const ProfileFieldRow({
    super.key,
    required this.label,
    required this.value,
    this.isLast = false,
    this.valueColor,
    this.trailing,
  });

  final String    label;
  final String    value;
  final bool      isLast;
  final Color?    valueColor;
  final Widget?   trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value.isEmpty ? '—' : value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: valueColor ??
                        (value.isEmpty
                            ? AppColors.textDisabled
                            : AppColors.textPrimary),
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color:   AppColors.borderGrey,
            height:  1,
            indent:  16,
            endIndent: 16,
          ),
      ],
    );
  }
}