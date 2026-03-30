// lib/features/voter/profile/screens/epic_search_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../providers/voter_profile_provider.dart';
import '../widgets/verification_step_indicator.dart';

class EpicSearchScreen extends ConsumerStatefulWidget {
  const EpicSearchScreen({super.key});

  @override
  ConsumerState<EpicSearchScreen> createState() => _EpicSearchScreenState();
}

class _EpicSearchScreenState extends ConsumerState<EpicSearchScreen> {
  final _epicCtrl    = TextEditingController();
  final _stateCtrl   = TextEditingController();
  final _captchaCtrl = TextEditingController();
  final _formKey     = GlobalKey<FormState>();

  @override
  void dispose() {
    _epicCtrl.dispose();
    _stateCtrl.dispose();
    _captchaCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(verificationProvider.notifier).searchByEpic(
      epic:        _epicCtrl.text.trim().toUpperCase(),
      stateCode:   _stateCtrl.text.trim().toUpperCase(),
      captchaText: _captchaCtrl.text.trim(),
    );

    final step = ref.read(verificationProvider).step;
    if (!mounted) return;
    if (step == VerificationStep.result) {
      context.pushNamed(RouteNames.verificationResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    final verif = ref.watch(verificationProvider);
    final isSearching = verif.step == VerificationStep.searching;

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title:   const Text('Search by EPIC'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            VerificationStepIndicator(
              currentStep: 2,
              totalSteps:  3,
              labels: const ['Captcha', 'Search', 'Confirm'],
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
                  children: [
                    const SizedBox(height: 8),

                    Text(
                      'Enter your EPIC (Voter ID) number and the ECI '
                      'state code to find your voter record.',
                      style: AppTextStyles.bodySecondary,
                    ),

                    const SizedBox(height: 24),

                    AppTextField(
                      controller:   _epicCtrl,
                      label:        'EPIC Number',
                      hint:         'e.g. MH01234567',
                      prefixIcon:   Icons.credit_card_outlined,
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) => (v?.trim().isEmpty ?? true)
                          ? 'EPIC number is required' : null,
                    ),

                    const SizedBox(height: 16),

                    AppTextField(
                      controller:   _stateCtrl,
                      label:        'State Code',
                      hint:         'e.g. S13 for Maharashtra',
                      prefixIcon:   Icons.map_outlined,
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) => (v?.trim().isEmpty ?? true)
                          ? 'State code is required' : null,
                    ),

                    const SizedBox(height: 16),

                    AppTextField(
                      controller:  _captchaCtrl,
                      label:       'CAPTCHA Text',
                      hint:        'Type what you see in the image',
                      prefixIcon:  Icons.shield_outlined,
                      validator: (v) => (v?.trim().isEmpty ?? true)
                          ? 'CAPTCHA is required' : null,
                    ),

                    if (verif.step == VerificationStep.error &&
                        verif.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _ErrorBanner(message: verif.errorMessage!),
                    ],

                    const SizedBox(height: 28),

                    PrimaryButton(
                      label:     'Search ECI Database',
                      onPressed: isSearching ? null : _search,
                      isLoading: isSearching,
                      icon:      Icons.search,
                    ),

                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          context.pop();
                          context.pushNamed(RouteNames.detailSearch);
                        },
                        child: Text(
                          'Search by name instead',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding:     const EdgeInsets.all(12),
        decoration:  BoxDecoration(
          color:        AppColors.errorLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.errorBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.error, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      );
}