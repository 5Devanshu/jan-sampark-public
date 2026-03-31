import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../providers/leader_complaint_provider.dart';

class EscalateScreen extends ConsumerStatefulWidget {
  const EscalateScreen({super.key, required this.complaintId});
  final String complaintId;

  @override
  ConsumerState<EscalateScreen> createState() => _EscalateScreenState();
}

class _EscalateScreenState extends ConsumerState<EscalateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();
  String _priority = 'high';

  static const _priorities = [
    _Priority('low', 'Low', AppColors.priorityLowText),
    _Priority('medium', 'Medium', AppColors.priorityMediumText),
    _Priority('high', 'High', AppColors.priorityHighText),
    _Priority('emergency', 'Emergency', AppColors.priorityEmergencyText),
  ];

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(complaintActionProvider.notifier)
        .escalate(
          widget.complaintId,
          priority: _priority,
          reason: _reasonCtrl.text.trim(),
        );

    if (!mounted) return;
    if (success) {
      context.showSuccess('Complaint escalated to Corporator.');
      context.pop();
    } else {
      context.showError(ref.read(complaintActionProvider).errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(complaintActionProvider);

    return AppScaffold(
      title: 'Escalate Complaint',
      isBlueAppBar: true,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spaceXL),

              // Warning banner
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceMD),
                decoration: BoxDecoration(
                  color: AppColors.escalationLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(color: AppColors.escalation),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.escalation,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Escalating sends this complaint directly '
                        'to the Corporator for urgent attention. '
                        'Use this for serious issues.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.escalation,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              Text('Escalation Priority', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.spaceMD),

              // Priority selector
              Row(
                children: _priorities.map((p) {
                  final isActive = _priority == p.value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? p.color.withOpacity(0.1)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isActive ? p.color : AppColors.borderGrey,
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          p.label,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.captionMedium.copyWith(
                            color: isActive ? p.color : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              Text('Reason for Escalation', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.spaceSM),
              Text(
                'Clearly describe why this needs Corporator attention.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppDimensions.spaceMD),

              AppTextField(
                label: 'Reason',
                hint:
                    'e.g. Repeated complaints about same '
                    'water supply issue, no action in 2 weeks.',
                controller: _reasonCtrl,
                maxLines: 4,
                maxLength: 500,
                textInputAction: TextInputAction.done,
                validator: Validators.minLength('Reason', 5),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              PrimaryButton(
                label: 'Escalate to Corporator',
                icon: Icons.arrow_upward_rounded,
                backgroundColor: AppColors.escalation,
                isLoading: actionState.isLoading,
                onPressed: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Priority {
  const _Priority(this.value, this.label, this.color);
  final String value;
  final String label;
  final Color color;
}
