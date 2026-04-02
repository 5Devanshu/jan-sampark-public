import 'package:flutter/material.dart';
import 'ops_colors.dart';

class OpsTextStyles {
  OpsTextStyles._();

  static const _font = 'Inter';

  static const display = TextStyle(
    fontFamily: _font,
    fontSize:   28,
    fontWeight: FontWeight.w700,
    color:      OpsColors.textPrimary,
  );

  static const heading1 = TextStyle(
    fontFamily: _font,
    fontSize:   22,
    fontWeight: FontWeight.w700,
    color:      OpsColors.textPrimary,
  );

  static const heading2 = TextStyle(
    fontFamily: _font,
    fontSize:   18,
    fontWeight: FontWeight.w600,
    color:      OpsColors.textPrimary,
  );

  static const heading3 = TextStyle(
    fontFamily: _font,
    fontSize:   15,
    fontWeight: FontWeight.w600,
    color:      OpsColors.textPrimary,
  );

  static const body = TextStyle(
    fontFamily: _font,
    fontSize:   14,
    fontWeight: FontWeight.w400,
    color:      OpsColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _font,
    fontSize:   14,
    fontWeight: FontWeight.w500,
    color:      OpsColors.textPrimary,
  );

  static const bodySecondary = TextStyle(
    fontFamily: _font,
    fontSize:   14,
    fontWeight: FontWeight.w400,
    color:      OpsColors.textSecondary,
  );

  static const caption = TextStyle(
    fontFamily: _font,
    fontSize:   12,
    fontWeight: FontWeight.w400,
    color:      OpsColors.textSecondary,
  );

  static const captionMedium = TextStyle(
    fontFamily: _font,
    fontSize:   12,
    fontWeight: FontWeight.w500,
    color:      OpsColors.textSecondary,
  );

  static const label = TextStyle(
    fontFamily: _font,
    fontSize:   12,
    fontWeight: FontWeight.w500,
    color:      OpsColors.textPrimary,
  );

  static const sidebarItem = TextStyle(
    fontFamily: _font,
    fontSize:   13,
    fontWeight: FontWeight.w500,
    color:      OpsColors.sidebarText,
  );

  static const sidebarItemActive = TextStyle(
    fontFamily: _font,
    fontSize:   13,
    fontWeight: FontWeight.w600,
    color:      OpsColors.sidebarTextActive,
  );

  static const tableHeader = TextStyle(
    fontFamily: _font,
    fontSize:   12,
    fontWeight: FontWeight.w600,
    color:      OpsColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const tableCell = TextStyle(
    fontFamily: _font,
    fontSize:   13,
    fontWeight: FontWeight.w400,
    color:      OpsColors.textPrimary,
  );

  static const buttonPrimary = TextStyle(
    fontFamily: _font,
    fontSize:   13,
    fontWeight: FontWeight.w600,
    color:      OpsColors.white,
  );

  static const fieldLabel = TextStyle(
    fontFamily: _font,
    fontSize:   13,
    fontWeight: FontWeight.w500,
    color:      OpsColors.textPrimary,
  );
}