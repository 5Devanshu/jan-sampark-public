import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared_widgets/inputs/app_dropdown.dart';
import '../models/auth_models.dart';
import '../providers/auth_notifier.dart';

/// Registration Step 2 — Location Selection.
///
/// Voter picks their Area first then their Ward from
/// the filtered list for that area.
/// Ward list reloads when area changes.
class RegistrationStepTwo extends ConsumerWidget {
  const RegistrationStepTwo({
    super.key,
    required this.selectedAreaId,
    required this.selectedWardId,
    required this.onAreaChanged,
    required this.onWardChanged,
  });

  final String? selectedAreaId;
  final String? selectedWardId;
  final void Function(String? areaId) onAreaChanged;
  final void Function(String? wardId) onWardChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(areasProvider);
    final wardsAsync = ref.watch(
        wardsForAreaProvider(selectedAreaId ?? ''));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical:   AppDimensions.pagePaddingTop,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Location', style: AppTextStyles.heading2),
          const SizedBox(height: 6),
          Text(
            'Select the area and ward where you are registered to vote.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppDimensions.spaceXXL),

          // ── Area selector ─────────────────────
          areasAsync.when(
            loading: () => const _DropdownSkeleton(label: 'Area'),
            error:   (e, _) => _ErrorTile(
              label:   'Area',
              message: 'Failed to load areas. Please retry.',
            ),
            data: (areas) {
              final areaItems = areas.map((a) {
                return DropdownMenuItem<String>(
                  value: a.id,
                  child: Text(a.areaName,
                      style: AppTextStyles.body),
                );
              }).toList();

              return AppDropdown<String>(
                label:     'Area',
                hint:      'Select your area',
                value:     selectedAreaId,
                items:     areaItems,
                onChanged: (val) {
                  onAreaChanged(val);
                  onWardChanged(null); // Reset ward when area changes
                },
                validator: (_) => selectedAreaId == null
                    ? 'Please select your area.'
                    : null,
                prefixIcon: const Icon(Icons.location_city_outlined,
                    size: AppDimensions.iconMD),
              );
            },
          ),

          const SizedBox(height: AppDimensions.spaceXL),

          // ── Ward selector ─────────────────────
          if (selectedAreaId == null) ...[
            _HintTile(
              icon:    Icons.info_outline_rounded,
              message: 'Select an area first to see its wards.',
            ),
          ] else
            wardsAsync.when(
              loading: () => const _DropdownSkeleton(label: 'Ward'),
              error:   (e, _) => _ErrorTile(
                label:   'Ward',
                message: 'Failed to load wards. Please retry.',
              ),
              data: (wards) {
                if (wards.isEmpty) {
                  return _HintTile(
                    icon:    Icons.warning_amber_outlined,
                    message: 'No wards found for the selected area.',
                  );
                }
                final wardItems = wards.map((w) {
                  return DropdownMenuItem<String>(
                    value: w.id,
                    child: Text('${w.wardName} (${w.wardCode})',
                        style: AppTextStyles.body),
                  );
                }).toList();

                return AppDropdown<String>(
                  label:     'Ward',
                  hint:      'Select your ward',
                  value:     selectedWardId,
                  items:     wardItems,
                  onChanged: onWardChanged,
                  validator: (_) => selectedWardId == null
                      ? 'Please select your ward.'
                      : null,
                  prefixIcon: const Icon(Icons.map_outlined,
                      size: AppDimensions.iconMD),
                );
              },
            ),

          const SizedBox(height: AppDimensions.spaceXL),

          // Info note
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceMD),
            decoration: BoxDecoration(
              color:        AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your area and ward determine which events, '
                    'announcements, and campaigns you can see.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spaceXXL),
        ],
      ),
    );
  }
}

class _DropdownSkeleton extends StatelessWidget {
  const _DropdownSkeleton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 6),
        Container(
          height: AppDimensions.inputHeight,
          decoration: BoxDecoration(
            color: AppColors.shimmerBase,
            borderRadius:
                BorderRadius.circular(AppDimensions.inputRadius),
          ),
          child: const Center(
            child: SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.label, required this.message});
  final String label;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:        AppColors.errorLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.errorBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message,
                    style: AppTextStyles.fieldError),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HintTile extends StatelessWidget {
  const _HintTile({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: AppTextStyles.bodySecondary),
          ),
        ],
      ),
    );
  }
}