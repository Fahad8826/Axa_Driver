import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppPrefs {
  AppPrefs._();

  // Single shared instance with Android AES encryption
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyAccessToken    = 'access_token';
  static const _keyRefreshToken   = 'refresh_token';
  static const _keyIsLoggedIn     = 'is_logged_in';
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keyDriverName     = 'driver_name';
  static const _keyDriverPhone    = 'driver_phone';
  static const _keyDriverId       = 'driver_id';
  static const _keyFcmToken       = 'fcm_token';   // ← consistent with secure storage

  // ── Tokens ────────────────────────────────────────────────────────────────
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }

  // ── Session ───────────────────────────────────────────────────────────────
  static Future<void> setLoggedIn(bool value) async {
    await _storage.write(key: _keyIsLoggedIn, value: value.toString());
  }

  static Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: _keyIsLoggedIn);
    return value == 'true';
  }

  // ── Onboarding ────────────────────────────────────────────────────────────
  static Future<void> setOnboardingDone() async {
    await _storage.write(key: _keyOnboardingDone, value: 'true');
  }

  static Future<bool> isOnboardingDone() async {
    final value = await _storage.read(key: _keyOnboardingDone);
    return value == 'true';
  }

  // ── Driver info ───────────────────────────────────────────────────────────
  static Future<void> saveDriverInfo({
    required int id,
    required String name,
    required String phone,
  }) async {
    await _storage.write(key: _keyDriverId, value: id.toString());
    await _storage.write(key: _keyDriverName, value: name);
    await _storage.write(key: _keyDriverPhone, value: phone);
  }

  static Future<String?> getDriverName() async {
    return _storage.read(key: _keyDriverName);
  }

  static Future<String?> getDriverPhone() async {
    return _storage.read(key: _keyDriverPhone);
  }

  static Future<int?> getDriverId() async {
    final value = await _storage.read(key: _keyDriverId);
    return value != null ? int.tryParse(value) : null;
  }

  // ── FCM Token ─────────────────────────────────────────────────────────────
  static Future<void> saveFcmToken(String token) async {
    await _storage.write(key: _keyFcmToken, value: token);
  }

  static Future<String?> getFcmToken() async {
    return _storage.read(key: _keyFcmToken);
  }

  // ── Clear (logout) ────────────────────────────────────────────────────────
  // Keeps onboarding_done  → user shouldn't see onboarding again after logout
  // Keeps fcm_token        → token is device-bound, no need to re-fetch
  static Future<void> clear() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyIsLoggedIn);
    await _storage.delete(key: _keyDriverName);
    await _storage.delete(key: _keyDriverPhone);
    await _storage.delete(key: _keyDriverId);
    // _keyOnboardingDone  → intentionally kept
    // _keyFcmToken        → intentionally kept
  }
}