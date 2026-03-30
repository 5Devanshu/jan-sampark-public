import 'package:intl/intl.dart';

/// Date and time formatting utilities for Jan Sampark.
///
/// All methods are static — no instantiation needed.
/// Handles null safely — returns empty string or fallback.
class DateFormatter {
  DateFormatter._();

  // ─────────────────────────────────────────────
  // Display Formats
  // ─────────────────────────────────────────────

  /// "15 Jan 2025"
  static String toDisplayDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy').format(date.toLocal());
  }

  /// "15 Jan 2025, 06:30 PM"
  static String toDisplayDateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
  }

  /// "06:30 PM"
  static String toDisplayTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('hh:mm a').format(date.toLocal());
  }

  /// "Monday, 15 January 2025"
  static String toFullDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('EEEE, dd MMMM yyyy').format(date.toLocal());
  }

  /// "Jan 2025"
  static String toMonthYear(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM yyyy').format(date.toLocal());
  }

  /// "2025-01-15"  (ISO format for API requests)
  static String toApiDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // ─────────────────────────────────────────────
  // Relative Time ("time ago")
  // ─────────────────────────────────────────────

  /// Returns a human-readable relative time string.
  ///
  /// "just now", "5m ago", "2h ago", "3d ago",
  /// "15 Jan" (within this year), "15 Jan 2024" (past year)
  static String timeAgo(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date.toLocal());

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    // More than a week — show date
    if (date.year == now.year) {
      return DateFormat('dd MMM').format(date.toLocal());
    }
    return DateFormat('dd MMM yyyy').format(date.toLocal());
  }

  // ─────────────────────────────────────────────
  // Countdown
  // ─────────────────────────────────────────────

  /// Returns "MM:SS" countdown string for OTP timer.
  static String countdown(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  // ─────────────────────────────────────────────
  // Parse helpers
  // ─────────────────────────────────────────────

  /// Parse ISO datetime string from API response safely.
  static DateTime? fromApiString(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Parse "YYYY-MM-DD" date string to DateTime safely.
  static DateTime? fromDateString(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateFormat('yyyy-MM-dd').parse(value);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // Event / Campaign date display
  // ─────────────────────────────────────────────

  /// Formats event date and time together.
  /// "Mon, 15 Jan · 06:30 PM"
  static String toEventDateTime(String? dateStr, String? timeStr) {
    final date = fromDateString(dateStr);
    if (date == null) return dateStr ?? '';
    final dateLabel = DateFormat('EEE, dd MMM').format(date);
    if (timeStr == null || timeStr.isEmpty) return dateLabel;
    // Parse HH:mm
    try {
      final parts = timeStr.split(':');
      final dt = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      final timeLabel = DateFormat('hh:mm a').format(dt);
      return '$dateLabel · $timeLabel';
    } catch (_) {
      return '$dateLabel · $timeStr';
    }
  }

  /// Days remaining until a date. Returns 0 if past.
  static int daysRemaining(String? dateStr) {
    final date = fromDateString(dateStr);
    if (date == null) return 0;
    final diff = date.difference(DateTime.now());
    return diff.inDays.clamp(0, 9999);
  }
}
