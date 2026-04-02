import 'package:flutter/material.dart';

/// Ops Console uses the same blue palette as the mobile app
/// but with a wider sidebar-friendly layout.
class OpsColors {
  OpsColors._();

  // ── Brand ─────────────────────────────────
  static const primary      = Color(0xFF1D4ED8);
  static const primaryDark  = Color(0xFF1E3A8A);
  static const primaryLight = Color(0xFFEFF6FF);
  static const primaryAccent = Color(0xFF3B82F6);

  // ── Sidebar ───────────────────────────────
  static const sidebarBg       = Color(0xFF0F172A);
  static const sidebarActive   = Color(0xFF1D4ED8);
  static const sidebarHover    = Color(0xFF1E293B);
  static const sidebarText     = Color(0xFFCBD5E1);
  static const sidebarTextActive = Color(0xFFFFFFFF);

  // ── Surfaces ──────────────────────────────
  static const white       = Color(0xFFFFFFFF);
  static const surfaceGrey = Color(0xFFF8FAFC);
  static const cardBg      = Color(0xFFFFFFFF);
  static const borderGrey  = Color(0xFFE2E8F0);

  // ── Text ──────────────────────────────────
  static const textPrimary   = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textDisabled  = Color(0xFF94A3B8);
  static const textHint      = Color(0xFFCBD5E1);

  // ── Status ────────────────────────────────
  static const success      = Color(0xFF16A34A);
  static const successLight = Color(0xFFF0FDF4);
  static const error        = Color(0xFFDC2626);
  static const errorLight   = Color(0xFFFEF2F2);
  static const warning      = Color(0xFFD97706);
  static const warningLight = Color(0xFFFFFBEB);

  // ── Shadows ───────────────────────────────
  static const shadow = Color(0x0D000000);

  // ── Input ────────────────────────────────
  static const inputBorder  = Color(0xFFCBD5E1);
  static const inputFocused = Color(0xFF1D4ED8);
}