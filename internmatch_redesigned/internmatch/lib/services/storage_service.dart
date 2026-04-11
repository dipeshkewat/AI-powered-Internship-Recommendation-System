import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps SharedPreferences for typed, key-safe access.
/// All keys are private constants — no magic strings in the rest of the app.
class StorageService {
  static const _keyToken = 'auth_token';
  static const _keyUserId = 'user_id';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyProfile = 'user_profile_json';
  static const _keyBookmarks = 'bookmarked_ids';
  static const _keyOnboardingDone = 'onboarding_done';
  // ignore: unused_field
  static const _keyTheme = 'theme_mode'; // 'dark' | 'light' - (reserved for future use)

  // ─── Singleton ─────────────────────────────────────────────────────────────

  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // ─── Auth ──────────────────────────────────────────────────────────────────

  Future<void> saveAuthToken(String token) =>
      _prefs.setString(_keyToken, token);

  String? getAuthToken() => _prefs.getString(_keyToken);

  Future<void> saveUserId(String id) => _prefs.setString(_keyUserId, id);

  String? getUserId() => _prefs.getString(_keyUserId);

  Future<void> saveUserMeta({
    required String name,
    required String email,
  }) async {
    await _prefs.setString(_keyUserName, name);
    await _prefs.setString(_keyUserEmail, email);
  }

  String? getUserName() => _prefs.getString(_keyUserName);
  String? getUserEmail() => _prefs.getString(_keyUserEmail);

  Future<void> clearAuth() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserEmail);
  }

  bool get isLoggedIn => getAuthToken() != null && getUserId() != null;

  // ─── Profile cache ─────────────────────────────────────────────────────────

  Future<void> saveProfileJson(Map<String, dynamic> json) =>
      _prefs.setString(_keyProfile, jsonEncode(json));

  Map<String, dynamic>? getProfileJson() {
    final raw = _prefs.getString(_keyProfile);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearProfile() => _prefs.remove(_keyProfile);

  // ─── Bookmarks (local cache) ───────────────────────────────────────────────

  List<String> getBookmarkedIds() =>
      _prefs.getStringList(_keyBookmarks) ?? [];

  Future<void> addBookmark(String id) async {
    final ids = getBookmarkedIds();
    if (!ids.contains(id)) {
      await _prefs.setStringList(_keyBookmarks, [...ids, id]);
    }
  }

  Future<void> removeBookmark(String id) async {
    final ids = getBookmarkedIds()..remove(id);
    await _prefs.setStringList(_keyBookmarks, ids);
  }

  bool isBookmarked(String id) => getBookmarkedIds().contains(id);

  // ─── Onboarding ────────────────────────────────────────────────────────────

  bool get onboardingDone => _prefs.getBool(_keyOnboardingDone) ?? false;

  Future<void> setOnboardingDone() =>
      _prefs.setBool(_keyOnboardingDone, true);

  // ─── Nuclear option ────────────────────────────────────────────────────────

  Future<void> clearAll() => _prefs.clear();
}
