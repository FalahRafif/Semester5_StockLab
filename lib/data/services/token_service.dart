import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const _tokenKey = "token";
  static const _userIdKey = "userId";
  static const _roleKey = "userId";
  static const _expiredKey = "token_expired_at";

  // Simpan token + expired
  static Future<void> saveAuth({
    required String token,
    required int userId,
    required String role,
    int expiresInSeconds = 86400, // default 24 jam jika API tidak kasih expired
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiredAt = now + (expiresInSeconds * 1000);
    print("wew");
    print(token);
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_roleKey, role);
    await prefs.setInt(_expiredKey, expiredAt);
  }

  // Ambil token (cek expired)
  static Future<String?> getToken() async {
    if (!await isTokenValid()) return null;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<int?> getuserId() async {
    if (!await isTokenValid()) return null;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<String?> getRole() async {
    if (!await isTokenValid()) return null;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // Cek masa berlaku token
  static Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final expiredAt = prefs.getInt(_expiredKey);

    if (expiredAt == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    return now < expiredAt;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_expiredKey);
  }
}
