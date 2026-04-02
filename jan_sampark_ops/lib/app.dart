import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/ops_theme.dart';
import 'core/router/ops_router.dart';

class OpsApp extends ConsumerWidget {
  const OpsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(opsRouterProvider);

    return MaterialApp.router(
      title:           'Jan Sampark Ops',
      theme:           OpsTheme.light,
      routerConfig:    router,
      debugShowCheckedModeBanner: false,
    );
  }
}