import 'package:flutter/material.dart';
import 'ops_colors.dart';
import 'ops_text_styles.dart';

class OpsTheme {
  OpsTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3:  true,
      fontFamily:    'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: OpsColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: OpsColors.surfaceGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor:  OpsColors.white,
        foregroundColor:  OpsColors.textPrimary,
        elevation:        0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color:     OpsColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: OpsColors.borderGrey),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OpsColors.primary,
          foregroundColor: OpsColors.white,
          elevation:       0,
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: OpsTextStyles.buttonPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: OpsColors.primary,
          side: const BorderSide(color: OpsColors.primary),
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:       true,
        fillColor:    OpsColors.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
              color: OpsColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
              color: OpsColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
              color: OpsColors.inputFocused, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
              color: OpsColors.error),
        ),
        hintStyle: OpsTextStyles.body.copyWith(
            color: OpsColors.textHint),
        labelStyle: OpsTextStyles.fieldLabel,
      ),
      dividerTheme: const DividerThemeData(
        color:     OpsColors.borderGrey,
        thickness: 1,
        space:     1,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor:         OpsColors.primary,
        unselectedLabelColor: OpsColors.textSecondary,
        indicatorColor:     OpsColors.primary,
      ),
    );
  }
}