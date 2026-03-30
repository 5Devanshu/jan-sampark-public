import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/router/route_names.dart';
import '../../../shared_widgets/buttons/primary_button.dart';
import '../../../shared_widgets/buttons/text_button_link.dart';
import '../../../shared_widgets/inputs/app_text_field.dart';
import '../providers/auth_notifier.dart';

/// Login screen — mobile number + password.
///
/// On success navigates to the correct home screen based on role.
/// GoRouter redirect handles role routing automatically after
/// authProvider state is updated.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _mobileCtrl  = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _mobileFocus  = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _passwordCtrl.dispose();
    _mobileFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(loginProvider.notifier).login(
          mobile:   _mobileCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    if (!mounted) return;

    if (success) {
      // GoRouter redirect will route to the correct home
      // based on the role stored in authProvider
      context.goNamed(RouteNames.voterHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    // Show error from notifier
    ref.listen<LoginState>(loginProvider, (_, next) {
      if (next.hasError && next.errorMessage.isNotEmpty) {
        context.showError(next.errorMessage);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Blue header ──────────────────────
              Container(
                width:  double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.pagePaddingH,
                  AppDimensions.space4XL,
                  AppDimensions.pagePaddingH,
                  AppDimensions.spaceXXL,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.white,
                          size: 18,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spaceXL),

                    Text(
                      'Welcome Back',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Login to your Jan Sampark account',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form ─────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppDimensions.spaceXL),

                      // Mobile field
                      AppTextField(
                        label:       'Mobile Number',
                        hint:        'Enter your 10-digit mobile number',
                        controller:  _mobileCtrl,
                        focusNode:   _mobileFocus,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator:   Validators.mobile,
                        onSubmitted: (_) =>
                            _passwordFocus.requestFocus(),
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          size: AppDimensions.iconMD,
                        ),
                        autofillHints: const [AutofillHints.telephoneNumber],
                      ),

                      const SizedBox(height: AppDimensions.spaceXL),

                      // Password field
                      AppTextField(
                        label:          'Password',
                        hint:           'Enter your password',
                        controller:     _passwordCtrl,
                        focusNode:      _passwordFocus,
                        isPassword:     true,
                        textInputAction: TextInputAction.done,
                        validator: Validators.required('Password'),
                        onSubmitted: (_) => _onLogin(),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          size: AppDimensions.iconMD,
                        ),
                        autofillHints: const [AutofillHints.password],
                      ),

                      const SizedBox(height: AppDimensions.spaceXXL),

                      // Login button
                      PrimaryButton(
                        label:     'Login',
                        onPressed: _onLogin,
                        isLoading: loginState.isLoading,
                      ),

                      const SizedBox(height: AppDimensions.spaceXL),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New to Jan Sampark? ',
                            style: AppTextStyles.bodySecondary,
                          ),
                          TextButtonLink(
                            label:     'Register',
                            onPressed: () =>
                                context.goNamed(RouteNames.otpSend),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.spaceLG),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}