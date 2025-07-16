import 'dart:convert';

TrainingApiResponse trainingApiResponseFromJson(String str) =>
    TrainingApiResponse.fromJson(json.decode(str));

String trainingApiResponseToJson(TrainingApiResponse data) =>
    json.encode(data.toJson());

class TrainingApiResponse {
  final String message;
  final List<Datum>? data;
  const TrainingApiResponse({required this.message, this.data});

  factory TrainingApiResponse.fromJson(Map<String, dynamic> json) =>
      TrainingApiResponse(
        message: json["message"] as String? ?? 'Pesan tidak diketahui',

        data:
            json["data"] == null
                ? null
                : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );
  Map<String, dynamic> toJson() => {
    "message": message,
    "data":
        data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  final int id;
  final String? title;
  final String? description;
  final Pivot? pivot;
  final int? participantCount;

  const Datum({
    required this.id,
    this.title,
    this.description,
    this.pivot,
    this.participantCount,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
    title: json["title"] as String?,
    description: json["description"] as String?,
    pivot:
        json["pivot"] == null || json["pivot"] is! Map
            ? null
            : Pivot.fromJson(json["pivot"] as Map<String, dynamic>),
    participantCount: int.tryParse(json['participant_count']?.toString() ?? ''),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "pivot": pivot?.toJson(), // Menggunakan null-aware operator '?'
    "participant_count": participantCount,
  };
}

class Pivot {
  final String? trainingBatchId;

  final String? trainingId;

  const Pivot({this.trainingBatchId, this.trainingId});

  factory Pivot.fromJson(Map<String, dynamic> json) => Pivot(
    trainingBatchId: json["training_batch_id"] as String?,
    trainingId: json["training_id"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "training_batch_id": trainingBatchId,
    "training_id": trainingId,
  };
}
