import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_16/models/api_model.dart';

// Mengimport semua model dari satu file flutter_models.dart
import 'package:tugas_16/services/api_service.dart';
import 'package:tugas_16/services/local_storage_service.dart';

// Import layar login untuk kasus unauthenticated
import 'package:tugas_16/screens/login_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId; // ID pesanan yang akan ditampilkan detailnya

  const OrderDetailScreen({super.key, required this.orderId});

  static const String id = "/order_detail_screen";

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _orderDetail;
  bool _isLoading = true;
  String? _errorMessage;

  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  // Mengambil detail pesanan dari API
  Future<void> _fetchOrderDetail() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? token =
          _apiService.authToken ?? await _localStorageService.getAuthToken();
      if (token == null) {
        print(
          'DEBUG(OrderDetailScreen): No authentication token found. Redirecting to login.',
        );
        throw Exception("No authentication token found. Please log in.");
      }
      _apiService.setAuthToken(token);
      print(
        'DEBUG(OrderDetailScreen): Token set: ${token.substring(0, 10)}...',
      );

      final SingleOrderResponse response = await _apiService.getOrderDetail(
        widget.orderId,
      );

      if (!mounted) return;
      if (response.data != null) {
        setState(() {
          _orderDetail = response.data;
        });
        print(
          'DEBUG(OrderDetailScreen): Order detail fetched for ID: ${widget.orderId}',
        );
      } else {
        setState(() {
          _errorMessage = response.message;
        });
        print(
          'DEBUG(OrderDetailScreen): Order detail data is null or message: ${response.message}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      print(
        'DEBUG(OrderDetailScreen): Error fetching order detail: $_errorMessage',
      );
      if (_errorMessage?.contains("Unauthenticated") == true) {
        _handleLogout(); // Otomatis logout jika tidak terautentikasi
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Menangani proses logout (mirip dengan HomeScreen/OrderListScreen)
  Future<void> _handleLogout() async {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      _isLoading = true;
    }); // Tampilkan loading saat logout

    try {
      await _localStorageService.clearAuthToken();
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Logged out successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreenLaundry()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Logout failed: $errorMessage"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper untuk mendapatkan warna berdasarkan status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'baru':
        return Colors.blue;
      case 'proses':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body:
          _isLoading
              ? Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Lottie.asset(
                    'assets/lottie/loading.json',
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
              )
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading order details: $_errorMessage',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchOrderDetail,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : _orderDetail == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/empty_box.json',
                      height: 150,
                      repeat: false,
                    ),
                    const Text(
                      'Order details not found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Order #${_orderDetail!.id ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                        ),
                        const Divider(height: 30, thickness: 2),
                        _buildDetailRow(
                          'Customer ID:',
                          _orderDetail!.customerId?.toString() ?? 'N/A',
                          Icons.person,
                        ),
                        _buildDetailRow(
                          'Service Type:',
                          _orderDetail!.serviceType?.name ?? 'N/A',
                          Icons.wash,
                        ),
                        _buildDetailRow(
                          'Service Option:',
                          _orderDetail!.layanan,
                          Icons.delivery_dining,
                        ),
                        _buildDetailRow(
                          'Status:',
                          _orderDetail!.status,
                          Icons.info_outline,
                          color: _getStatusColor(_orderDetail!.status),
                        ),
                        _buildDetailRow(
                          'Created At:',
                          _orderDetail!.createdAt?.toLocal().toString().split(
                                '.',
                              )[0] ??
                              'N/A',
                          Icons.calendar_today,
                        ),
                        _buildDetailRow(
                          'Updated At:',
                          _orderDetail!.updatedAt?.toLocal().toString().split(
                                '.',
                              )[0] ??
                              'N/A',
                          Icons.update,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Estimated Cost:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$XX.XX',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_orderDetail!.status.toLowerCase() == 'baru' ||
                            _orderDetail!.status.toLowerCase() == 'proses')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  () =>
                                      _showCancelOrderDialog(_orderDetail!.id!),
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Cancel Order',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCancelOrderDialog(int orderId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: const Text(
            'Are you sure you want to cancel this order? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _updateOrderStatus(orderId, 'Dibatalkan');
    }
  }

  // Fungsi untuk update status pesanan (digunakan untuk pembatalan)
  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      _isLoading = true;
    });

    try {
      final SingleOrderResponse response = await _apiService.updateOrderStatus(
        orderId,
        newStatus,
      );
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );
      await _fetchOrderDetail();
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            "Failed to update status: ${e.toString().replaceFirst('Exception: ', '')}",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }
}
