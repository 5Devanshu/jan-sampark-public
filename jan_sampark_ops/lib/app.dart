import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/ops_colors.dart';
import 'features/complaints/screens/ops_complaints_screen.dart';

class OpsApp extends ConsumerWidget {
  const OpsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Jan Sampark Ops',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: OpsColors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: OpsColors.primary,
          primary: OpsColors.primary,
          surface: OpsColors.white,
        ),
      ),
      home: const Scaffold(
        body: SafeArea(
          child: OpsComplaintsScreen(),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
