import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../providers/leader_complaint_provider.dart';

class AcknowledgeScreen extends ConsumerStatefulWidget {
  const AcknowledgeScreen({super.key, required this.complaintId});
  final String complaintId;

  @override
  ConsumerState<AcknowledgeScreen> createState() => _AcknowledgeScreenState();
}

class _AcknowledgeScreenState extends ConsumerState<AcknowledgeScreen> {
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    context.hideKeyboard();
    final success = await ref
        .read(complaintActionProvider.notifier)
        .acknowledge(
          widget.complaintId,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        );
    if (!mounted) return;
    if (success) {
      context.showSuccess('Complaint acknowledged.');
      context.pop();
    } else {
      context.showError(ref.read(complaintActionProvider).errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(complaintActionProvider);

    return AppScaffold(
      title: 'Acknowledge Complaint',
      isBlueAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spaceXL),

            // Info banner
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceMD),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Acknowledging confirms you have received '
                      'and reviewed this complaint. '
                      'The voter will be notified.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spaceXXL),

            Text('Optional Note', style: AppTextStyles.heading3),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              'Add a note for the voter explaining your acknowledgement.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppDimensions.spaceMD),

            AppTextField(
              label: 'Note (optional)',
              hint:
                  'e.g. Received your complaint. '
                  'Will inspect the site tomorrow.',
              controller: _noteCtrl,
              maxLines: 4,
              maxLength: 500,
              textInputAction: TextInputAction.done,
            ),

            const SizedBox(height: AppDimensions.spaceXXL),

            PrimaryButton(
              label: 'Acknowledge Complaint',
              icon: Icons.thumb_up_outlined,
              isLoading: actionState.isLoading,
              onPressed: _onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
