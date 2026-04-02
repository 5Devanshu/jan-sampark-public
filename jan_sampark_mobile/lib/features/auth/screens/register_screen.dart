import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/router/route_names.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared_widgets/buttons/primary_button.dart';
import '../../../shared_widgets/buttons/secondary_button.dart';
import '../../../shared_widgets/dialogs/loading_dialog.dart';
import '../models/auth_models.dart';
import '../providers/auth_notifier.dart';
import '../widgets/step_progress_indicator.dart';
import '../widgets/registration_step_one.dart';
import '../widgets/registration_step_two.dart';
import '../widgets/registration_step_three.dart';
import '../widgets/registration_step_four.dart';
import '../../../core/utils/file_picker_helper.dart';

/// Main registration screen — hosts the 4-step form.
///
/// Step 1: Personal info (name, password, gender, DOB, language)
/// Step 2: Location (area, ward)
/// Step 3: Demographics (religion, education, income, family)
/// Step 4: ID document upload
///
/// Each step has its own FormKey for independent validation.
/// Tapping Next validates only the current step.
/// Back does not require validation.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({
    super.key,
    required this.mobile,
    required this.verifiedToken,
  });

  final String mobile;
  final String verifiedToken;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _pageCtrl = PageController();

  // Per-step form keys
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  int _currentStep = 1;

  // ── Step 1 controllers ────────────────────
  final _fullNameCtrl    = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _dobCtrl         = TextEditingController();
  String? _gender;
  String? _language      = 'en';

  // ── Step 2 ────────────────────────────────
  String? _areaId;
  String? _wardId;

  // ── Step 3 controllers ────────────────────
  final _adultsCtrl = TextEditingController(text: '2');
  final _kidsCtrl   = TextEditingController(text: '0');
  String? _religion;
  String? _education;
  String? _occupation;
  String? _incomeRange;

  // ── Step 4 ────────────────────────────────
  String?     _documentType = 'voter_id';
  PickedFile? _pickedFile;
  bool        _skipDocument = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _fullNameCtrl.dispose();
    _passwordCtrl.dispose();
    _dobCtrl.dispose();
    _adultsCtrl.dispose();
    _kidsCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // Navigation
  // ─────────────────────────────────────────────

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageCtrl.animateToPage(
      step - 1,
      duration: const Duration(milliseconds: 300),
      curve:    Curves.easeInOut,
    );
  }

  Future<void> _onNext() async {
    context.hideKeyboard();

    switch (_currentStep) {
      case 1:
        if (!_step1Key.currentState!.validate()) return;
        _goToStep(2);

      case 2:
        if (!_step2Key.currentState!.validate()) return;
        if (_areaId == null) {
          context.showError('Please select your area.');
          return;
        }
        if (_wardId == null) {
          context.showError('Please select your ward.');
          return;
        }
        _goToStep(3);

      case 3:
        // Step 3 is optional — no required validation
        _goToStep(4);

      case 4:
        await _onSubmit();
    }
  }

  void _onBack() {
    context.hideKeyboard();
    if (_currentStep == 1) {
      Navigator.of(context).pop();
    } else {
      _goToStep(_currentStep - 1);
    }
  }

  // ─────────────────────────────────────────────
  // Submit
  // ─────────────────────────────────────────────

  Future<void> _onSubmit() async {
    LoadingDialog.show(context, message: 'Creating your account...');

    final request = RegisterRequest(
      mobile:            widget.mobile,
      verifiedToken:     widget.verifiedToken,
      fullName:          _fullNameCtrl.text.trim(),
      password:          _passwordCtrl.text,
      gender:            _gender ?? 'other',
      dateOfBirth:       _dobCtrl.text.trim(),
      language:          _language ?? 'en',
      religion:          _religion ?? '',
      wardId:            _wardId!,
      areaId:            _areaId!,
      education:         _education,
      occupation:        _occupation,
      annualIncomeRange: _incomeRange ?? '',
      familyAdults: int.tryParse(_adultsCtrl.text),
      familyKids:   int.tryParse(_kidsCtrl.text),
    );

    final documentPath = (!_skipDocument && _pickedFile != null)
        ? _pickedFile!.path
        : null;

    final success = await ref.read(registerProvider.notifier).register(
          request:      request,
          documentPath: documentPath,
        );

    if (!mounted) return;
    LoadingDialog.hide(context);

    if (success) {
      // GoRouter redirect handles routing to voter home
      context.goNamed(RouteNames.voterHome);
    } else {
      final error = ref.read(registerProvider).errorMessage;
      if (error.isNotEmpty) context.showError(error);
    }
  }

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerProvider);
    final isLastStep    = _currentStep == AppConstants.registrationTotalSteps;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePaddingH,
                vertical:   AppDimensions.spaceMD,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderGrey),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: _onBack,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:        AppColors.surfaceGrey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          'Create Account',
                          style: AppTextStyles.heading3,
                        ),
                      ),

                      // Step indicator text
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:        AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '$_currentStep / '
                          '${AppConstants.registrationTotalSteps}',
                          style: AppTextStyles.captionMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  StepProgressIndicator(currentStep: _currentStep),
                ],
              ),
            ),

            // ── Page content ─────────────────────
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics:    const NeverScrollableScrollPhysics(),
                children: [
                  // Step 1
                  Form(
                    key: _step1Key,
                    child: RegistrationStepOne(
                      fullNameCtrl:      _fullNameCtrl,
                      passwordCtrl:      _passwordCtrl,
                      dobCtrl:           _dobCtrl,
                      selectedGender:    _gender,
                      selectedLanguage:  _language,
                      onGenderChanged:   (v) => setState(() => _gender = v),
                      onLanguageChanged: (v) => setState(() => _language = v),
                    ),
                  ),

                  // Step 2
                  Form(
                    key: _step2Key,
                    child: RegistrationStepTwo(
                      selectedAreaId: _areaId,
                      selectedWardId: _wardId,
                      onAreaChanged:  (v) => setState(() {
                        _areaId = v;
                        _wardId = null; // Reset ward
                      }),
                      onWardChanged:  (v) => setState(() => _wardId = v),
                    ),
                  ),

                  // Step 3
                  Form(
                    key: _step3Key,
                    child: RegistrationStepThree(
                      selectedReligion:    _religion,
                      selectedEducation:   _education,
                      selectedOccupation:  _occupation,
                      selectedIncomeRange: _incomeRange,
                      familyAdultsCtrl:    _adultsCtrl,
                      familyKidsCtrl:      _kidsCtrl,
                      onReligionChanged:   (v) => setState(() => _religion  = v),
                      onEducationChanged:  (v) => setState(() => _education = v),
                      onOccupationChanged: (v) => setState(() => _occupation = v),
                      onIncomeRangeChanged:(v) => setState(() => _incomeRange= v),
                    ),
                  ),

                  // Step 4
                  RegistrationStepFour(
                    selectedDocumentType: _documentType,
                    pickedFile:           _pickedFile,
                    onDocumentTypeChanged: (v) =>
                        setState(() => _documentType = v),
                    onFilePicked: (f) => setState(() {
                      _pickedFile    = f;
                      _skipDocument  = false;
                    }),
                    onSkip: () => setState(() => _skipDocument = true),
                  ),
                ],
              ),
            ),

            // ── Bottom action buttons ─────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.pagePaddingH,
                AppDimensions.spaceMD,
                AppDimensions.pagePaddingH,
                AppDimensions.spaceMD +
                    MediaQuery.paddingOf(context).bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.borderGrey),
                ),
              ),
              child: Row(
                children: [
                  // Back button (hidden on step 1)
                  if (_currentStep > 1) ...[
                    Expanded(
                      child: SecondaryButton(
                        label:     'Back',
                        height:    AppDimensions.buttonHeightMD,
                        onPressed: _onBack,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceMD),
                  ],

                  // Next / Complete button
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: isLastStep
                          ? (_skipDocument
                              ? 'Complete Registration'
                              : 'Upload & Complete')
                          : 'Next',
                      onPressed: _onNext,
                      isLoading: registerState.isLoading,
                      icon: isLastStep
                          ? Icons.check_circle_outline_rounded
                          : null,
                      height: AppDimensions.buttonHeightMD,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
