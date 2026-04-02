import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/screens/ops_login_screen.dart';
import '../../features/dashboard/screens/ops_dashboard_screen.dart';
import '../../features/corporators/screens/corporators_screen.dart';
import '../../features/corporators/screens/create_corporator_screen.dart';
import '../../features/corporators/screens/corporator_detail_screen.dart';
import '../../features/masters/screens/areas_screen.dart';
import '../../features/masters/screens/wards_screen.dart';
import '../../features/masters/screens/complaint_categories_screen.dart';
import '../../features/masters/screens/helpline_master_screen.dart';
import '../../shared/widgets/ops_shell.dart';
import '../constants/ops_constants.dart';

// ─────────────────────────────────────────────
// Route names
// ─────────────────────────────────────────────

class OpsRoutes {
  OpsRoutes._();
  static const login            = 'ops-login';
  static const dashboard        = 'ops-dashboard';
  static const corporators      = 'ops-corporators';
  static const createCorporator = 'ops-create-corporator';
  static const corporatorDetail = 'ops-corporator-detail';
  static const areas            = 'ops-areas';
  static const wards            = 'ops-wards';
  static const categories       = 'ops-categories';
  static const helpline         = 'ops-helpline';
}

// ─────────────────────────────────────────────
// Router
// ─────────────────────────────────────────────

final opsRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) async {
      const storage = FlutterSecureStorage();
      final token = await storage.read(
          key: OpsConstants.keyAccessToken);
      final role  = await storage.read(
          key: OpsConstants.keyRole);

      final isLoginPage =
          state.matchedLocation == '/login';

      if (token == null || role != 'ops') {
        return isLoginPage ? null : '/login';
      }
      if (isLoginPage) return '/dashboard';
      return null;
    },
    routes: [
      // ── Auth ─────────────────────────────
      GoRoute(
        path: '/login',
        name: OpsRoutes.login,
        builder: (_, __) => const OpsLoginScreen(),
      ),

      // ── Shell (sidebar layout) ────────────
      ShellRoute(
        builder: (context, state, child) =>
            OpsShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: OpsRoutes.dashboard,
            builder: (_, __) => const OpsDashboardScreen(),
          ),
          GoRoute(
            path: '/corporators',
            name: OpsRoutes.corporators,
            builder: (_, __) => const CorporatorsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: OpsRoutes.createCorporator,
                builder: (_, __) =>
                    const CreateCorporatorScreen(),
              ),
              GoRoute(
                path: ':id',
                name: OpsRoutes.corporatorDetail,
                builder: (_, state) => CorporatorDetailScreen(
                  corporatorId:
                      state.pathParameters['id'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/masters/areas',
            name: OpsRoutes.areas,
            builder: (_, __) => const AreasScreen(),
          ),
          GoRoute(
            path: '/masters/wards',
            name: OpsRoutes.wards,
            builder: (_, __) => const WardsScreen(),
          ),
          GoRoute(
            path: '/masters/categories',
            name: OpsRoutes.categories,
            builder: (_, __) =>
                const ComplaintCategoriesScreen(),
          ),
          GoRoute(
            path: '/masters/helpline',
            name: OpsRoutes.helpline,
            builder: (_, __) => const HelplineMasterScreen(),
          ),
        ],
      ),
    ],
  );
});