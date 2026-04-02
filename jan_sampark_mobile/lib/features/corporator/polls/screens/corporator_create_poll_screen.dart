import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/inputs/app_dropdown.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../../shared_widgets/dialogs/loading_dialog.dart';
import '../providers/corporator_poll_provider.dart';
import '../../../voter/polls/providers/poll_provider.dart';

class CorporatorCreatePollScreen extends ConsumerStatefulWidget {
  const CorporatorCreatePollScreen({super.key});

  @override
  ConsumerState<CorporatorCreatePollScreen> createState() =>
      _CorporatorCreatePollScreenState();
}

class _CorporatorCreatePollScreenState
    extends ConsumerState<CorporatorCreatePollScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _questionCtrl = TextEditingController();
  final _closesCtrl   = TextEditingController();

  String  _pollType    = 'multiple_choice';
  bool    _isAnonymous = true;
  bool    _showResults = true;

  // Options for multiple_choice / yes_no
  final List<TextEditingController> _optionCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];

  static const _pollTypes = {
    'multiple_choice': 'Multiple Choice',
    'yes_no':          'Yes / No',
    'rating':          'Rating (1–5 Stars)',
    'open_ended':      'Open Ended',
  };

  @override
  void dispose() {
    _questionCtrl.dispose();
    _closesCtrl.dispose();
    for (final c in _optionCtrls) { c.dispose(); }
    super.dispose();
  }

  Future<void> _pickDate() async {
    context.hideKeyboard();
    final picked = await showDatePicker(
      context:     context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate:   DateTime.now(),
      lastDate:    DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
              primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _closesCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _onSubmit() async {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;

    // Build options list for MC / YesNo
    List<String> options = [];
    if (_pollType == 'multiple_choice') {
      options = _optionCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (options.length < 2) {
        context.showError(
            'Please enter at least 2 options.');
        return;
      }
    } else if (_pollType == 'yes_no') {
      options = ['yes', 'no'];
    }

    LoadingDialog.show(context,
        message: 'Creating poll...');

    final success = await ref
        .read(createPollProvider.notifier)
        .create(
          question:    _questionCtrl.text.trim(),
          pollType:    _pollType,
          isAnonymous: _isAnonymous,
          showResults: _showResults,
          options:     options,
          closesAt:    _closesCtrl.text.trim().isNotEmpty
              ? _closesCtrl.text.trim()
              : null,
        );

    if (!mounted) return;
    LoadingDialog.hide(context);

    if (success) {
      ref.read(pollListProvider.notifier).load();
      context.showSuccess('Poll published successfully.');
      context.pop();
    } else {
      final error = ref.read(createPollProvider).errorMessage;
      if (error.isNotEmpty) context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPollProvider);

    return AppScaffold(
      title:       'Create Poll',
      isBlueAppBar: true,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
              AppDimensions.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spaceXL),

              // Poll type
              AppDropdown<String>(
                label:     'Poll Type',
                value:     _pollType,
                items:     dropdownItems(_pollTypes),
                onChanged: (v) => setState(() {
                  _pollType = v ?? _pollType;
                }),
                prefixIcon: const Icon(Icons.poll_outlined,
                    size: AppDimensions.iconMD),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Question
              AppTextField(
                label:          'Question',
                hint:           'e.g. How satisfied are you '
                    'with water supply in our ward?',
                controller:     _questionCtrl,
                maxLines:       3,
                maxLength:      500,
                textInputAction: TextInputAction.next,
                validator: Validators.minLength('Question', 5),
              ),

              // Options for multiple choice
              if (_pollType == 'multiple_choice') ...[
                const SizedBox(height: AppDimensions.spaceXL),
                Text('Answer Options',
                    style: AppTextStyles.heading3),
                const SizedBox(height: AppDimensions.spaceSM),
                Text(
                  'Add at least 2 options.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: AppDimensions.spaceMD),

                ..._optionCtrls.asMap().entries.map((entry) {
                  final i   = entry.key;
                  final ctrl = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.spaceMD),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label:          'Option ${i + 1}',
                            hint:           'Enter option text',
                            controller:     ctrl,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        if (i >= 2) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                                Icons.remove_circle_outline,
                                color: AppColors.error),
                            onPressed: () => setState(() {
                              ctrl.dispose();
                              _optionCtrls.removeAt(i);
                            }),
                          ),
                        ],
                      ],
                    ),
                  );
                }),

                if (_optionCtrls.length < 6)
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _optionCtrls.add(TextEditingController());
                    }),
                    icon:  const Icon(Icons.add_rounded,
                        size: 18),
                    label: const Text('Add Option'),
                  ),
              ],

              const SizedBox(height: AppDimensions.spaceXL),

              // Closes at
              AppTextField(
                label:      'Closes On (optional)',
                hint:       'YYYY-MM-DD',
                controller: _closesCtrl,
                isReadOnly: true,
                prefixIcon: const Icon(Icons.timer_outlined,
                    size: AppDimensions.iconMD),
                onTap: _pickDate,
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Toggles
              _Toggle(
                title:     'Anonymous Poll',
                subtitle:  'Voter identities are not stored.',
                value:     _isAnonymous,
                onChanged: (v) =>
                    setState(() => _isAnonymous = v),
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              _Toggle(
                title:     'Show Results to Voters',
                subtitle:  'Voters see results after voting.',
                value:     _showResults,
                onChanged: (v) =>
                    setState(() => _showResults = v),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              PrimaryButton(
                label:     'Publish Poll',
                icon:      Icons.poll_outlined,
                isLoading: state.isLoading,
                onPressed: _onSubmit,
              ),

              const SizedBox(height: AppDimensions.spaceXXL),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String   title;
  final String   subtitle;
  final bool     value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium),
                Text(subtitle,
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          Switch(
            value:    value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}