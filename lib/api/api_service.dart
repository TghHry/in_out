
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:in_out_2/services/session_manager.dart';

class ApiService {
  static const String baseUrl = 'https://appabsensi.mobileprojp.com';

  static final SessionManager _sessionManager = SessionManager();

  // --- Manajemen Token (melalui SessionManager) ---
  static Future<void> saveToken(String token) async {
    await _sessionManager.saveToken(token);
    debugPrint('ApiService: Token disimpan via SessionManager.');
  }

  static Future<String?> getToken() async {
    String? token = await _sessionManager.getToken();
    debugPrint('ApiService: Token diambil via SessionManager: $token');
    return token;
  }

  static Future<void> deleteToken() async {
    await _sessionManager.clearSession();
    debugPrint('ApiService: Token dan sesi dihapus via SessionManager.');
  }

  // --- Pembentukan Header Permintaan HTTP ---
  static Map<String, String> _getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
    Map<String, dynamic>? queryParameters,
  }) async {
    Uri uri = Uri.parse('$baseUrl/$endpoint');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }
    debugPrint('ApiService: GET request to: $uri');
    try {
      final response = await http.get(uri, headers: _getHeaders(token: token));
      debugPrint(
        'ApiService: GET response status for $endpoint: ${response.statusCode}',
      );
      debugPrint(
        'ApiService: GET response body for $endpoint: ${response.body}',
      );
      return _handleResponse(response, endpoint);
    } catch (e) {
      debugPrint('ApiService: Error during GET $endpoint: $e');
      throw Exception(
        'Terjadi kesalahan jaringan atau server saat ${endpoint.split('/').last}: $e',
      );
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    debugPrint(
      'ApiService: POST request to: $uri with body: ${jsonEncode(body)}',
    );
    try {
      final response = await http.post(
        uri,
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );
      debugPrint(
        'ApiService: POST response status for $endpoint: ${response.statusCode}',
      );
      debugPrint(
        'ApiService: POST response body for $endpoint: ${response.body}',
      );
      return _handleResponse(response, endpoint);
    } catch (e) {
      debugPrint('ApiService: Error during POST $endpoint: $e');
      throw Exception(
        'Terjadi kesalahan jaringan atau server saat ${endpoint.split('/').last}: $e',
      );
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    debugPrint(
      'ApiService: PUT request to: $uri with body: ${jsonEncode(body)}',
    );
    try {
      final response = await http.put(
        uri,
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );
      debugPrint(
        'ApiService: PUT response status for $endpoint: ${response.statusCode}',
      );
      debugPrint(
        'ApiService: PUT response body for $endpoint: ${response.body}',
      );
      return _handleResponse(response, endpoint);
    } catch (e) {
      debugPrint('ApiService: Error during PUT $endpoint: $e');
      throw Exception(
        'Terjadi kesalahan jaringan atau server saat memperbarui data: $e',
      );
    }
  }

  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    debugPrint('ApiService: DELETE request to: $uri');
    try {
      final response = await http.delete(
        uri,
        headers: _getHeaders(token: token),
      );
      debugPrint(
        'ApiService: DELETE response status for $endpoint: ${response.statusCode}',
      );
      debugPrint(
        'ApiService: DELETE response body for $endpoint: ${response.body}',
      );
      return _handleResponse(response, endpoint);
    } catch (e) {
      debugPrint('ApiService: Error during DELETE $endpoint: $e');
      throw Exception(
        'Terjadi kesalahan jaringan atau server saat menghapus data: $e',
      );
    }
  }

  static Map<String, dynamic> _handleResponse(
    http.Response response,
    String endpoint,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else if (response.statusCode == 404 && endpoint == 'api/absen/today') {
      final responseBody = json.decode(response.body);
      if (responseBody['message'] ==
              "Belum ada data absensi pada tanggal tersebut" &&
          responseBody['data'] == null) {
        debugPrint(
          'ApiService: 404 untuk api/absen/today diinterpretasikan sebagai "no data".',
        );
        return {"message": responseBody['message'], "data": null};
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Gagal memuat. Status: ${response.statusCode}',
        );
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception(
        errorData['message'] ??
            'Permintaan gagal. Status: ${response.statusCode}',
      );
    }
  }
}
