import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/dio_client.dart';
import 'core/providers/auth_provider.dart';
import 'core/router/app_router.dart';
import 'core/router/route_names.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/locale_provider.dart';

/// Root application widget.
///
/// Consumes the router and locale providers from Riverpod.
/// The ProviderScope is created in main.dart — not here —
/// so that overrides can be passed during testing.
class JanSamparkApp extends ConsumerWidget {
  const JanSamparkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      // ── Identity ──────────────────────────────
      title:       'Jan Sampark',
      debugShowCheckedModeBanner: false,

      // ── Theme ─────────────────────────────────
      theme:       AppTheme.light,
      themeMode:   ThemeMode.light,

      // ── Router ────────────────────────────────
      routerConfig: router,

      // ── Localisation ──────────────────────────
      locale:             locale,
      supportedLocales:   appSupportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Builder — injects session expired callback ──
      builder: (context, child) {
        // Set the session expired callback on the Dio client
        // so it can navigate to login when refresh fails.
        // This runs once after the first frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          DioClient.setSessionExpiredCallback(() {
            ref.read(authProvider.notifier).signOut();
            router.goNamed(RouteNames.welcome);
          });
        });

        return child ?? const SizedBox.shrink();
      },
    );
  }
}