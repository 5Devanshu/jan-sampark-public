import 'package:intl/intl.dart';

/// Date and time formatting utilities for the Ops Console.
class OpsDateFormatter {
  OpsDateFormatter._();

  static final _date     = DateFormat('d MMM yyyy');
  static final _dateTime = DateFormat('d MMM yyyy, HH:mm');
  static final _time     = DateFormat('HH:mm');
  static final _dateShort = DateFormat('dd/MM/yyyy');
  static final _monthYear = DateFormat('MMM yyyy');

  // ─────────────────────────────────────────────
  // Formatters
  // ─────────────────────────────────────────────

  static String toDate(DateTime? dt) {
    if (dt == null) return '—';
    return _date.format(dt.toLocal());
  }

  static String toDateTime(DateTime? dt) {
    if (dt == null) return '—';
    return _dateTime.format(dt.toLocal());
  }

  static String toTime(DateTime? dt) {
    if (dt == null) return '—';
    return _time.format(dt.toLocal());
  }

  static String toShortDate(DateTime? dt) {
    if (dt == null) return '—';
    return _dateShort.format(dt.toLocal());
  }

  static String toMonthYear(DateTime? dt) {
    if (dt == null) return '—';
    return _monthYear.format(dt.toLocal());
  }

  // ─────────────────────────────────────────────
  // Relative time
  // ─────────────────────────────────────────────

  static String timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt.toLocal());

    if (diff.inSeconds < 60)  return 'just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24)  return '${diff.inHours}h ago';
    if (diff.inDays    < 7)   return '${diff.inDays}d ago';
    if (diff.inDays    < 30)  return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays    < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  // ─────────────────────────────────────────────
  // Parse helpers
  // ─────────────────────────────────────────────

  static DateTime? fromApiString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  static DateTime? fromDateString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final parts = raw.split('-');
      if (parts.length != 3) return null;
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // ISO string for API requests
  // ─────────────────────────────────────────────

  static String toApiDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  static String toApiDateTime(DateTime dt) =>
      dt.toUtc().toIso8601String();
}