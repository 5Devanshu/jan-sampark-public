// lib/features/voter/profile/widgets/profile_info_section.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

/// White card container grouping related profile fields.
/// Shows a title row + optional edit button + children.
class ProfileInfoSection extends StatelessWidget {
  const ProfileInfoSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.onEdit,
    this.editLabel = 'Edit',
  });

  final String      title;
  final IconData    icon;
  final List<Widget> children;
  final VoidCallback? onEdit;
  final String      editLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border:       Border.all(color: AppColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color:      AppColors.shadow,
            blurRadius: 6,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color:        AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: AppTextStyles.labelMedium),
                ),
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon:  const Icon(Icons.edit_outlined, size: 14),
                    label: Text(editLabel, style: AppTextStyles.labelSmall),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),
          Divider(color: AppColors.borderGrey, height: 1),
          ...children,
        ],
      ),
    );
  }
}