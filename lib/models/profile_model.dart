
import 'dart:convert';
import 'package:in_out_2/models/batch_model.dart';
import 'package:in_out_2/models/training_model.dart';

ProfileResponse profileResponseFromJson(String str) =>
    ProfileResponse.fromJson(json.decode(str));

String profileResponseToJson(ProfileResponse data) => json.encode(data.toJson());

class ProfileResponse {
   String? message;
  final ProfileUser? data;

   ProfileResponse({
    required this.message,
    this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) => ProfileResponse(
        message: json["message"] as String? ?? 'Pesan tidak diketahui',
        data: json["data"] == null || json["data"] is! Map
            ? null
            : ProfileUser.fromJson(json["data"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class ProfileUser {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? batchId;
  final int? trainingId;
  final String? jenisKelamin;
  final String? profilePhoto;
  final String? onesignalPlayerId;
  final BatchData? batch;
  final Datum? training;

  const ProfileUser({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.batchId,
    this.trainingId,
    this.jenisKelamin,
    this.profilePhoto,
    this.onesignalPlayerId,
    this.batch,
    this.training,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return ProfileUser(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json["name"] as String? ?? 'Nama Tidak Diketahui',
      email: json["email"] as String? ?? 'email@tidakdiketahui.com',
      emailVerifiedAt: parseDateTime(json["email_verified_at"]),
      createdAt: parseDateTime(json["created_at"]),
      updatedAt: parseDateTime(json["updated_at"]),
      batchId: int.tryParse(json['batch_id']?.toString() ?? ''),
      trainingId: int.tryParse(json['training_id']?.toString() ?? ''),
      jenisKelamin: json["jenis_kelamin"] as String?,
      profilePhoto: json["profile_photo"] as String?,
      onesignalPlayerId: json["onesignal_player_id"] as String?,
      batch: json["batch"] == null || json["batch"] is! Map
          ? null
          : BatchData.fromJson(json["batch"] as Map<String, dynamic>),
      training: json["training"] == null || json["training"] is! Map
          ? null
          : Datum.fromJson(json["training"] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "batch_id": batchId,
        "training_id": trainingId,
        "jenis_kelamin": jenisKelamin,
        "profile_photo": profilePhoto,
        "onesignal_player_id": onesignalPlayerId,
        "batch": batch?.toJson(),
        "training": training?.toJson(),
      };
}