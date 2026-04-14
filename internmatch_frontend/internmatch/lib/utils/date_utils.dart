import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  /// "2 days ago", "just now", "3 months ago"
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  /// "3 days left", "Closes today", "Closed"
  static String deadlineLabel(DateTime? deadline) {
    if (deadline == null) return 'Open';
    final diff = deadline.difference(DateTime.now());
    if (diff.isNegative) return 'Closed';
    if (diff.inDays == 0) return 'Closes today!';
    if (diff.inDays == 1) return 'Closes tomorrow';
    if (diff.inDays <= 7) return '${diff.inDays} days left';
    return DateFormat('d MMM yyyy').format(deadline);
  }

  /// Returns urgency level: 0 = safe, 1 = warning, 2 = urgent/closed
  static int deadlineUrgency(DateTime? deadline) {
    if (deadline == null) return 0;
    final days = deadline.difference(DateTime.now()).inDays;
    if (days < 0) return 2;
    if (days <= 3) return 2;
    if (days <= 7) return 1;
    return 0;
  }

  static String formatShort(DateTime date) =>
      DateFormat('d MMM').format(date);

  static String formatFull(DateTime date) =>
      DateFormat('d MMMM yyyy').format(date);
}
