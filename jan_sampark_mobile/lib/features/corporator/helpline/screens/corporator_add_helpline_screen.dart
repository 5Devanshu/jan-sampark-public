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
import '../../../voter/helpline/providers/helpline_provider.dart';
import '../providers/corporator_helpline_provider.dart';

class CorporatorAddHelplineScreen extends ConsumerStatefulWidget {
  const CorporatorAddHelplineScreen({super.key});

  @override
  ConsumerState<CorporatorAddHelplineScreen> createState() =>
      _CorporatorAddHelplineScreenState();
}

class _CorporatorAddHelplineScreenState
    extends ConsumerState<CorporatorAddHelplineScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _numCtrl   = TextEditingController();
  final _descCtrl  = TextEditingController();
  String _category = 'municipal';

  static const _categoryOptions = {
    'police':      'Police',
    'fire':        'Fire',
    'medical':     'Medical',
    'electricity': 'Electricity',
    'water':       'Water',
    'women':       'Women',
    'child':       'Child',
    'municipal':   'Municipal',
    'transport':   'Transport',
    'disaster':    'Disaster',
    'other':       'Other',
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(createHelplineProvider.notifier)
        .create(
          name:        _nameCtrl.text.trim(),
          number:      _numCtrl.text.trim(),
          category:    _category,
          description: _descCtrl.text.trim().isNotEmpty
              ? _descCtrl.text.trim()
              : null,
        );

    if (!mounted) return;
    if (success) {
      ref.read(helplineProvider.notifier).load();
      context.showSuccess('Helpline number added.');
      context.pop();
    } else {
      final error =
          ref.read(createHelplineProvider).errorMessage;
      if (error.isNotEmpty) context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createHelplineProvider);

    return AppScaffold(
      title:       'Add Helpline Number',
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

              Container(
                padding: const EdgeInsets.all(
                    AppDimensions.spaceMD),
                decoration: BoxDecoration(
                  color:        AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMD),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Custom numbers are visible only to '
                        'voters in your area. '
                        'Swipe left on the Helpline screen '
                        'to remove a number.',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              // Category
              AppDropdown<String>(
                label:     'Category',
                value:     _category,
                items:     dropdownItems(_categoryOptions),
                onChanged: (v) =>
                    setState(() => _category = v ?? _category),
                prefixIcon: const Icon(Icons.category_outlined,
                    size: AppDimensions.iconMD),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Name
              AppTextField(
                label:          'Service Name',
                hint:           'e.g. Ward Plumber',
                controller:     _nameCtrl,
                textInputAction: TextInputAction.next,
                validator:      Validators.required('Name'),
                prefixIcon: const Icon(Icons.badge_outlined,
                    size: AppDimensions.iconMD),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Number
              AppTextField(
                label:          'Phone Number',
                hint:           'e.g. 9876543210',
                controller:     _numCtrl,
                keyboardType:   TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator:      Validators.required(
                    'Phone Number'),
                prefixIcon: const Icon(Icons.phone_outlined,
                    size: AppDimensions.iconMD),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Description
              AppTextField(
                label:          'Description (optional)',
                hint:           'e.g. Available Mon–Sat, 9am–6pm',
                controller:     _descCtrl,
                maxLines:       2,
                maxLength:      200,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              PrimaryButton(
                label:     'Add Helpline Number',
                icon:      Icons.phone_outlined,
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