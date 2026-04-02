import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/file_picker_helper.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/inputs/app_dropdown.dart';
import '../../../../shared_widgets/inputs/image_upload_field.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../../shared_widgets/dialogs/loading_dialog.dart';
import '../providers/corporator_campaign_provider.dart';

class CreateCampaignScreen extends ConsumerStatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  ConsumerState<CreateCampaignScreen> createState() =>
      _CreateCampaignScreenState();
}

class _CreateCampaignScreenState
    extends ConsumerState<CreateCampaignScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _titleCtrl      = TextEditingController();
  final _descCtrl       = TextEditingController();
  final _targetCtrl     = TextEditingController();
  final _startDateCtrl  = TextEditingController();
  final _endDateCtrl    = TextEditingController();
  String?     _campaignType;
  PickedFile? _coverImage;

  static const _campaignTypes = {
    'fundraising':    'Fundraising',
    'infrastructure': 'Infrastructure',
    'welfare':        'Welfare',
    'health':         'Health',
    'education':      'Education',
    'environment':    'Environment',
    'other':          'Other',
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _targetCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    context.hideKeyboard();
    final picked = await showDatePicker(
      context:     context,
      initialDate: DateTime.now(),
      firstDate:   DateTime.now().subtract(
          const Duration(days: 1)),
      lastDate:    DateTime.now().add(
          const Duration(days: 730)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
              primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _onSubmit() async {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;
    if (_campaignType == null) {
      context.showError('Please select a campaign type.');
      return;
    }

    LoadingDialog.show(context,
        message: 'Creating campaign...');

    final success = await ref
        .read(createCampaignProvider.notifier)
        .create(
          title:          _titleCtrl.text.trim(),
          description:    _descCtrl.text.trim(),
          campaignType:   _campaignType!,
          targetAmount:   double.tryParse(
                  _targetCtrl.text.trim()) ??
              0.0,
          startDate:      _startDateCtrl.text.trim(),
          endDate:        _endDateCtrl.text.trim(),
          coverImagePath: _coverImage?.path,
        );

    if (!mounted) return;
    LoadingDialog.hide(context);

    if (success) {
      ref.read(campaignListProvider.notifier).load();
      context.showSuccess('Campaign created successfully.');
      context.pop();
    } else {
      final error = ref.read(createCampaignProvider).errorMessage;
      if (error.isNotEmpty) context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createCampaignProvider);

    return AppScaffold(
      title:       'Create Campaign',
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

              // Campaign type
              AppDropdown<String>(
                label:     'Campaign Type',
                value:     _campaignType,
                items:     dropdownItems(_campaignTypes),
                onChanged: (v) =>
                    setState(() => _campaignType = v),
                validator: (_) => _campaignType == null
                    ? 'Required'
                    : null,
                prefixIcon: const Icon(Icons.category_outlined,
                    size: AppDimensions.iconMD),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Title
              AppTextField(
                label:          'Campaign Title',
                hint:           'e.g. Ward 14 Playground Renovation',
                controller:     _titleCtrl,
                textInputAction: TextInputAction.next,
                validator:      Validators.required('Title'),
                prefixIcon: const Icon(Icons.title_rounded,
                    size: AppDimensions.iconMD),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Description
              AppTextField(
                label:          'Description',
                hint:           'Describe the campaign purpose and goals...',
                controller:     _descCtrl,
                maxLines:       4,
                maxLength:      2000,
                textInputAction: TextInputAction.next,
                validator: Validators.minLength(
                    'Description', 20),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Target amount
              AppTextField(
                label:          'Target Amount (₹)',
                hint:           'e.g. 50000',
                controller:     _targetCtrl,
                keyboardType: const TextInputType
                    .numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator:      Validators.donationAmount,
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text('₹', style: AppTextStyles.heading3),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[\d.]')),
                ],
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Date row
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label:      'Start Date',
                      hint:       'YYYY-MM-DD',
                      controller: _startDateCtrl,
                      isReadOnly: true,
                      validator:  Validators.required('Start Date'),
                      prefixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          size: AppDimensions.iconMD),
                      onTap: () => _pickDate(_startDateCtrl),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMD),
                  Expanded(
                    child: AppTextField(
                      label:      'End Date',
                      hint:       'YYYY-MM-DD',
                      controller: _endDateCtrl,
                      isReadOnly: true,
                      validator:  Validators.required('End Date'),
                      prefixIcon: const Icon(
                          Icons.event_outlined,
                          size: AppDimensions.iconMD),
                      onTap: () => _pickDate(_endDateCtrl),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Cover image
              ImageUploadField(
                label:     'Cover Image',
                onPicked:  (f) =>
                    setState(() => _coverImage = f),
                helperText: 'Optional — shown on the campaign card.',
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              PrimaryButton(
                label:     'Create Campaign',
                icon:      Icons.volunteer_activism_outlined,
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