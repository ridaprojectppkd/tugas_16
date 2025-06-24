// lib/models/service_type_list_response.dart
import 'service_type.dart';

// Model for list Service Type responses
class ServiceTypeListResponse {
  final String message;
  final List<ServiceType> data;

  ServiceTypeListResponse({
    required this.message,
    required this.data,
  });

  factory ServiceTypeListResponse.fromJson(Map<String, dynamic> json) {
    return ServiceTypeListResponse(
      message: json['message'],
      data: (json['data'] as List)
          .map((e) => ServiceType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
