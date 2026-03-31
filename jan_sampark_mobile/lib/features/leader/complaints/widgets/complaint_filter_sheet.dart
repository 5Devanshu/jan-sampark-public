import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared_widgets/inputs/app_dropdown.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../../shared_widgets/buttons/secondary_button.dart';

/// Bottom sheet filter panel for the complaint list.
Future<_FilterResult?> showComplaintFilterSheet({
  required BuildContext context,
  required String? currentStatus,
  required String? currentPriority,
  required bool currentEscalatedOnly,
}) {
  return showModalBottomSheet<_FilterResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.bottomSheetRadius),
      ),
    ),
    builder: (_) => _FilterSheet(
      currentStatus: currentStatus,
      currentPriority: currentPriority,
      currentEscalatedOnly: currentEscalatedOnly,
    ),
  );
}

class _FilterResult {
  const _FilterResult({
    this.status,
    this.priority,
    required this.escalatedOnly,
  });
  final String? status;
  final String? priority;
  final bool escalatedOnly;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    this.currentStatus,
    this.currentPriority,
    required this.currentEscalatedOnly,
  });

  final String? currentStatus;
  final String? currentPriority;
  final bool currentEscalatedOnly;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _status;
  String? _priority;
  bool _escalatedOnly = false;

  static const _statusOptions = {
    'pending': 'Pending',
    'acknowledged': 'Acknowledged',
    'in_progress': 'In Progress',
    'resolved': 'Resolved',
    'closed': 'Closed',
    'rejected': 'Rejected',
  };

  static const _priorityOptions = {
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High',
    'emergency': 'Emergency',
  };

  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus;
    _priority = widget.currentPriority;
    _escalatedOnly = widget.currentEscalatedOnly;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePaddingH,
          AppDimensions.spaceLG,
          AppDimensions.pagePaddingH,
          AppDimensions.spaceXL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderGrey,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spaceLG),

            Row(
              children: [
                Text('Filter Complaints', style: AppTextStyles.heading3),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    _status = null;
                    _priority = null;
                    _escalatedOnly = false;
                  }),
                  child: const Text('Clear all'),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceXL),

            // Status filter
            AppDropdown<String>(
              label: 'Status',
              value: _status,
              hint: 'Any status',
              items: dropdownItems(_statusOptions),
              onChanged: (v) => setState(() => _status = v),
            ),

            const SizedBox(height: AppDimensions.spaceXL),

            // Priority filter
            AppDropdown<String>(
              label: 'Priority',
              value: _priority,
              hint: 'Any priority',
              items: dropdownItems(_priorityOptions),
              onChanged: (v) => setState(() => _priority = v),
            ),

            const SizedBox(height: AppDimensions.spaceXL),

            // Escalated toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_outlined,
                    color: AppColors.escalation,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Show escalated only',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  Switch(
                    value: _escalatedOnly,
                    onChanged: (v) => setState(() => _escalatedOnly = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spaceXXL),

            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Cancel',
                    height: AppDimensions.buttonHeightMD,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: 'Apply Filters',
                    height: AppDimensions.buttonHeightMD,
                    onPressed: () => Navigator.of(context).pop(
                      _FilterResult(
                        status: _status,
                        priority: _priority,
                        escalatedOnly: _escalatedOnly,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
