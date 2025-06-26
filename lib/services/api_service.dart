// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugas_16/models/auth_responses.dart';
import 'package:tugas_16/models/error_responses.dart';
import 'package:tugas_16/models/order_list_response.dart';
import 'package:tugas_16/models/order_responses.dart';
import 'package:tugas_16/models/service_type_list_responses.dart';
import 'package:tugas_16/models/single_service_type_responses.dart';
import 'package:tugas_16/models/single_user_responses.dart';

class ApiService {
  final String baseUrl = 'https://applaundry.mobileprojp.com/api';
  String? _authToken; // Store the authentication token

  void setAuthToken(String? token) {
    _authToken = token;
  }

  String? get authToken => _authToken; // Getter for the token

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // --- Authentication Endpoints ---

  Future<AuthResponse> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        ErrorResponse.fromJson(jsonDecode(response.body)).message,
      );
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      if (authResponse.data?.token != null) {
        setAuthToken(
          authResponse.data!.token,
        ); // Store token on successful login
      }
      return authResponse;
    } else {
      throw Exception(
        ErrorResponse.fromJson(jsonDecode(response.body)).message,
      );
    }
  }

  // --- User Profile Endpoints ---
  Future<SingleUserResponse> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return SingleUserResponse.fromJson(jsonDecode(response.body));
    } else {
      if (response.statusCode == 401) {
        throw Exception("Unauthenticated. Please log in again.");
      }
      throw Exception(
        ErrorResponse.fromJson(jsonDecode(response.body)).message,
      );
    }
  }

  Future<SingleUserResponse> updateProfile(String name) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile'), // According to Postman: PUT /profile
      headers: _getHeaders(),
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 200) {
      return SingleUserResponse.fromJson(jsonDecode(response.body));
    } else {
      if (response.statusCode == 401) {
        throw Exception("Unauthenticated. Please log in again.");
      }
      throw Exception(
        ErrorResponse.fromJson(jsonDecode(response.body)).message,
      );
    }
  }

  // --- Service Type Endpoints ---

  Future<ServiceTypeListResponse> getServiceTypes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/layanan'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return ServiceTypeListResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        ErrorResponse.fromJson(jsonDecode(response.body)).message,
      );
    }
  }

  Future<SingleServiceTypeResponse> addServiceType(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/layanan'),
      headers: _getHeaders(),
      body: jsonEncode({'name': name}),
    );

    // FIX: Accept both 200 OK and 201 Created as success status codes
    if (response.statusCode == 201 || response.statusCode == 200) {
      return SingleServiceTypeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        ErrorResponse.fromJson(jsonDecode(response.body)).message,
      );
    }
  }

  Future<SingleServiceTypeResponse> updateServiceType(
    int id,
    String name,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/layanan/$id'),
      headers: _getHeaders(),
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 200) {
      return SingleServiceTypeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        ErrorResponse.fromJson(jsonDecode(response.body)).message,
      );
    }
  }

  Future<SingleServiceTypeResponse> deleteServiceType(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/layanan/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return SingleServiceTypeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        ErrorResponse.fromJson(jsonDecode(response.body)).message,
      );
    }
  }

  // --- Order Endpoints ---

  Future<OrderListResponse> getOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return OrderListResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        ErrorResponse.fromJson(jsonDecode(response.body)).message,
      );
    }
  }

  Future<SingleOrderResponse> getOrderDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return SingleOrderResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        ErrorResponse.fromJson(jsonDecode(response.body)).message,
      );
    }
  }

  Future<SingleOrderResponse> createOrder(
    int customerId,
    String layanan,
    int serviceTypeId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: _getHeaders(),
      body: jsonEncode({
        'customer_id': customerId,
        'layanan': layanan,
        'service_type_id': serviceTypeId,
      }),
    );

    // CHANGED: Accept 200 OK as a success status for creating an order
    if (response.statusCode == 201 || response.statusCode == 200) {
      return SingleOrderResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        ErrorResponse.fromJson(jsonDecode(response.body)).message,
      );
    }
  }

  Future<SingleOrderResponse> updateOrderStatus(int id, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$id/status'),
      headers: _getHeaders(),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      return SingleOrderResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        ErrorResponse.fromJson(jsonDecode(response.body)).message,
      );
    }
  }
}
