import 'package:flutter/material.dart';
import 'app_colors.dart';

/// All text styles for Jan Sampark.
///
/// Uses the Inter font family throughout.
/// Every text in the app must reference one of these styles
/// — never use raw TextStyle() directly.
///
/// Usage:
///   Text('Hello', style: AppTextStyles.heading1)
class AppTextStyles {
  AppTextStyles._();

  // ─────────────────────────────────────────────
  // Display — large hero / splash text
  // ─────────────────────────────────────────────

  static const TextStyle display = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle displayWhite = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
    height: 1.25,
    letterSpacing: -0.5,
  );

  // ─────────────────────────────────────────────
  // Headings
  // ─────────────────────────────────────────────

  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
    letterSpacing: -0.2,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle heading3White = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
    height: 1.4,
  );

  // ─────────────────────────────────────────────
  // Body
  // ─────────────────────────────────────────────

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyLargeMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySemiBold = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyWhite = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnPrimary,
    height: 1.5,
  );

  // ─────────────────────────────────────────────
  // Caption / Small
  // ─────────────────────────────────────────────

  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle captionMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle captionPrimary = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    height: 1.5,
  );

  // ─────────────────────────────────────────────
  // Label
  // ─────────────────────────────────────────────

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0.3,
  );

  static const TextStyle labelSmallSecondary = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.3,
  );

  static const TextStyle labelSmallWhite = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
    height: 1.4,
    letterSpacing: 0.3,
  );

  // ─────────────────────────────────────────────
  // Button Labels
  // ─────────────────────────────────────────────

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.25,
    letterSpacing: 0.1,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.25,
    letterSpacing: 0.1,
  );

  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    height: 1.25,
  );

  // ─────────────────────────────────────────────
  // Form Field Labels / Errors
  // ─────────────────────────────────────────────

  static const TextStyle fieldLabel = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle fieldError = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    height: 1.4,
  );

  static const TextStyle fieldHelper = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ─────────────────────────────────────────────
  // Navigation Bar Labels
  // ─────────────────────────────────────────────

  static const TextStyle navLabel = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // ─────────────────────────────────────────────
  // Metric / Dashboard Numbers
  // ─────────────────────────────────────────────

  static const TextStyle metricLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle metricMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle metricSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.2,
  );

  // ─────────────────────────────────────────────
  // App Bar Title
  // ─────────────────────────────────────────────

  static const TextStyle appBarTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle appBarTitleWhite = TextStyle(
    fontFamily: 'Inter',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.3,
  );

  // ─────────────────────────────────────────────
  // Complaint Number / Code
  // ─────────────────────────────────────────────

  static const TextStyle codeLabel = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    height: 1.4,
    letterSpacing: 0.5,
  );
}
