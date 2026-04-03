import 'package:flutter/material.dart';

/// All colour constants for Jan Sampark Ops Console.
/// Blue and neutral corporate theme for admin/operations interface.
///
/// Never use raw hex values anywhere else in the codebase.
/// Always import and use OpsColors.[token].
class OpsColors {
  OpsColors._();

  // ─────────────────────────────────────────────
  // Primary Blue Palette
  // ─────────────────────────────────────────────

  /// Main brand blue — buttons, headers, active nav
  static const Color primary = Color(0xFF1A56DB);

  /// Pressed / darker blue — button pressed states
  static const Color primaryDark = Color(0xFF1E429F);

  /// Lightest blue — backgrounds, selection highlights
  static const Color primaryLight = Color(0xFFEBF5FF);

  /// Secondary action blue — secondary buttons, accents
  static const Color primaryAccent = Color(0xFF3F83F8);

  /// Blue ring used on focused elements
  static const Color primaryFocus = Color(0xFF76A9FA);

  // ─────────────────────────────────────────────
  // Neutral Palette
  // ─────────────────────────────────────────────

  /// Pure white — main background
  static const Color white = Color(0xFFFFFFFF);

  /// Very light grey — card and section backgrounds
  static const Color surfaceGrey = Color(0xFFF9FAFB);

  /// Card borders, dividers, subtle lines
  static const Color borderGrey = Color(0xFFE5E7EB);

  /// Input borders in resting state
  static const Color inputBorder = Color(0xFFD1D5DB);

  /// Darker grey for icons and secondary elements
  static const Color iconGrey = Color(0xFF9CA3AF);

  // ─────────────────────────────────────────────
  // Text Colours
  // ─────────────────────────────────────────────

  /// Primary text — headlines, body copy, labels
  static const Color textPrimary = Color(0xFF111827);

  /// Secondary text — subtitles, metadata
  static const Color textSecondary = Color(0xFF6B7280);

  /// Disabled or muted text
  static const Color textDisabled = Color(0xFF9CA3AF);

  /// White text on coloured backgrounds
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Hint text inside inputs
  static const Color textHint = Color(0xFFD1D5DB);

  // ─────────────────────────────────────────────
  // Semantic — Success
  // ─────────────────────────────────────────────

  static const Color success = Color(0xFF057A55);
  static const Color successLight = Color(0xFFDEF7EC);
  static const Color successBorder = Color(0xFF84E1BC);

  // ─────────────────────────────────────────────
  // Semantic — Warning
  // ─────────────────────────────────────────────

  static const Color warning = Color(0xFFC27803);
  static const Color warningLight = Color(0xFFFDF6B2);
  static const Color warningBorder = Color(0xFFFACA15);

  // ─────────────────────────────────────────────
  // Semantic — Error
  // ─────────────────────────────────────────────

  static const Color error = Color(0xFFE02424);
  static const Color errorLight = Color(0xFFFDE8E8);
  static const Color errorBorder = Color(0xFFF98080);

  // ─────────────────────────────────────────────
  // Semantic — Info
  // ─────────────────────────────────────────────

  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFCFF0FE);
  static const Color infoBorder = Color(0xFF7EE8F7);

  // ─────────────────────────────────────────────
  // Semantic — Escalation
  // ─────────────────────────────────────────────

  static const Color escalation = Color(0xFFFF5A1F);
  static const Color escalationLight = Color(0xFFFFECE2);
}
