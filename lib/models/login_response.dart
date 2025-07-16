
import 'dart:convert';
import 'package:in_out_2/models/user_model.dart';

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));
String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  final String message;
  final LoginData? data;

  const LoginResponse({
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        message: json["message"] as String? ?? 'Pesan tidak diketahui',
        data: json["data"] == null || json["data"] is! Map
            ? null
            : LoginData.fromJson(json["data"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};

  String? get token => data?.token;
  User? get user => data?.user;
}

class LoginData {
  final String token;
  final User user;

  const LoginData({required this.token, required this.user});

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
        token: json["token"] as String,
        user: User.fromJson(
          json["user"] as Map<String, dynamic>,
        ),
      );

  Map<String, dynamic> toJson() => {"token": token, "user": user.toJson()};
}