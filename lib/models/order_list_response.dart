// lib/models/order_list_response.dart
import 'package:tugas_16/models/order_model.dart';



// Model for list Order responses
class OrderListResponse {
  final String message;
  final List<Order> data;

  OrderListResponse({
    required this.message,
    required this.data,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      message: json['message'],
      data: (json['data'] as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
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
