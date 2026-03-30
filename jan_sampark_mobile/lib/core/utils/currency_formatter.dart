import 'package:intl/intl.dart';

/// Currency and number formatting utilities for Jan Sampark.
/// All amounts are in Indian Rupees (INR).
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _inrDecimalFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _compactFormat = NumberFormat.compact(locale: 'en_IN');

  // ─────────────────────────────────────────────
  // Format amounts
  // ─────────────────────────────────────────────

  /// "₹1,50,000"
  static String format(double amount) => _inrFormat.format(amount);

  /// "₹1,50,000.50"
  static String formatDecimal(double amount) =>
      _inrDecimalFormat.format(amount);

  /// "₹1.5L" / "₹25K"
  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    }
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  // ─────────────────────────────────────────────
  // Progress percentage
  // ─────────────────────────────────────────────

  /// "42%" — for campaign progress display
  static String formatPercent(double pct) {
    return '${pct.toStringAsFixed(1)}%';
  }

  // ─────────────────────────────────────────────
  // Parse
  // ─────────────────────────────────────────────

  /// Parse "1,50,000" or "150000" → 150000.0
  static double? parse(String value) {
    final cleaned = value.replaceAll(RegExp(r'[₹,\s]'), '');
    return double.tryParse(cleaned);
  }
}
