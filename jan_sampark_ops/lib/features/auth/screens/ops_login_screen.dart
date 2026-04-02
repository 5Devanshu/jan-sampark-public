import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/theme/ops_colors.dart';
import '../../../core/theme/ops_text_styles.dart';
import '../../../core/constants/ops_constants.dart';
import '../../../core/network/ops_dio_client.dart';

final _loginLoadingProvider = StateProvider<bool>((ref) => false);
final _loginErrorProvider   = StateProvider<String>((ref) => '');

class OpsLoginScreen extends ConsumerStatefulWidget {
  const OpsLoginScreen({super.key});

  @override
  ConsumerState<OpsLoginScreen> createState() =>
      _OpsLoginScreenState();
}

class _OpsLoginScreenState extends ConsumerState<OpsLoginScreen> {
  final _mobileCtrl   = TextEditingController(text: '9000000000');
  final _passwordCtrl = TextEditingController(text: 'Admin@1234!');

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    ref.read(_loginLoadingProvider.notifier).state = true;
    ref.read(_loginErrorProvider.notifier).state   = '';

    try {
      final dio = ref.read(opsDioProvider);
      final res = await dio.post(
        OpsConstants.endpointLogin,
        data: {
          'mobile':   _mobileCtrl.text.trim(),
          'password': _passwordCtrl.text,
        },
      );

      final data = res.data as Map<String, dynamic>;
      final role = data['role'] as String? ?? '';

      if (role != 'ops') {
        ref.read(_loginErrorProvider.notifier).state =
            'Access denied. Ops credentials required.';
        return;
      }

      const storage = FlutterSecureStorage();
      await Future.wait([
        storage.write(
          key:   OpsConstants.keyAccessToken,
          value: data['access_token'] as String? ?? '',
        ),
        storage.write(
          key:   OpsConstants.keyRefreshToken,
          value: data['refresh_token'] as String? ?? '',
        ),
        storage.write(
          key:   OpsConstants.keyUserId,
          value: data['user_id'] as String? ?? '',
        ),
        storage.write(
          key:   OpsConstants.keyRole,
          value: role,
        ),
        storage.write(
          key:   OpsConstants.keyFullName,
          value: data['full_name'] as String? ?? '',
        ),
      ]);

      if (mounted) context.go('/dashboard');
    } on DioException catch (e) {
      ref.read(_loginErrorProvider.notifier).state =
          e.response?.data?['detail'] as String? ??
              'Login failed. Please check your credentials.';
    } catch (_) {
      ref.read(_loginErrorProvider.notifier).state =
          'An unexpected error occurred.';
    } finally {
      ref.read(_loginLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(_loginLoadingProvider);
    final error     = ref.watch(_loginErrorProvider);

    return Scaffold(
      backgroundColor: OpsColors.surfaceGrey,
      body: Center(
        child: Container(
          width:  420,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color:        OpsColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: OpsColors.borderGrey),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withOpacity(0.06),
                blurRadius: 24,
                offset:     const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Row(
                children: [
                  Container(
                    width:  44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:        OpsColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.how_to_vote_rounded,
                        color: OpsColors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jan Sampark',
                          style: OpsTextStyles.heading3),
                      Text('Operations Console',
                          style: OpsTextStyles.caption),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Text('Sign In', style: OpsTextStyles.heading1),
              const SizedBox(height: 4),
              Text(
                'Enter your Ops credentials to access the console.',
                style: OpsTextStyles.bodySecondary,
              ),

              const SizedBox(height: 28),

              // Mobile
              _Label('Mobile Number'),
              const SizedBox(height: 6),
              TextField(
                controller:  _mobileCtrl,
                keyboardType: TextInputType.phone,
                style:        OpsTextStyles.body,
                decoration: const InputDecoration(
                  hintText: '10-digit mobile number',
                  prefixIcon: Icon(Icons.phone_outlined,
                      size: 18),
                ),
              ),

              const SizedBox(height: 20),

              // Password
              _Label('Password'),
              const SizedBox(height: 6),
              TextField(
                controller:   _passwordCtrl,
                obscureText:  true,
                style:        OpsTextStyles.body,
                onSubmitted:  (_) => _login(),
                decoration: const InputDecoration(
                  hintText: 'Your password',
                  prefixIcon: Icon(Icons.lock_outline_rounded,
                      size: 18),
                ),
              ),

              if (error.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color:        OpsColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: OpsColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: OpsColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(error,
                            style: OpsTextStyles.caption.copyWith(
                                color: OpsColors.error)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              SizedBox(
                width:  double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: OpsColors.white,
                          ),
                        )
                      : const Text('Sign In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: OpsTextStyles.fieldLabel);
  }
}