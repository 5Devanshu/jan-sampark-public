import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/inputs/app_dropdown.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../../shared_widgets/dialogs/loading_dialog.dart';
import '../providers/leader_announcement_provider.dart';

class LeaderCreateAnnouncementScreen extends ConsumerStatefulWidget {
  const LeaderCreateAnnouncementScreen({super.key});

  @override
  ConsumerState<LeaderCreateAnnouncementScreen> createState() =>
      _LeaderCreateAnnouncementScreenState();
}

class _LeaderCreateAnnouncementScreenState
    extends ConsumerState<LeaderCreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String? _category;

  static const _categoryOptions = {
    'announcement': 'General Announcement',
    'policy': 'Policy Update',
    'scheme': 'Government Scheme',
    'achievement': 'Achievement',
    'party_message': 'Party Message',
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      context.showError('Please select a category.');
      return;
    }

    LoadingDialog.show(context, message: 'Publishing announcement...');

    final success = await ref
        .read(createAnnouncementProvider.notifier)
        .create(
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          category: _category!,
        );

    if (!mounted) return;
    LoadingDialog.hide(context);

    if (success) {
      // Refresh the announcements list
      ref.read(announcementListProvider.notifier).load();
      context.showSuccess('Announcement published.');
      context.pop();
    } else {
      final error = ref.read(createAnnouncementProvider).errorMessage;
      if (error.isNotEmpty) context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createAnnouncementProvider);

    return AppScaffold(
      title: 'Create Announcement',
      isBlueAppBar: true,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spaceXL),

              // Category
              AppDropdown<String>(
                label: 'Category',
                value: _category,
                hint: 'Select announcement type',
                items: dropdownItems(_categoryOptions),
                onChanged: (v) => setState(() => _category = v),
                validator: (_) =>
                    _category == null ? 'Please select a category.' : null,
                prefixIcon: const Icon(
                  Icons.category_outlined,
                  size: AppDimensions.iconMD,
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Title
              AppTextField(
                label: 'Title',
                hint: 'e.g. New Water Pipeline Work Starting',
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                validator: Validators.required('Title'),
                prefixIcon: const Icon(
                  Icons.title_rounded,
                  size: AppDimensions.iconMD,
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Content
              AppTextField(
                label: 'Content',
                hint:
                    'Write the full announcement here. '
                    'Be clear and concise.',
                controller: _contentCtrl,
                maxLines: 8,
                maxLength: 5000,
                textInputAction: TextInputAction.done,
                validator: Validators.minLength('Content', 20),
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // Publish note
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
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This announcement will be immediately '
                        'visible to all voters in your ward.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              PrimaryButton(
                label: 'Publish Announcement',
                icon: Icons.campaign_outlined,
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
