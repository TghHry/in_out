

import 'package:flutter/foundation.dart';
import 'package:in_out_2/api/api_service.dart';
import 'package:in_out_2/models/generic_api_response.dart';
import 'package:in_out_2/models/login_response.dart';
import 'package:in_out_2/services/session_manager.dart';

class AuthService {
  final SessionManager _sessionManager = SessionManager();

  Future<LoginResponse> login(String email, String password) async {
    debugPrint('AuthService: Calling login with email: $email');
    try {
      final Map<String, dynamic> responseData = await ApiService.post(
        'api/login',
        {'email': email, 'password': password},
      );
      debugPrint('AuthService: Raw response from ApiService.post (login): $responseData');

      final LoginResponse loginResponse = LoginResponse.fromJson(responseData);

      if (loginResponse.token != null && loginResponse.user != null) {
        await _sessionManager.saveToken(loginResponse.token!);
        await _sessionManager.saveEmail(loginResponse.user!.email);
        await _sessionManager.saveUser(loginResponse.user!);
        debugPrint('AuthService: Login successful, token, email, and user saved.');
      } else {
        debugPrint('AuthService: Login failed, token or user not found in response.');
        throw Exception(loginResponse.message);
      }
      return loginResponse;
    } catch (e) {
      debugPrint('AuthService: Error during login: $e');
      rethrow;
    }
  }

  Future<GenericApiResponse> register({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required int trainingId,
    required int batchId,
    String? profilePhoto,
  }) async {
    debugPrint('AuthService: Calling registration for email: $email');
    try {
      final Map<String, dynamic> body = {
        'name': name,
        'email': email,
        'password': password,
        'jenis_kelamin': jenisKelamin,
        'training_id': trainingId,
        'batch_id': batchId,
        if (profilePhoto != null) 'profile_photo': profilePhoto,
      };

      final Map<String, dynamic> responseData = await ApiService.post(
        'api/register',
        body,
      );
      debugPrint('AuthService: Raw response from ApiService.post (register): $responseData');
      return GenericApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('AuthService: Error during registration: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    debugPrint('AuthService: Starting logout process.');
    try {
      await _sessionManager.clearSession();
      debugPrint('AuthService: Logout successful, local session cleared.');
    } catch (e) {
      debugPrint('AuthService: Error during logout: $e');
      rethrow;
    }
  }
}