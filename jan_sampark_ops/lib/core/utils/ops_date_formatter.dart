import 'package:intl/intl.dart';

class OpsDateFormatter {
  OpsDateFormatter._();

  static String toDate(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('d MMM yyyy').format(dt.toLocal());
  }

  static String toDateTime(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('d MMM yyyy, HH:mm').format(dt.toLocal());
  }

  static String timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'just now';
    if (diff.inHours   < 1)  return '${diff.inMinutes}m ago';
    if (diff.inDays    < 1)  return '${diff.inHours}h ago';
    if (diff.inDays    < 30) return '${diff.inDays}d ago';
    return toDate(dt);
  }
}