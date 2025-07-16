// lib/presentation/absensi/attandance/services/attandance_service.dart

import 'package:flutter/foundation.dart';
import 'package:in_out_2/api/api_service.dart';
import 'package:in_out_2/models/attandance_api_reponse.dart';
import 'package:in_out_2/models/generic_api_response.dart';
import 'package:intl/intl.dart';


class AttendanceService {
  Future<AttendanceApiResponse> getTodayAttendance(String token) async {
    debugPrint('AttendanceService: Calling getTodayAttendance...');
    try {
      final Map<String, dynamic> responseData = await ApiService.get('api/absen/today', token: token);
      debugPrint('AttendanceService: Raw response from ApiService.getTodayAttendance: $responseData');
      return AttendanceApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('AttendanceService: Error in getTodayAttendance service: $e');
      rethrow;
    }
  }

  Future<AttendanceApiResponse> checkIn({
    required String token,
    required double latitude,
    required double longitude,
    required String address,
    required String status,
  }) async {
    debugPrint('AttendanceService: Calling checkIn...');
    try {
      final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final String currentTime = DateFormat('HH:mm').format(DateTime.now());

      final Map<String, dynamic> body = {
        'check_in_lat': latitude.toString(),
        'check_in_lng': longitude.toString(),
        'check_in_address': address,
        'status': status,
        'attendance_date': currentDate,
        'check_in': currentTime,
      };

      final Map<String, dynamic> responseData = await ApiService.post(
        'api/absen/check-in',
        body,
        token: token,
      );
      debugPrint('AttendanceService: Raw response from ApiService.checkIn: $responseData');
      return AttendanceApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('AttendanceService: Error in checkIn service: $e');
      rethrow;
    }
  }

  Future<AttendanceApiResponse> checkOut({
    required String token,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    debugPrint('AttendanceService: Calling checkOut...');
    try {
      final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final String currentTime = DateFormat('HH:mm').format(DateTime.now());

      final Map<String, dynamic> body = {
        'check_out_lat': latitude.toString(),
        'check_out_lng': longitude.toString(),
        'check_out_address': address,
        'attendance_date': currentDate,
        'check_out': currentTime,
      };

      final Map<String, dynamic> responseData = await ApiService.post(
        'api/absen/check-out',
        body,
        token: token,
      );
      debugPrint('AttendanceService: Raw response from ApiService.checkOut: $responseData');
      return AttendanceApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('AttendanceService: Error in checkOut service: $e');
      rethrow;
    }
  }

  Future<GenericApiResponse> submitIzin({
    required String token,
    required String date,
    required String reason,
  }) async {
    debugPrint('AttendanceService: Calling submitIzin...');
    try {
      final Map<String, dynamic> body = {
        'date': date,
        'alasan_izin': reason,
      };

      final Map<String, dynamic> responseData = await ApiService.post(
        'api/izin',
        body,
        token: token,
      );
      debugPrint('AttendanceService: Raw response from ApiService.submitIzin: $responseData');
      return GenericApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('AttendanceService: Error in submitIzin service: $e');
      rethrow;
    }
  }
}