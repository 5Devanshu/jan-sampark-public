import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../storage/secure_storage.dart';
import '../storage/local_storage.dart';
import 'route_names.dart';

/// Route guard logic for GoRouter's [redirect] callback.
///
/// Three checks on every navigation:
///   1. No session token  → redirect to /welcome
///   2. Has session       → redirect away from auth screens
///   3. Role mismatch     → redirect to correct home screen
///
/// The guard is synchronous where possible (reading cached role
/// from SharedPreferences) to avoid navigation flicker.
class RouteGuard {
  RouteGuard._();

  /// The main redirect function passed to GoRouter.
  /// Called on every navigation event.
  static Future<String?> redirect(GoRouterState state) async {
    final path = state.matchedLocation;
    final isAuth = _isAuthRoute(path);

    // Check token presence
    final hasSession = await SecureStorage.hasSession();

    // ── Not logged in ──────────────────────────
    if (!hasSession) {
      if (isAuth) return null; // Allow auth routes
      return '/welcome'; // Redirect everything else
    }

    // ── Already logged in, on auth screen ──────
    if (isAuth && path != '/splash') {
      final role = LocalStorage.getLastKnownRole();
      return _homeForRole(role);
    }

    // ── Role-based routing from splash ─────────
    if (path == '/splash') {
      final role = await SecureStorage.readUserRole();
      if (role != null) {
        LocalStorage.setLastKnownRole(role);
        return _homeForRole(role);
      }
      return '/welcome';
    }

    return null; // No redirect needed
  }

  static bool _isAuthRoute(String path) =>
      path.startsWith('/welcome') ||
      path.startsWith('/login') ||
      path.startsWith('/otp') ||
      path.startsWith('/register') ||
      path == '/splash';

  static String _homeForRole(String? role) {
    return switch (role) {
      'voter' => '/voter/home',
      'leader' => '/leader/home',
      'corporator' => '/corporator/home',
      _ => '/welcome',
    };
  }
}
