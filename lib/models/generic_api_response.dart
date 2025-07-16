

import 'dart:convert';

GenericApiResponse genericApiResponseFromJson(String str) => GenericApiResponse.fromJson(json.decode(str));

String genericApiResponseToJson(GenericApiResponse data) => json.encode(data.toJson());

class GenericApiResponse {
  final String message;

  const GenericApiResponse({required this.message});

  factory GenericApiResponse.fromJson(Map<String, dynamic> json) => GenericApiResponse(
        message: json["message"] as String? ?? 'Pesan tidak diketahui',
      );

  Map<String, dynamic> toJson() => {
        "message": message,
      };
}