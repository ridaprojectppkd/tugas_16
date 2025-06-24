// lib/models/service_type_response.dart
import 'service_type.dart';

// Model for single Service Type responses (e.g., add service)
class SingleServiceTypeResponse {
  final String message;
  final ServiceType? data;

  SingleServiceTypeResponse({
    required this.message,
    this.data,
  });

  factory SingleServiceTypeResponse.fromJson(Map<String, dynamic> json) {
    return SingleServiceTypeResponse(
      message: json['message'],
      data: json['data'] != null ? ServiceType.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}
