import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/storage/local_storage.dart';

Future<void> main() async {
  // ── Ensure Flutter is initialised before anything async ──
  WidgetsFlutterBinding.ensureInitialized();

  // ── Lock to portrait mode ─────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Transparent status bar ────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // ── Initialise local storage ──────────────────
  // Must complete before runApp so LocalStorage is ready
  await LocalStorage.init();

  // ── Run the app ───────────────────────────────
  runApp(const ProviderScope(child: JanSamparkApp()));
}
