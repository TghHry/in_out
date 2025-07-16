
import 'dart:convert';
import 'package:in_out_2/models/attandance_model.dart';

AttendanceApiResponse attendanceApiResponseFromJson(String str) =>
    AttendanceApiResponse.fromJson(json.decode(str));

String attendanceApiResponseToJson(AttendanceApiResponse data) => json.encode(data.toJson());

class AttendanceApiResponse {
  final String message;
  final Attendance? data;

  const AttendanceApiResponse({
    required this.message,
    this.data,
  });

  factory AttendanceApiResponse.fromJson(Map<String, dynamic> json) => AttendanceApiResponse(
        message: json["message"] as String? ?? 'Pesan tidak diketahui',
        data: json["data"] == null || json["data"] is! Map
            ? null
            : Attendance.fromJson(json["data"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}