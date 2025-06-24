// lib/models/order_response.dart
import 'package:tugas_16/models/order_model.dart';



// Model for single Order responses (e.g., add order, detail order, change status)
class SingleOrderResponse {
  final String message;
  final Order? data;

  SingleOrderResponse({
    required this.message,
    this.data,
  });

  factory SingleOrderResponse.fromJson(Map<String, dynamic> json) {
    return SingleOrderResponse(
      message: json['message'],
      data: json['data'] != null ? Order.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}
