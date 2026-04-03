import 'package:flutter/material.dart';
import 'ops_colors.dart';

/// All text styles for Jan Sampark Ops Console.
///
/// Uses the Inter font family throughout (Flutter default).
/// Every text in the app must reference one of these styles
/// — never use raw TextStyle() directly.
///
/// Usage:
///   Text('Hello', style: OpsTextStyles.heading1)
class OpsTextStyles {
  OpsTextStyles._();

  // ─────────────────────────────────────────────
  // Display — large hero / splash text
  // ─────────────────────────────────────────────

  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: OpsColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle displayWhite = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: OpsColors.textOnPrimary,
    height: 1.25,
    letterSpacing: -0.5,
  );

  // ─────────────────────────────────────────────
  // Headings
  // ─────────────────────────────────────────────

  static const TextStyle heading1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: OpsColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: OpsColors.textPrimary,
    height: 1.35,
    letterSpacing: -0.2,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: OpsColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle heading3White = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: OpsColors.textOnPrimary,
    height: 1.4,
  );

  // ─────────────────────────────────────────────
  // Body
  // ─────────────────────────────────────────────

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: OpsColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyLargeMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: OpsColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: OpsColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: OpsColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: OpsColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmallMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: OpsColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmallWhite = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: OpsColors.textOnPrimary,
    height: 1.5,
  );

  // ─────────────────────────────────────────────
  // Button Text
  // ─────────────────────────────────────────────

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: OpsColors.textOnPrimary,
    height: 1.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: OpsColors.textOnPrimary,
    height: 1.5,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: OpsColors.textOnPrimary,
    height: 1.4,
  );

  // ─────────────────────────────────────────────
  // Label / Badge
  // ─────────────────────────────────────────────

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: OpsColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: OpsColors.textSecondary,
    height: 1.35,
    letterSpacing: 0.2,
  );

  // ─────────────────────────────────────────────
  // Hint / Caption
  // ─────────────────────────────────────────────

  static const TextStyle hint = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: OpsColors.textHint,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: OpsColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle captionSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: OpsColors.textDisabled,
    height: 1.45,
  );
}
