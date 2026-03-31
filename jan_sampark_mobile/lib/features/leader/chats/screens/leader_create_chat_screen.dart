import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../models/leader_chat_models.dart';
import '../providers/leader_chat_provider.dart';

class LeaderCreateChatScreen extends ConsumerStatefulWidget {
  const LeaderCreateChatScreen({super.key});

  @override
  ConsumerState<LeaderCreateChatScreen> createState() =>
      _LeaderCreateChatScreenState();
}

class _LeaderCreateChatScreenState
    extends ConsumerState<LeaderCreateChatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // Targeting options
  final Set<String> _genders = {};
  final Set<String> _religions = {};

  static const _genderOptions = [
    _Chip('male', 'Male'),
    _Chip('female', 'Female'),
    _Chip('other', 'Other'),
  ];

  static const _religionOptions = [
    _Chip('hindu', 'Hindu'),
    _Chip('muslim', 'Muslim'),
    _Chip('christian', 'Christian'),
    _Chip('sikh', 'Sikh'),
    _Chip('buddhist', 'Buddhist'),
    _Chip('jain', 'Jain'),
    _Chip('other', 'Other'),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(createChatProvider.notifier)
        .create(
          CreateChatRequest(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim().isNotEmpty
                ? _descCtrl.text.trim()
                : null,
            targetGenders: _genders.toList(),
            targetReligions: _religions.toList(),
          ),
        );

    if (!mounted) return;

    if (success) {
      // Prepend new chat to list
      final chat = ref.read(createChatProvider).createdChat;
      if (chat != null) {
        ref.read(leaderChatListProvider.notifier).prependChat(chat);
      }
      context.showSuccess('Chat created.');
      context.pop();
    } else {
      final error = ref.read(createChatProvider).errorMessage;
      if (error.isNotEmpty) context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createChatProvider);

    return AppScaffold(
      title: 'Create Chat',
      isBlueAppBar: true,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spaceXL),

              // Title
              AppTextField(
                label: 'Chat Title',
                hint: 'e.g. Ward 14 Water Supply Update',
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                validator: Validators.required('Title'),
                prefixIcon: const Icon(
                  Icons.title_rounded,
                  size: AppDimensions.iconMD,
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Description
              AppTextField(
                label: 'Description (optional)',
                hint: 'Briefly describe this chat thread.',
                controller: _descCtrl,
                maxLines: 3,
                maxLength: 500,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              // Targeting header
              Text('Audience Targeting', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.spaceSM),
              Text(
                'Optionally limit who can see this chat. '
                'Leave blank to target all ward voters.',
                style: AppTextStyles.bodySecondary,
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Gender chips
              Text('Gender', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _genderOptions.map((o) {
                  final active = _genders.contains(o.value);
                  return _ToggleChip(
                    label: o.label,
                    isActive: active,
                    onTap: () => setState(() {
                      active ? _genders.remove(o.value) : _genders.add(o.value);
                    }),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Religion chips
              Text('Religion', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _religionOptions.map((o) {
                  final active = _religions.contains(o.value);
                  return _ToggleChip(
                    label: o.label,
                    isActive: active,
                    onTap: () => setState(() {
                      active
                          ? _religions.remove(o.value)
                          : _religions.add(o.value);
                    }),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              PrimaryButton(
                label: 'Create Chat',
                icon: Icons.forum_outlined,
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

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.borderGrey,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.captionMedium.copyWith(
            color: isActive ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _Chip {
  const _Chip(this.value, this.label);
  final String value;
  final String label;
}
