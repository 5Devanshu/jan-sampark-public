import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'route_names.dart';
import 'route_guards.dart';

// ── Auth screens (stubs — replaced in Module 7) ──
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_send_screen.dart';
import '../../features/auth/screens/otp_verify_screen.dart';
import '../../features/auth/screens/register_screen.dart';

// ── Voter shell (stub — replaced in Module 8) ────
import '../../features/voter/dashboard/screens/voter_home_screen.dart';

// ── Module 9 profile imports
import '../../features/voter/profile/screens/voter_profile_screen.dart';
import '../../features/voter/profile/screens/edit_profile_screen.dart';
import '../../features/voter/profile/screens/ocr_status_screen.dart';
import '../../features/voter/profile/screens/verification_intro_screen.dart';
import '../../features/voter/profile/screens/captcha_screen.dart';
import '../../features/voter/profile/screens/epic_search_screen.dart';
import '../../features/voter/profile/screens/detail_search_screen.dart';
import '../../features/voter/profile/screens/verification_result_screen.dart';
import '../../features/voter/profile/screens/verification_success_screen.dart';

// ── Leader shell (stub — replaced in Module 15) ──
import '../../features/leader/dashboard/screens/leader_home_screen.dart';

// ── Corporator shell (stub — replaced in Module 17) ─
import '../../features/corporator/dashboard/screens/corporator_home_screen.dart';
import '../../features/corporator/campaigns/screens/pending_donations_screen.dart';

// ── Notifications (stub — replaced in Module 20) ─
import '../../features/notifications/screens/notifications_screen.dart';

