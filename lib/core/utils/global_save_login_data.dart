import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalStorage {
  // 🔑 keys (ja diye SharedPreferences e data rakhbo)
  static const String _kTokenKey = 'access_token';
  static const String _kUserJsonKey = 'user_json';

  /// ✅ Login successful hole ei function diye save korba
  /// token + full user json
  static Future<void> saveLoginData({
    required String token,
    required Map<String, dynamic> userJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // token direct string
    await prefs.setString(_kTokenKey, token);

    // user JSON -> String
    final String encodedUser = jsonEncode(userJson);
    await prefs.setString(_kUserJsonKey, encodedUser);
  }

  /// ✅ Saved token ta pore jekhono theke nite parba
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTokenKey);
  }

  /// ✅ Saved user JSON abar Map hisebe pabar jonno
  static Future<Map<String, dynamic>?> getUserJson() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userString = prefs.getString(_kUserJsonKey);

    if (userString == null) return null;

    try {
      final Map<String, dynamic> userMap =
          jsonDecode(userString) as Map<String, dynamic>;
      return userMap;
    } catch (e) {
      // jodi kono karone parse error hoy
      return null;
    }
  }

  /// ✅ Age login kora chilo ki na – eta diye check korba
  /// true mane: age token + user data save chilo (mane login kora chilo)
  static Future<bool> hasLoggedInBefore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenKey);
    final user = prefs.getString(_kUserJsonKey);

    return token != null && user != null;
  }

  /// ✅ Logout korar time e sob clear kore dibe
  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kUserJsonKey);
  }
}
