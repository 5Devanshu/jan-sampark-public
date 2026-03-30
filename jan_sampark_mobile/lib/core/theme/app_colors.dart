import 'package:flutter/material.dart';

/// All colour constants for Jan Sampark.
/// White and blue corporate theme.
///
/// Never use raw hex values anywhere else in the codebase.
/// Always import and use AppColors.[token].
class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────
  // Primary Blue Palette
  // ─────────────────────────────────────────────

  /// Main brand blue — buttons, app bar, active nav, links
  static const Color primary = Color(0xFF1A56DB);

  /// Pressed / darker blue — button pressed states
  static const Color primaryDark = Color(0xFF1E429F);

  /// Lightest blue — card backgrounds, chip fills, selection highlights
  static const Color primaryLight = Color(0xFFEBF5FF);

  /// Secondary action blue — info badges, secondary buttons
  static const Color primaryAccent = Color(0xFF3F83F8);

  /// Blue ring used on focused inputs
  static const Color primaryFocus = Color(0xFF76A9FA);

  // ─────────────────────────────────────────────
  // Neutral Palette
  // ─────────────────────────────────────────────

  /// Screen and card background — pure white
  static const Color white = Color(0xFFFFFFFF);

  /// Page scaffold background — very light grey
  static const Color surfaceGrey = Color(0xFFF9FAFB);

  /// Card borders, dividers, input borders
  static const Color borderGrey = Color(0xFFE5E7EB);

  /// Slightly deeper border for inputs in resting state
  static const Color inputBorder = Color(0xFFD1D5DB);

  // ─────────────────────────────────────────────
  // Text Colours
  // ─────────────────────────────────────────────

  /// Headlines, body copy, primary labels
  static const Color textPrimary = Color(0xFF111827);

  /// Subtitles, placeholder, metadata
  static const Color textSecondary = Color(0xFF6B7280);

  /// Disabled labels, muted info
  static const Color textDisabled = Color(0xFF9CA3AF);

  /// White text used on coloured (primary blue) backgrounds
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Hint text inside inputs
  static const Color textHint = Color(0xFF9CA3AF);

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
  // Semantic — Escalation
  // ─────────────────────────────────────────────

  static const Color escalation = Color(0xFFFF5A1F);
  static const Color escalationLight = Color(0xFFFFECE2);

  // ─────────────────────────────────────────────
  // Status Badge Colours
  // Each status has a background + text colour pair
  // ─────────────────────────────────────────────

  /// Complaint: PENDING
  static const Color statusPendingBg = Color(0xFFFDF6B2);
  static const Color statusPendingText = Color(0xFFC27803);

  /// Complaint: ACKNOWLEDGED
  static const Color statusAcknowledgedBg = Color(0xFFEBF5FF);
  static const Color statusAcknowledgedText = Color(0xFF1A56DB);

  /// Complaint: IN PROGRESS
  static const Color statusInProgressBg = Color(0xFFEDEBFE);
  static const Color statusInProgressText = Color(0xFF5521B5);

  /// Complaint: RESOLVED / CLOSED
  static const Color statusResolvedBg = Color(0xFFDEF7EC);
  static const Color statusResolvedText = Color(0xFF057A55);

  /// Complaint: CLOSED (greyed)
  static const Color statusClosedBg = Color(0xFFF3F4F6);
  static const Color statusClosedText = Color(0xFF6B7280);

  /// Complaint: REJECTED
  static const Color statusRejectedBg = Color(0xFFFDE8E8);
  static const Color statusRejectedText = Color(0xFFE02424);

  /// Complaint: ESCALATED
  static const Color statusEscalatedBg = Color(0xFFFFECE2);
  static const Color statusEscalatedText = Color(0xFFFF5A1F);

  /// Donation: ACCEPTED = resolved colours
  static const Color statusAcceptedBg = Color(0xFFDEF7EC);
  static const Color statusAcceptedText = Color(0xFF057A55);

  /// Donation: PENDING REVIEW
  static const Color statusReviewBg = Color(0xFFFDF6B2);
  static const Color statusReviewText = Color(0xFFC27803);

  /// Verification: VERIFIED
  static const Color verifiedBg = Color(0xFFDEF7EC);
  static const Color verifiedText = Color(0xFF057A55);

  /// Verification: UNVERIFIED
  static const Color unverifiedBg = Color(0xFFFDE8E8);
  static const Color unverifiedText = Color(0xFFE02424);

  // ─────────────────────────────────────────────
  // Priority Badge Colours
  // ─────────────────────────────────────────────

  static const Color priorityLowBg = Color(0xFFF3F4F6);
  static const Color priorityLowText = Color(0xFF6B7280);
  static const Color priorityMediumBg = Color(0xFFFDF6B2);
  static const Color priorityMediumText = Color(0xFFC27803);
  static const Color priorityHighBg = Color(0xFFFFECE2);
  static const Color priorityHighText = Color(0xFFFF5A1F);
  static const Color priorityEmergencyBg = Color(0xFFFDE8E8);
  static const Color priorityEmergencyText = Color(0xFFE02424);

  // ─────────────────────────────────────────────
  // Miscellaneous
  // ─────────────────────────────────────────────

  /// Full-screen loading overlay background
  static const Color overlay = Color(0x80000000);

  /// Subtle divider lines
  static const Color divider = Color(0xFFE5E7EB);

  /// Shimmer loading placeholder colours
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF9FAFB);

  /// Card drop shadow colour
  static const Color shadow = Color(0x14000000); // 8% black

  // ─────────────────────────────────────────────
  // Bottom Navigation
  // ─────────────────────────────────────────────

  static const Color navBarBackground = Color(0xFFFFFFFF);
  static const Color navBarSelected = Color(0xFF1A56DB);
  static const Color navBarUnselected = Color(0xFF9CA3AF);
  static const Color navBarBorder = Color(0xFFE5E7EB);

  // ─────────────────────────────────────────────
  // App Bar
  // ─────────────────────────────────────────────

  /// White app bar used on content screens
  static const Color appBarWhite = Color(0xFFFFFFFF);
  static const Color appBarWhiteText = Color(0xFF111827);

  /// Blue app bar used on auth screens (login, OTP, register)
  static const Color appBarBlue = Color(0xFF1A56DB);
  static const Color appBarBlueText = Color(0xFFFFFFFF);
}