/// GoRouter provider for Jan Sampark.
///
/// Provides the router instance to the entire app via Riverpod.
/// Route guards run on every navigation event via [redirect].
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation:  '/splash',
    debugLogDiagnostics: false,
    redirect:         RouteGuard.redirect,

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),

    routes: [
      // ────────────────────────────────────────
      // Auth Routes
      // ────────────────────────────────────────

      GoRoute(
        path:  '/splash',
        name:  RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),

      GoRoute(
        path:  '/welcome',
        name:  RouteNames.welcome,
        builder: (_, __) => const WelcomeScreen(),
      ),

      GoRoute(
        path:  '/login',
        name:  RouteNames.login,
        builder: (_, __) => const LoginScreen(),
      ),

      GoRoute(
        path:  '/otp-send',
        name:  RouteNames.otpSend,
        builder: (_, __) => const OtpSendScreen(),
      ),

      GoRoute(
        path:  '/otp-verify',
        name:  RouteNames.otpVerify,
        builder: (context, state) {
          final mobile = state.extra as String? ?? '';
          return OtpVerifyScreen(mobile: mobile);
        },
      ),

      GoRoute(
        path:  '/register',
        name:  RouteNames.register,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return RegisterScreen(
            mobile:         data['mobile'] as String? ?? '',
            verifiedToken:  data['verified_token'] as String? ?? '',
          );
        },
      ),

      // ────────────────────────────────────────
      // Voter Routes
      // ────────────────────────────────────────

      ShellRoute(
        builder: (context, state, child) => VoterShell(child: child),
        routes: [
          GoRoute(
            path:  '/voter/home',
            name:  RouteNames.voterHome,
            builder: (_, __) => const VoterHomeScreen(),
          ),
          GoRoute(
            path:    '/voter/complaints',
            name:    RouteNames.voterComplaints,
            builder: (_, __) => const VoterComplaintsPlaceholder(),
            routes: [
              GoRoute(
                path:    'file',
                name:    RouteNames.fileComplaint,
                builder: (_, __) => const Placeholder(),
              ),
              GoRoute(
                path:    ':id',
                name:    RouteNames.complaintDetail,
                builder: (_, state) => ComplaintDetailPlaceholder(
                  id: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path:    'feedback',
                    name:    RouteNames.complaintFeedback,
                    builder: (_, state) => Placeholder(
                      key: ValueKey(state.pathParameters['id']),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path:    '/voter/campaigns',
            name:    RouteNames.voterCampaigns,
            builder: (_, __) => const VoterCampaignsPlaceholder(),
            routes: [
              GoRoute(
                path:    ':id',
                name:    RouteNames.campaignDetail,
                builder: (_, state) => Placeholder(
                  key: ValueKey(state.pathParameters['id']),
                ),
                routes: [
                  GoRoute(
                    path:    'donate',
                    name:    RouteNames.donate,
                    builder: (_, __) => const Placeholder(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path:    '/voter/events',
            name:    RouteNames.voterEvents,
            builder: (_, __) => const VoterEventsPlaceholder(),
            routes: [
              GoRoute(
                path:    ':id',
                name:    RouteNames.eventDetail,
                builder: (_, state) => Placeholder(
                  key: ValueKey(state.pathParameters['id']),
                ),
              ),
              GoRoute(
                path:    'my-registrations',
                name:    RouteNames.myRegistrations,
                builder: (_, __) => const Placeholder(),
              ),
            ],
          ),
          GoRoute(
            path:  '/voter/profile',
            name:  RouteNames.voterProfile,
            builder: (_, __) => const VoterProfileScreen(),
            routes: [
              GoRoute(
                path:    'edit',
                name:    RouteNames.editProfile,
                builder: (context, state) {
                  final section =
                      state.uri.queryParameters['section'] ?? 'basic';
                  return EditProfileScreen(initialSection: section);
                },
              ),
              GoRoute(
                path:    'ocr-status',
                name:    RouteNames.voterOcrStatus,
                builder: (_, __) => const OcrStatusScreen(),
              ),
              GoRoute(
                path:    'verify',
                name:    RouteNames.verificationIntro,
                builder: (_, __) => const VerificationIntroScreen(),
                routes: [
                  GoRoute(
                    path:    'captcha',
                    name:    RouteNames.captchaScreen,
                    builder: (_, __) => const CaptchaScreen(),
                  ),
                  GoRoute(
                    path:    'epic-search',
                    name:    RouteNames.epicSearch,
                    builder: (_, __) => const EpicSearchScreen(),
                  ),
                  GoRoute(
                    path:    'detail-search',
                    name:    RouteNames.detailSearch,
                    builder: (_, __) => const DetailSearchScreen(),
                  ),
                  GoRoute(
                    path:    'result',
                    name:    RouteNames.verificationResult,
                    builder: (_, __) => const VerificationResultScreen(),
                  ),
                  GoRoute(
                    path:    'success',
                    name:    RouteNames.verificationSuccess,
                    builder: (_, __) => const VerificationSuccessScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Voter routes outside shell
      GoRoute(
        path:  '/voter/chats',
        name:  RouteNames.voterChats,
        builder: (_, __) => const Placeholder(),
        routes: [
          GoRoute(
            path:    ':id',
            name:    RouteNames.voterChatRoom,
            builder: (_, state) => Placeholder(
              key: ValueKey(state.pathParameters['id']),
            ),
          ),
        ],
      ),
      GoRoute(
        path:    '/voter/announcements',
        name:    RouteNames.voterAnnouncements,
        builder: (_, __) => const Placeholder(),
        routes: [
          GoRoute(
            path:    ':id',
            name:    RouteNames.voterAnnouncementDetail,
            builder: (_, state) => Placeholder(
              key: ValueKey(state.pathParameters['id']),
            ),
          ),
        ],
      ),
      GoRoute(
        path:    '/voter/polls',
        name:    RouteNames.voterPolls,
        builder: (_, __) => const Placeholder(),
        routes: [
          GoRoute(
            path:    ':id/vote',
            name:    RouteNames.voterPollVote,
            builder: (_, state) => Placeholder(
              key: ValueKey(state.pathParameters['id']),
            ),
          ),
          GoRoute(
            path:    ':id/results',
            name:    RouteNames.voterPollResults,
            builder: (_, state) => Placeholder(
              key: ValueKey(state.pathParameters['id']),
            ),
          ),
        ],
      ),
      GoRoute(
        path:  '/helpline',
        name:  RouteNames.helpline,
        builder: (_, __) => const Placeholder(),
      ),

      // ────────────────────────────────────────
      // Leader Routes
      // ────────────────────────────────────────

      ShellRoute(
        builder: (context, state, child) => LeaderShell(child: child),
        routes: [
          GoRoute(
            path:  '/leader/home',
            name:  RouteNames.leaderHome,
            builder: (_, __) => const LeaderHomeScreen(),
          ),
          GoRoute(
            path:    '/leader/complaints',
            name:    RouteNames.leaderComplaints,
            builder: (_, __) => const Placeholder(),
            routes: [
              GoRoute(
                path:    ':id',
                name:    RouteNames.leaderComplaintDetail,
                builder: (_, state) => Placeholder(
                  key: ValueKey(state.pathParameters['id']),
                ),
              ),
            ],
          ),
          GoRoute(
            path:    '/leader/voters',
            name:    RouteNames.leaderVoters,
            builder: (_, __) => const Placeholder(),
            routes: [
              GoRoute(
                path:    ':id',
                name:    RouteNames.voterProfileView,
                builder: (_, state) => Placeholder(
                  key: ValueKey(state.pathParameters['id']),
                ),
              ),
            ],
          ),
          GoRoute(
            path:    '/leader/events',
            name:    RouteNames.leaderEvents,
            builder: (_, __) => const Placeholder(),
            routes: [
              GoRoute(
                path:    'create',
                name:    RouteNames.createEvent,
                builder: (_, __) => const Placeholder(),
              ),
              GoRoute(
                path:    ':id',
                name:    RouteNames.leaderEventManagement,
                builder: (_, state) => Placeholder(
                  key: ValueKey(state.pathParameters['id']),
                ),
                routes: [
                  GoRoute(
                    path:    'attendance',
                    name:    RouteNames.attendanceScreen,
                    builder: (_, __) => const Placeholder(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path:    '/leader/profile',
            name:    RouteNames.leaderProfile,
            builder: (_, __) => const Placeholder(),
          ),
        ],
      ),

      // ────────────────────────────────────────
      // Corporator Routes
      // ────────────────────────────────────────

      ShellRoute(
        builder: (context, state, child) => CorporatorShell(child: child),
        routes: [
          GoRoute(
            path:  '/corporator/home',
            name:  RouteNames.corporatorHome,
            builder: (_, __) => const CorporatorHomeScreen(),
          ),
          GoRoute(
            path:    '/corporator/complaints',
            name:    RouteNames.corporatorComplaints,
            builder: (_, __) => const Placeholder(),
            routes: [
              GoRoute(
                path:    ':id',
                name:    RouteNames.corporatorComplaintDetail,
                builder: (_, state) => Placeholder(
                  key: ValueKey(state.pathParameters['id']),
                ),
              ),
              GoRoute(
                path:    'escalated',
                name:    RouteNames.escalatedInbox,
                builder: (_, __) => const Placeholder(),
              ),
            ],
          ),
          GoRoute(
            path:    '/corporator/analytics',
            name:    RouteNames.corporatorAnalytics,
            builder: (_, __) => const Placeholder(),
            routes: [
              GoRoute(
                path:  'voters',
                name:  RouteNames.voterAnalytics,
                builder: (_, __) => const Placeholder(),
              ),
              GoRoute(
                path:  'complaints',
                name:  RouteNames.complaintAnalytics,
                builder: (_, __) => const Placeholder(),
              ),
              GoRoute(
                path:  'campaigns',
                name:  RouteNames.campaignAnalytics,
                builder: (_, __) => const Placeholder(),
              ),
              GoRoute(
                path:  'events',
                name:  RouteNames.eventAnalyticsScreen,
                builder: (_, __) => const Placeholder(),
              ),
              GoRoute(
                path:  'leaders',
                name:  RouteNames.leaderAnalytics,
                builder: (_, __) => const Placeholder(),
              ),
              GoRoute(
                path:  'heatmap',
                name:  RouteNames.wardHeatmap,
                builder: (_, __) => const Placeholder(),
              ),
            ],
          ),
          GoRoute(
            path:    '/corporator/manage',
            name:    RouteNames.corporatorManage,
            builder: (_, __) => const Placeholder(),
          ),
          GoRoute(
            path:    '/corporator/profile',
            name:    RouteNames.corporatorProfile,
            builder: (_, __) => const Placeholder(),
          ),
        ],
      ),

      // ────────────────────────────────────────
      // Shared Routes
      // ────────────────────────────────────────

      GoRoute(
        path:    '/corporator/campaigns/:id/pending',
        name:    RouteNames.pendingDonations,
        builder: (_, state) => PendingDonationsScreen(
          campaignId: state.pathParameters['id']!,
        ),
      ),

      GoRoute(
        path:  '/notifications',
        name:  RouteNames.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
    ],
  );
});

// ─────────────────────────────────────────────
// Shell Widgets — Bottom Navigation Wrappers
// (full implementations in Module 8 / 15 / 17)
// ─────────────────────────────────────────────

class VoterShell extends StatelessWidget {
  const VoterShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _VoterBottomNav(),
    );
  }
}

class _VoterBottomNav extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    int selectedIndex = 0;
    if (location.startsWith('/voter/complaints')) selectedIndex = 1;
    if (location.startsWith('/voter/campaigns'))  selectedIndex = 2;
    if (location.startsWith('/voter/events'))     selectedIndex = 3;
    if (location.startsWith('/voter/profile'))    selectedIndex = 4;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.navBarBorder, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) {
          final routes = [
            '/voter/home',
            '/voter/complaints',
            '/voter/campaigns',
            '/voter/events',
            '/voter/profile',
          ];
          context.go(routes[i]);
        },
        items: const [
          BottomNavigationBarItem(
            icon:      Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label:     'Home',
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.report_problem_outlined),
            activeIcon: Icon(Icons.report_problem),
            label:      'Complaints',
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label:      'Campaigns',
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label:      'Events',
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label:      'Profile',
          ),
        ],
      ),
    );
  }
}

class LeaderShell extends StatelessWidget {
  const LeaderShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int selectedIndex = 0;
    if (location.startsWith('/leader/complaints')) selectedIndex = 1;
    if (location.startsWith('/leader/voters'))     selectedIndex = 2;
    if (location.startsWith('/leader/events'))     selectedIndex = 3;
    if (location.startsWith('/leader/profile'))    selectedIndex = 4;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.navBarBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (i) {
            final routes = [
              '/leader/home',
              '/leader/complaints',
              '/leader/voters',
              '/leader/events',
              '/leader/profile',
            ];
            context.go(routes[i]);
          },
          items: const [
            BottomNavigationBarItem(
              icon:       Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label:      'Home',
            ),
            BottomNavigationBarItem(
              icon:       Icon(Icons.report_problem_outlined),
              activeIcon: Icon(Icons.report_problem),
              label:      'Complaints',
            ),
            BottomNavigationBarItem(
              icon:       Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label:      'Voters',
            ),
            BottomNavigationBarItem(
              icon:       Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label:      'Events',
            ),
            BottomNavigationBarItem(
              icon:       Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label:      'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class CorporatorShell extends StatelessWidget {
  const CorporatorShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int selectedIndex = 0;
    if (location.startsWith('/corporator/complaints')) selectedIndex = 1;
    if (location.startsWith('/corporator/analytics'))  selectedIndex = 2;
    if (location.startsWith('/corporator/manage'))     selectedIndex = 3;
    if (location.startsWith('/corporator/profile'))    selectedIndex = 4;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.navBarBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (i) {
            final routes = [
              '/corporator/home',
              '/corporator/complaints',
              '/corporator/analytics',
              '/corporator/manage',
              '/corporator/profile',
            ];
            context.go(routes[i]);
          },
          items: const [
            BottomNavigationBarItem(
              icon:       Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label:      'Home',
            ),
            BottomNavigationBarItem(
              icon:       Icon(Icons.report_problem_outlined),
              activeIcon: Icon(Icons.report_problem),
              label:      'Complaints',
            ),
            BottomNavigationBarItem(
              icon:       Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label:      'Analytics',
            ),
            BottomNavigationBarItem(
              icon:       Icon(Icons.manage_accounts_outlined),
              activeIcon: Icon(Icons.manage_accounts),
              label:      'Manage',
            ),
            BottomNavigationBarItem(
              icon:       Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label:      'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Temporary stub screens — replaced module by module
// ─────────────────────────────────────────────

class VoterComplaintsPlaceholder extends StatelessWidget {
  const VoterComplaintsPlaceholder({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Complaints — coming in Module 10')));
}

class VoterCampaignsPlaceholder extends StatelessWidget {
  const VoterCampaignsPlaceholder({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Campaigns — coming in Module 11')));
}

class VoterEventsPlaceholder extends StatelessWidget {
  const VoterEventsPlaceholder({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Events — coming in Module 12')));
}

class VoterProfilePlaceholder extends StatelessWidget {
  const VoterProfilePlaceholder({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Profile — coming in Module 9')));
}

class ComplaintDetailPlaceholder extends StatelessWidget {
  const ComplaintDetailPlaceholder({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Complaint $id detail')));
}
