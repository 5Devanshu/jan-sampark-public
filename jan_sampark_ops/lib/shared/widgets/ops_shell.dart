import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/theme/ops_colors.dart';
import '../../core/theme/ops_text_styles.dart';
import '../../core/router/ops_router.dart';
import '../../core/constants/ops_constants.dart';

/// Responsive shell with persistent sidebar.
/// On wide screens: sidebar + content.
/// On narrow screens (<800px): drawer.
class OpsShell extends ConsumerWidget {
  const OpsShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 800;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            const _Sidebar(),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: const Drawer(child: _Sidebar()),
      appBar: AppBar(
        backgroundColor:  OpsColors.sidebarBg,
        foregroundColor:  OpsColors.white,
        title: const Text('Jan Sampark Ops',
            style: TextStyle(color: OpsColors.white)),
      ),
      body: child,
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).matchedLocation;

    return Container(
      width: 240,
      color: OpsColors.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Brand ────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  width:  36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:        OpsColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.how_to_vote_rounded,
                      color: OpsColors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jan Sampark',
                        style: OpsTextStyles.bodyMedium
                            .copyWith(color: OpsColors.white)),
                    Text('Ops Console',
                        style: OpsTextStyles.caption
                            .copyWith(
                                color: OpsColors.sidebarText)),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),

          // ── Nav items ────────────────────────
          _NavItem(
            icon:     Icons.dashboard_outlined,
            label:    'Dashboard',
            route:    '/dashboard',
            isActive: loc.startsWith('/dashboard'),
          ),

          const SizedBox(height: 4),

          _SectionLabel(label: 'MANAGEMENT'),
          _NavItem(
            icon:     Icons.badge_outlined,
            label:    'Corporators',
            route:    '/corporators',
            isActive: loc.startsWith('/corporators'),
          ),

          const SizedBox(height: 4),

          _SectionLabel(label: 'MASTERS'),
          _NavItem(
            icon:     Icons.location_city_outlined,
            label:    'Areas',
            route:    '/masters/areas',
            isActive: loc == '/masters/areas',
          ),
          _NavItem(
            icon:     Icons.map_outlined,
            label:    'Wards',
            route:    '/masters/wards',
            isActive: loc == '/masters/wards',
          ),
          _NavItem(
            icon:     Icons.category_outlined,
            label:    'Complaint Categories',
            route:    '/masters/categories',
            isActive: loc == '/masters/categories',
          ),
          _NavItem(
            icon:     Icons.phone_outlined,
            label:    'Helpline Numbers',
            route:    '/masters/helpline',
            isActive: loc == '/masters/helpline',
          ),

          const Spacer(),

          // ── Logout ───────────────────────────
          const Divider(color: Colors.white12, height: 1),
          _LogoutButton(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        label,
        style: OpsTextStyles.caption.copyWith(
          color:         OpsColors.textDisabled,
          letterSpacing: 1.0,
          fontSize:      10,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
  });

  final IconData icon;
  final String   label;
  final String   route;
  final bool     isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 2),
      child: GestureDetector(
        onTap: () => context.go(route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? OpsColors.sidebarActive
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size:  18,
                color: isActive
                    ? OpsColors.white
                    : OpsColors.sidebarText,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: isActive
                      ? OpsTextStyles.sidebarItemActive
                      : OpsTextStyles.sidebarItem,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 8),
      child: GestureDetector(
        onTap: () async {
          const storage = FlutterSecureStorage();
          await storage.deleteAll();
          if (context.mounted) context.go('/login');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.logout_rounded,
                  size: 18, color: OpsColors.sidebarText),
              const SizedBox(width: 10),
              Text('Logout',
                  style: OpsTextStyles.sidebarItem),
            ],
          ),
        ),
      ),
    );
  }
}