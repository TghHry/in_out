
import 'package:in_out_2/api/api_service.dart';
import 'package:in_out_2/models/batch_model.dart';
import 'package:in_out_2/models/training_model.dart';
import 'package:in_out_2/utils/datetime_helper.dart' as datetime_utils; 

class User {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? batchId;
  final int? trainingId;
  final String? jenisKelamin;
  final String? profilePhotoPath;
  final String? onesignalPlayerId;
  final BatchData? batch;
  final Datum? training;

  String? get fullProfilePhotoUrl {
    if (profilePhotoPath == null || profilePhotoPath!.isEmpty) {
      return null;
    }

    if (profilePhotoPath!.startsWith('http://') || profilePhotoPath!.startsWith('https://')) {
      return profilePhotoPath;
    }

    const String publicStorageSegment = 'public/';
    String cleanedPhotoPath = profilePhotoPath!.startsWith('/') ? profilePhotoPath!.substring(1) : profilePhotoPath!;
    
    return '${ApiService.baseUrl}/$publicStorageSegment$cleanedPhotoPath';
  }

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.batchId,
    this.trainingId,
    this.jenisKelamin,
    this.profilePhotoPath,
    this.onesignalPlayerId,
    this.batch,
    this.training,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final DateTime parsedCreatedAt = datetime_utils.tryParseDateTime(json['created_at']?.toString()) ?? DateTime(2000, 1, 1);
    final DateTime parsedUpdatedAt = datetime_utils.tryParseDateTime(json['updated_at']?.toString()) ?? DateTime(2000, 1, 1);

    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,

      emailVerifiedAt: datetime_utils.tryParseDateTime(json['email_verified_at']?.toString()),

      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,

      batchId: json['batch_id'] != null
          ? int.tryParse(json['batch_id'].toString())
          : null,
      trainingId: json['training_id'] != null
          ? int.tryParse(json['training_id'].toString())
          : null,

      jenisKelamin: json['jenis_kelamin'] as String?,
      profilePhotoPath: json['profile_photo'] as String?,
      onesignalPlayerId: json['onesignal_player_id'] as String?,

      batch: json['batch'] == null || json['batch'] is! Map
          ? null
          : BatchData.fromJson(json['batch'] as Map<String, dynamic>),
      training: json['training'] == null || json['training'] is! Map
          ? null
          : Datum.fromJson(json['training'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'batch_id': batchId,
      'training_id': trainingId,
      'jenis_kelamin': jenisKelamin,
      'profile_photo': profilePhotoPath,
      'onesignal_player_id': onesignalPlayerId,
      'batch': batch?.toJson(),
      'training': training?.toJson(),
    };
  }
}