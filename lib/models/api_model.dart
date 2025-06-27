// lib/models/flutter_models.dart
// HANYA gunakan satu file ini untuk semua model Anda
// import 'dart:convert';

// User model for registration and login responses
class User {
  final int? id;
  final String name;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.tryParse(json['id']?.toString() ?? ''),
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

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
      message: json['message'] as String,
      data: json['data'] != null ? AuthData.fromJson(json['data'] as Map<String, dynamic>) : null,
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
      token: json['token'] as String?,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}

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
      message: json['message'] as String,
      errors: json['errors'] != null ? Map<String, dynamic>.from(json['errors'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'errors': errors,
    };
  }
}

// Model for Service Type (e.g., Cuci, Antar, Jemput)
class ServiceType {
  final int? id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceType({
    this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      id: int.tryParse(json['id']?.toString() ?? ''),
      name: json['name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

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
      message: json['message'] as String,
      data: json['data'] != null ? ServiceType.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

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
      message: json['message'] as String,
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

// Model for an Order
class Order {
  final int? id;
  final int? customerId; // Buat nullable jika API bisa mengembalikan null
  final String layanan; // 'Antar' or 'Jemput'
  final int? serviceTypeId;
  final String status; // 'Baru', 'Proses', 'Selesai', 'Dibatalkan'
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ServiceType? serviceType; // Nested service type data

  Order({
    this.id,
    this.customerId,
    required this.layanan,
    this.serviceTypeId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.serviceType,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: int.tryParse(json['id']?.toString() ?? ''),
      customerId: int.tryParse(json['customer_id']?.toString() ?? ''),
      layanan: json['layanan'] as String,
      serviceTypeId: int.tryParse(json['service_type_id']?.toString() ?? ''),
      status: json['status'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      serviceType: json['service_type'] != null
          ? ServiceType.fromJson(json['service_type'] as Map<String, dynamic>)
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
      message: json['message'] as String,
      data: json['data'] != null ? Order.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

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
      message: json['message'] as String,
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
