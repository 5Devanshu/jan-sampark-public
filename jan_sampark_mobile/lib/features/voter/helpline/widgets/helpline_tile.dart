import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/extensions.dart';
import '../models/helpline_models.dart';

/// Helpline directory tile with icon, name, number, and call button.
class HelplineTile extends StatelessWidget {
  const HelplineTile({super.key, required this.helpline});
  final HelplineModel helpline;

  Future<void> _call(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: helpline.number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        context.showError(
          'Could not launch dialler. '
          'Dial ${helpline.number} manually.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _categoryConfig(helpline.category);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.cardPaddingH),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: config.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(config.icon, color: config.color, size: 26),
            ),

            const SizedBox(width: 14),

            // Name + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          helpline.name,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (helpline.isSystem)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Official',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),

                  if (helpline.description != null &&
                      helpline.description!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      helpline.description!,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 6),

                  Text(
                    helpline.number,
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Call button
            GestureDetector(
              onTap: () => _call(context),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _CategoryConfig _categoryConfig(String cat) {
    return switch (cat) {
      'police' => _CategoryConfig(
        Icons.local_police_outlined,
        AppColors.primaryDark,
        AppColors.primaryLight,
      ),
      'fire' => _CategoryConfig(
        Icons.local_fire_department_outlined,
        AppColors.error,
        AppColors.errorLight,
      ),
      'medical' => _CategoryConfig(
        Icons.local_hospital_outlined,
        AppColors.success,
        AppColors.successLight,
      ),
      'electricity' => _CategoryConfig(
        Icons.bolt_outlined,
        const Color(0xFFC27803),
        AppColors.warningLight,
      ),
      'water' => _CategoryConfig(
        Icons.water_drop_outlined,
        AppColors.primaryAccent,
        AppColors.primaryLight,
      ),
      'women' => _CategoryConfig(
        Icons.woman_outlined,
        const Color(0xFF9333EA),
        const Color(0xFFF3E8FF),
      ),
      'child' => _CategoryConfig(
        Icons.child_care_outlined,
        const Color(0xFFEA580C),
        const Color(0xFFFFF7ED),
      ),
      'municipal' => _CategoryConfig(
        Icons.location_city_outlined,
        AppColors.primary,
        AppColors.primaryLight,
      ),
      'transport' => _CategoryConfig(
        Icons.directions_bus_outlined,
        const Color(0xFF0891B2),
        const Color(0xFFECFEFF),
      ),
      'disaster' => _CategoryConfig(
        Icons.warning_amber_outlined,
        const Color(0xFFDC2626),
        const Color(0xFFFEF2F2),
      ),
      _ => _CategoryConfig(
        Icons.phone_outlined,
        AppColors.textSecondary,
        AppColors.surfaceGrey,
      ),
    };
  }
}

class _CategoryConfig {
  const _CategoryConfig(this.icon, this.color, this.bg);
  final IconData icon;
  final Color color;
  final Color bg;
}
