// lib/models/auth_response.dart
import 'package:tugas_16/models/user_model.dart';


// Model for successful registration and login responses
class AuthResponse {
  final String message;
  final AuthData? data;

  AuthResponse({
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'],
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

// Data part of the AuthResponse, containing token and user info
class AuthData {
  final String? token;
  final User user;

  AuthData({
    this.token,
    required this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}
