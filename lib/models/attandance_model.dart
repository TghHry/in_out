
import 'package:intl/intl.dart'; 
class Attendance {
  final int id;
  final int userId;
  final DateTime date; 
  final String? checkIn; 
  final String? checkOut; 
  final double? checkInLat; 
  final double? checkInLng;
  final double? checkOutLat; 
  final double? checkOutLng; 

  final String? checkInAddress; 
  final String? checkOutAddress; 
  final String status; 
  final String? reason; 


  const Attendance({
    required this.id,
    required this.userId,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    this.checkInAddress,
    this.checkOutAddress,
    required this.status,
    this.reason,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
   
    double? _parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        return double.tryParse(value);
      } else if (value is num) {
        return value.toDouble();
      }
      return null;
    }

    return Attendance(

      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0, 
      date: DateTime.parse(json['attendance_date'] as String),

      checkIn: json["check_in_time"] as String?,
      checkOut: json["check_out_time"] as String?, 


      checkInLat: _parseDouble(json["check_in_lat"]),
      checkInLng: _parseDouble(json["check_in_lng"]),
      checkOutLat: _parseDouble(json["check_out_lat"]),
      checkOutLng: _parseDouble(json["check_out_lng"]),

      checkInAddress: json["check_in_address"] as String?,
      checkOutAddress: json["check_out_address"] as String?,


      status: json["status"] as String? ?? 'Tidak Diketahui',
      reason: json["alasan_izin"] as String?,
    );
  }

 
  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,

        "attendance_date": DateFormat('yyyy-MM-dd').format(date),

        "check_in": checkIn, 
        "check_out": checkOut,

        "check_in_lat": checkInLat,
        "check_in_lng": checkInLng,
        "check_out_lat": checkOutLat,
        "check_out_lng": checkOutLng,
        "check_in_address": checkInAddress,
        "check_out_address": checkOutAddress,
        "status": status,
        "alasan_izin": reason,
      };
}