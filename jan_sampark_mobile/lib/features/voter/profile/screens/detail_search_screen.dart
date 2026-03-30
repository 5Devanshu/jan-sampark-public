// lib/features/voter/profile/screens/detail_search_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/inputs/app_dropdown.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../providers/voter_profile_provider.dart';
import '../widgets/verification_step_indicator.dart';

class DetailSearchScreen extends ConsumerStatefulWidget {
  const DetailSearchScreen({super.key});

  @override
  ConsumerState<DetailSearchScreen> createState() =>
      _DetailSearchScreenState();
}

class _DetailSearchScreenState extends ConsumerState<DetailSearchScreen> {
  final _nameCtrl       = TextEditingController();
  final _stateCtrl      = TextEditingController();
  final _districtCtrl   = TextEditingController();
  final _captchaCtrl    = TextEditingController();
  final _fatherNameCtrl = TextEditingController();
  final _ageCtrl        = TextEditingController();
  String? _gender;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stateCtrl.dispose();
    _districtCtrl.dispose();
    _captchaCtrl.dispose();
    _fatherNameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(verificationProvider.notifier).searchByDetails(
      name:       _nameCtrl.text.trim(),
      stateCode:  _stateCtrl.text.trim().toUpperCase(),
      district:   _districtCtrl.text.trim(),
      captchaText: _captchaCtrl.text.trim(),
      fatherName: _fatherNameCtrl.text.trim().isEmpty
          ? null : _fatherNameCtrl.text.trim(),
      age:    int.tryParse(_ageCtrl.text.trim()),
      gender: _gender,
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
        title:   const Text('Search by Details'),
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
                      'Enter your personal details as they appear '
                      'on your voter ID card.',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 24),

                    AppTextField(
                      controller: _nameCtrl,
                      label: 'Full Name *',
                      hint:  'As on voter ID',
                      prefixIcon: Icons.person_outline,
                      validator: (v) =>
                          (v?.trim().isEmpty ?? true) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 14),

                    AppTextField(
                      controller: _stateCtrl,
                      label: 'State Code *',
                      hint:  'e.g. S13 for Maharashtra',
                      prefixIcon: Icons.map_outlined,
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) =>
                          (v?.trim().isEmpty ?? true) ? 'State code is required' : null,
                    ),
                    const SizedBox(height: 14),

                    AppTextField(
                      controller: _districtCtrl,
                      label: 'District *',
                      hint:  'ECI district code',
                      prefixIcon: Icons.location_city_outlined,
                      validator: (v) =>
                          (v?.trim().isEmpty ?? true) ? 'District is required' : null,
                    ),
                    const SizedBox(height: 14),

                    AppTextField(
                      controller: _captchaCtrl,
                      label: 'CAPTCHA Text *',
                      hint:  'Type what you see in the image',
                      prefixIcon: Icons.shield_outlined,
                      validator: (v) =>
                          (v?.trim().isEmpty ?? true) ? 'CAPTCHA is required' : null,
                    ),
                    const SizedBox(height: 14),

                    // ── Optional fields ─────────────────
                    AppTextField(
                      controller: _fatherNameCtrl,
                      label: "Father's / Husband's Name",
                      hint:  'Optional',
                      prefixIcon: Icons.family_restroom_outlined,
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _ageCtrl,
                            label: 'Age',
                            hint:  'Optional',
                            prefixIcon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppDropdown<String>(
                            label: 'Gender',
                            hint:  'Optional',
                            value: _gender,
                            items: const [
                              DropdownMenuItem(value: 'M', child: Text('Male')),
                              DropdownMenuItem(value: 'F', child: Text('Female')),
                            ],
                            onChanged: (v) => setState(() => _gender = v),
                          ),
                        ),
                      ],
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

                    const SizedBox(height: 32),
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
          color: AppColors.errorLight,
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