// lib/models/single_user_response.dart

import 'package:tugas_16/models/user_model.dart';

class SingleUserResponse {
  final String message;
  final User? data; // This will directly hold the User object

  SingleUserResponse({required this.message, this.data});

  factory SingleUserResponse.fromJson(Map<String, dynamic> json) {
    return SingleUserResponse(
      message: json['message'],
      // Correctly parse 'data' directly as a User object
      data:
          json['data'] != null
              ? User.fromJson(json['data'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data?.toJson()};
  }
}
