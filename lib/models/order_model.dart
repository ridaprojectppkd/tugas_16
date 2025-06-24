// lib/models/order.dart
import 'service_type.dart';

// Model for an Order
class Order {
  final int? id;
  final int customerId;
  final String layanan; // 'Antar' or 'Jemput'
  final int? serviceTypeId;
  final String status; // 'Baru', 'Proses', 'Selesai', 'Dibatalkan'
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ServiceType? serviceType; // Nested service type data

  Order({
    this.id,
    required this.customerId,
    required this.layanan,
    this.serviceTypeId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.serviceType,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customer_id'],
      layanan: json['layanan'],
      serviceTypeId: json['service_type_id'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      serviceType: json['service_type'] != null
          ? ServiceType.fromJson(json['service_type'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'layanan': layanan,
      'service_type_id': serviceTypeId,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'service_type': serviceType?.toJson(),
    };
  }
}
