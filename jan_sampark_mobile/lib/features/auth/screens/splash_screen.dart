import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/router/route_names.dart';

/// Splash screen shown on app cold start.
///
/// Displays the Jan Sampark logo for 2 seconds while checking
/// whether a valid session exists in secure storage.
///
/// After the delay:
///   - If session exists → navigate to role home
///   - If no session     → navigate to welcome
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();

    // ── Fade + scale animation ────────────────
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

    _ctrl.forward();

    // Navigate after 2.2 seconds
    Future.delayed(const Duration(milliseconds: 2200), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final hasSession = await SecureStorage.hasSession();
    if (!mounted) return;

    if (!hasSession) {
      context.goNamed(RouteNames.welcome);
      return;
    }

    final role = await SecureStorage.readUserRole();
    if (!mounted) return;

    switch (role) {
      case 'voter':
        context.goNamed(RouteNames.voterHome);
      case 'leader':
        context.goNamed(RouteNames.leaderHome);
      case 'corporator':
        context.goNamed(RouteNames.corporatorHome);
      default:
        context.goNamed(RouteNames.welcome);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo ────────────────────────
                Container(
                  width:  100,
                  height: 100,
                  decoration: BoxDecoration(
                    color:        AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:      Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset:     const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/images/logo_jan_sampark_icon.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.how_to_vote_rounded,
                      color:  AppColors.primary,
                      size:   56,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── App name ─────────────────────
                Text(
                  'Jan Sampark',
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Your Voice, Your Ward',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 60),

                // ── Loading indicator ─────────────
                SizedBox(
                  width:  24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color:       AppColors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}