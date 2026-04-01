/// Centralised form validators — import and use directly as `Validators.email`.
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!re.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Minimum 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? cgpa(String? value) {
    if (value == null || value.isEmpty) return 'CGPA is required';
    final d = double.tryParse(value);
    if (d == null) return 'Enter a valid number';
    if (d < 0 || d > 10) return 'CGPA must be between 0 and 10';
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    final re = RegExp(r'^https?://');
    if (!re.hasMatch(value)) return 'Enter a valid URL (https://...)';
    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    final re = RegExp(r'^\+?[0-9]{10,13}$');
    if (!re.hasMatch(value.replaceAll(' ', ''))) return 'Enter a valid phone number';
    return null;
  }

  static String? minLength(String? value, int min, {String fieldName = 'This field'}) {
    if (value == null || value.length < min) return '$fieldName must be at least $min characters';
    return null;
  }
}
