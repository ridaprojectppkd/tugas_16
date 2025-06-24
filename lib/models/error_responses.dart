// lib/models/error_response.dart

// Model for API error responses
class ErrorResponse {
  final String message;
  final Map<String, dynamic>? errors; // For validation errors

  ErrorResponse({
    required this.message,
    this.errors,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'],
      errors: json['errors'] != null ? Map<String, dynamic>.from(json['errors']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'errors': errors,
    };
  }
}
