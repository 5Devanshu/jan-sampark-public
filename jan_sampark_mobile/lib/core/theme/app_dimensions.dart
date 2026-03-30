/// All spacing, sizing, radius and elevation constants.
///
/// Follows an 8-point grid system.
/// Never use raw pixel values in the UI — always use AppDimensions.[token].
class AppDimensions {
  AppDimensions._();

  // ─────────────────────────────────────────────
  // Spacing — 8-point grid
  // ─────────────────────────────────────────────

  static const double spaceXXS = 2.0;
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 12.0;
  static const double space = 16.0;
  static const double spaceLG = 20.0;
  static const double spaceXL = 24.0;
  static const double spaceXXL = 32.0;
  static const double space3XL = 40.0;
  static const double space4XL = 48.0;
  static const double space5XL = 64.0;

  // ─────────────────────────────────────────────
  // Page / Screen Padding
  // ─────────────────────────────────────────────

  /// Horizontal padding applied to all screen content
  static const double pagePaddingH = 20.0;

  /// Vertical padding at the top of screen content (below app bar)
  static const double pagePaddingTop = 16.0;

  /// Vertical padding at the bottom of screen content
  static const double pagePaddingBottom = 24.0;

  // ─────────────────────────────────────────────
  // Border Radius
  // ─────────────────────────────────────────────

  static const double radiusXS = 4.0;
  static const double radiusSM = 6.0;
  static const double radius = 8.0;
  static const double radiusMD = 10.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 20.0;
  static const double radiusFull = 100.0; // Fully rounded — pill badges, chips

  // ─────────────────────────────────────────────
  // Button Dimensions
  // ─────────────────────────────────────────────

  static const double buttonHeightLG = 52.0;
  static const double buttonHeightMD = 44.0;
  static const double buttonHeightSM = 36.0;
  static const double buttonHeightXS = 28.0;

  /// Standard button border radius
  static const double buttonRadius = 8.0;

  // ─────────────────────────────────────────────
  // Input Field Dimensions
  // ─────────────────────────────────────────────

  static const double inputHeight = 52.0;
  static const double inputRadius = 8.0;
  static const double inputBorderWidth = 1.0;
  static const double inputFocusBorderWidth = 1.5;
  static const double inputPaddingH = 16.0;
  static const double inputPaddingV = 14.0;

  // ─────────────────────────────────────────────
  // Card Dimensions
  // ─────────────────────────────────────────────

  static const double cardRadius = 10.0;
  static const double cardBorderWidth = 1.0;
  static const double cardPaddingH = 16.0;
  static const double cardPaddingV = 14.0;
  static const double cardElevation = 0.0; // We use border + shadow instead

  // ─────────────────────────────────────────────
  // Elevation / Shadows
  // ─────────────────────────────────────────────

  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;

  // ─────────────────────────────────────────────
  // App Bar
  // ─────────────────────────────────────────────

  static const double appBarHeight = 60.0;
  static const double appBarElevation = 0.0;
  static const double appBarBorderWidth = 1.0;

  // ─────────────────────────────────────────────
  // Bottom Navigation Bar
  // ─────────────────────────────────────────────

  static const double bottomNavHeight = 64.0;
  static const double bottomNavIconSize = 22.0;

  // ─────────────────────────────────────────────
  // Icons
  // ─────────────────────────────────────────────

  static const double iconXS = 14.0;
  static const double iconSM = 16.0;
  static const double iconMD = 20.0;
  static const double icon = 24.0;
  static const double iconLG = 28.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 40.0;
  static const double iconHero = 56.0;

  // ─────────────────────────────────────────────
  // Avatar / Profile Photo
  // ─────────────────────────────────────────────

  static const double avatarXS = 28.0;
  static const double avatarSM = 36.0;
  static const double avatarMD = 48.0;
  static const double avatarLG = 64.0;
  static const double avatarXL = 80.0;
  static const double avatarXXL = 96.0;

  // ─────────────────────────────────────────────
  // Badge
  // ─────────────────────────────────────────────

  static const double badgeHeight = 24.0;
  static const double badgeHeightSM = 20.0;
  static const double badgePaddingH = 10.0;
  static const double badgePaddingHSM = 8.0;
  static const double badgeRadius = 100.0;

  // ─────────────────────────────────────────────
  // Divider
  // ─────────────────────────────────────────────

  static const double dividerThickness = 1.0;

  // ─────────────────────────────────────────────
  // Progress Bar
  // ─────────────────────────────────────────────

  static const double progressBarHeight = 6.0;
  static const double progressBarRadius = 100.0;

  // ─────────────────────────────────────────────
  // Image Upload Box
  // ─────────────────────────────────────────────

  static const double uploadBoxHeight = 120.0;
  static const double uploadBoxRadius = 8.0;

  // ─────────────────────────────────────────────
  // OTP Input Boxes
  // ─────────────────────────────────────────────

  static const double otpBoxWidth = 48.0;
  static const double otpBoxHeight = 56.0;
  static const double otpBoxRadius = 8.0;
  static const double otpBoxSpacing = 10.0;

  // ─────────────────────────────────────────────
  // Step Progress Indicator (registration)
  // ─────────────────────────────────────────────

  static const double stepIndicatorHeight = 4.0;
  static const double stepIndicatorRadius = 100.0;
  static const double stepIndicatorSpacing = 6.0;

  // ─────────────────────────────────────────────
  // Bottom Sheet
  // ─────────────────────────────────────────────

  static const double bottomSheetRadius = 20.0;
  static const double bottomSheetDragHeight = 4.0;
  static const double bottomSheetDragWidth = 40.0;

  // ─────────────────────────────────────────────
  // Complaint Timeline
  // ─────────────────────────────────────────────

  static const double timelineDotSize = 12.0;
  static const double timelineLineWidth = 2.0;
  static const double timelineIconSize = 32.0;
}
