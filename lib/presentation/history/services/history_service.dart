

import 'package:flutter/foundation.dart';
import 'package:in_out_2/api/api_service.dart';
import 'package:in_out_2/models/attandance_model.dart';
import 'package:in_out_2/models/generic_api_response.dart';

class HistoryService {
  Future<List<Attendance>> getAttendanceHistory({
    required String token,
    required String startDate,
    required String endDate,
  }) async {
    debugPrint('HistoryService: Calling getAttendanceHistory from $startDate to $endDate');
    try {
      final Map<String, dynamic> responseData = await ApiService.get(
        'api/absen/history',
        token: token,
        queryParameters: {'start': startDate, 'end': endDate},
      );
      debugPrint('HistoryService: Raw response from ApiService.get (history): $responseData');

      final List<dynamic> historyListJson = responseData['data'] as List<dynamic>? ?? [];
      return historyListJson.map((json) => Attendance.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('HistoryService: Error in getAttendanceHistory service: $e');
      rethrow;
    }
  }

  Future<GenericApiResponse> deleteAttendanceRecord({
    required String token,
    required int recordId,
  }) async {
    debugPrint('HistoryService: Calling deleteAttendanceRecord for ID: $recordId');
    try {
      final Map<String, dynamic> responseData = await ApiService.delete(
        'api/absen/$recordId',
        token: token,
      );
      debugPrint('HistoryService: Raw response from ApiService.delete (record): $responseData');
      return GenericApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('HistoryService: Error in deleteAttendanceRecord service: $e');
      rethrow;
    }
  }
}