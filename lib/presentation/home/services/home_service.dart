
import 'package:flutter/foundation.dart'; 
import 'package:in_out_2/api/api_service.dart'; 

class HomeService {
  Future<Map<String, dynamic>> getAttendanceStats(String token) async {
    debugPrint('HomeService: Memanggil getAttendanceStats...');
    try {
      final Map<String, dynamic> responseData = await ApiService.get('api/absen/stats', token: token);
      debugPrint('HomeService: Raw response dari ApiService.get (stats): $responseData');


      if (responseData['data'] is Map<String, dynamic>) {
        return responseData['data'] as Map<String, dynamic>;
      } else {
        throw Exception(responseData['message'] ?? 'Format data statistik tidak valid.');
      }
    } catch (e) {
      debugPrint('HomeService: Error dalam getAttendanceStats service: $e');
      rethrow; 
    }
  }
}