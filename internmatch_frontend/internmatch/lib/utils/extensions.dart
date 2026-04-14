import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── String extensions ────────────────────────────────────────────────────────

extension StringX on String {
  /// "flutter developer" → "Flutter Developer"
  String get titleCase {
    return split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  /// "flutter" → "F"
  String get initial => isNotEmpty ? this[0].toUpperCase() : '';

  /// Returns null if the string is empty, otherwise the string itself.
  String? get nullIfEmpty => trim().isEmpty ? null : this;

  /// Truncates to [maxLength] and appends "…" if needed.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}…';
  }

  /// Removes all whitespace duplicates and trims.
  String get cleaned => trim().replaceAll(RegExp(r'\s+'), ' ');

  bool get isValidEmail {
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(trim());
  }

  bool get isValidUrl {
    return RegExp(r'^https?://').hasMatch(this);
  }
}

// ─── DateTime extensions ──────────────────────────────────────────────────────

extension DateTimeX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isFuture => isAfter(DateTime.now());
  bool get isPast => isBefore(DateTime.now());

  int get daysFromNow => difference(DateTime.now()).inDays;

  String get smartLabel {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    if (daysFromNow > 0 && daysFromNow <= 7) return 'In $daysFromNow days';
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }
}

// ─── int extensions ───────────────────────────────────────────────────────────

extension IntX on int {
  /// Match score 0-100 → semantic color
  Color get matchColor {
    if (this >= 85) return AppColors.success;
    if (this >= 70) return AppColors.warning;
    return AppColors.error;
  }

  /// Match score → label
  String get matchLabel {
    if (this >= 85) return 'Excellent Match';
    if (this >= 70) return 'Good Match';
    if (this >= 50) return 'Partial Match';
    return 'Low Match';
  }

  Duration get ms => Duration(milliseconds: this);
  Duration get seconds => Duration(seconds: this);
}

// ─── double extensions ────────────────────────────────────────────────────────

extension DoubleX on double {
  /// CGPA 0-10 → colour
  Color get cgpaColor {
    if (this >= 8.5) return AppColors.success;
    if (this >= 7.0) return AppColors.warning;
    return AppColors.error;
  }

  String get cgpaLabel {
    if (this >= 9.0) return 'Outstanding';
    if (this >= 8.0) return 'Excellent';
    if (this >= 7.0) return 'Good';
    if (this >= 6.0) return 'Average';
    return 'Below Average';
  }
}

// ─── List extensions ─────────────────────────────────────────────────────────

extension ListX<T> on List<T> {
  List<T> get uniqueItems => toSet().toList();

  List<T> safeSublist(int start, [int? end]) {
    final e = end != null ? end.clamp(0, length) : length;
    final s = start.clamp(0, e);
    return sublist(s, e);
  }
}

// ─── BuildContext extensions ──────────────────────────────────────────────────

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get topPadding => MediaQuery.of(this).padding.top;
  double get bottomPadding => MediaQuery.of(this).padding.bottom;
  bool get isSmallScreen => screenWidth < 360;

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
        backgroundColor:
            isError ? AppColors.error.withOpacity(0.9) : AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: Text(message,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel,
                style: const TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: isDestructive ? AppColors.error : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
