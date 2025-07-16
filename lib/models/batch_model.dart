

import 'dart:convert';

BatchApiResponse batchApiResponseFromJson(String str) =>
    BatchApiResponse.fromJson(json.decode(str));

String batchApiResponseToJson(BatchApiResponse data) => json.encode(data.toJson());

class BatchApiResponse {
  final String message;
  final List<BatchData>? data;

  const BatchApiResponse({
    required this.message,
    this.data,
  });

  factory BatchApiResponse.fromJson(Map<String, dynamic> json) => BatchApiResponse(
        message: json["message"] as String? ?? 'Pesan tidak diketahui',
        data: json["data"] == null
            ? null
            : List<BatchData>.from(json["data"].map((x) => BatchData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class BatchData {
  final int id;
   String? batchKe;
  final DateTime startDate;
  final DateTime endDate;

  BatchData({
    required this.id,
    this.batchKe,
    required this.startDate,
    required this.endDate,
  });

  factory BatchData.fromJson(Map<String, dynamic> json) => BatchData(
        id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        batchKe: json["batch_ke"] as String? ?? 'Batch Tidak Diketahui',
        startDate: DateTime.parse(json["start_date"] as String),
        endDate: DateTime.parse(json["end_date"] as String),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "batch_ke": batchKe,
        "start_date": startDate.toIso8601String().split('T').first,
        "end_date": endDate.toIso8601String().split('T').first,
      };
}