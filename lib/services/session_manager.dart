import 'dart:convert';
import 'package:in_out_2/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SessionManager {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';
  static const String _userProfileKey = 'current_user_profile_json';
  static const String _rememberedEmailKey = 'remembered_email';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    debugPrint('SessionManager: Token berhasil disimpan di SharedPreferences.');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);
    debugPrint('SessionManager: Token berhasil diambil dari SharedPreferences: $token');
    return token;
  }

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    debugPrint('SessionManager: Email berhasil disimpan di SharedPreferences: $email');
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString(_emailKey);
    debugPrint('SessionManager: Email berhasil diambil dari SharedPreferences: $email');
    return email;
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString(_userProfileKey, jsonEncode(user.toJson()));
      debugPrint('SessionManager: Data pengguna (objek User) berhasil disimpan di SharedPreferences.');
    } catch (e) {
      debugPrint('SessionManager: Gagal menyimpan data pengguna ke SharedPreferences: $e');
    }
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJsonString = prefs.getString(_userProfileKey);
    if (userJsonString != null && userJsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userJsonString) as Map<String, dynamic>;
        debugPrint('SessionManager: Data pengguna (objek User) berhasil diambil dari SharedPreferences.');
        return User.fromJson(userMap);
      } catch (e) {
        debugPrint('SessionManager: Kesalahan saat mendekode data pengguna dari SharedPreferences: $e');
        await prefs.remove(_userProfileKey);
        debugPrint('SessionManager: Data pengguna yang rusak telah dihapus.');
        return null;
      }
    }
    debugPrint('SessionManager: Tidak ada data pengguna (objek User) yang ditemukan di SharedPreferences.');
    return null;
  }
  
  Future<void> saveRememberedEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rememberedEmailKey, email);
    debugPrint('SessionManager: Email diingat: $email');
  }

  Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_rememberedEmailKey);
    debugPrint('SessionManager: Email yang diingat diambil: $email');
    return email;
  }

  Future<void> deleteRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberedEmailKey);
    debugPrint('SessionManager: Email yang diingat dihapus.');
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_userProfileKey);
    await prefs.remove(_rememberedEmailKey);
    debugPrint('SessionManager: Sesi telah dibersihkan sepenuhnya dari SharedPreferences.');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}