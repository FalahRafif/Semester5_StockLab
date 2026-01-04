import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const _tokenKey = "token";
  static const _userIdKey = "userId";
  static const _roleKey = "role"; // ✅ FIX
  static const _expiredKey = "token_expired_at";

  /// Simpan token + user session
  static Future<void> saveAuth({
    required String token,
    required String userId,
    required String role,
    int expiresInSeconds = 86400, // default 24 jam
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiredAt = now + (expiresInSeconds * 1000);

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_roleKey, role);
    await prefs.setInt(_expiredKey, expiredAt);
  }

  /// Ambil token (null jika expired)
  static Future<String?> getToken() async {
    if (!await isTokenValid()) return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Ambil userId dari session
  static Future<String?> getUserId() async {
    if (!await isTokenValid()) return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Ambil role user
  static Future<String?> getRole() async {
    if (!await isTokenValid()) return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  /// Validasi token berdasarkan expired time
  static Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final expiredAt = prefs.getInt(_expiredKey);

    if (expiredAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch < expiredAt;
  }

  /// Clear session (logout)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_expiredKey);
  }
}
