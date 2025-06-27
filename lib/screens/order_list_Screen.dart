import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_16/models/api_model.dart';

// Import semua model dari satu file flutter_models.dart
import 'package:tugas_16/services/api_service.dart';
import 'package:tugas_16/services/local_storage_service.dart';


// Import layar lain yang akan dinavigasi dari sini
import 'package:tugas_16/screens/create_order_screen.dart';
import 'package:tugas_16/screens/login_screen.dart';
import 'package:tugas_16/screens/order_detail_screen.dart';


class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});
  static const String id = "/order_list_screen";

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<Order> _orders = [];
  bool _isLoadingOrders = true;
  String? _errorMessage;

  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() {
      _isLoadingOrders = true;
      _errorMessage = null;
    });

    try {
      final String? token = _apiService.authToken ?? await _localStorageService.getAuthToken();
      if (token == null) {
        throw Exception("No authentication token found. Please log in.");
      }
      _apiService.setAuthToken(token);

      final OrderListResponse response = await _apiService.getOrders();

      if (!mounted) return;
      if (response.data.isNotEmpty) {
        setState(() {
          _orders = response.data;
        });
      } else {
        setState(() {
          _errorMessage = "No orders found.";
          _orders = [];
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _orders = [];
      });
      if (_errorMessage?.contains("Unauthenticated") == true) {
        _handleLogout();
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingOrders = false;
      });
    }
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() { _isLoadingOrders = true; });
    try {
      final SingleOrderResponse response = await _apiService.updateOrderStatus(orderId, newStatus);
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.green),
      );
      await _fetchOrders(); // Refresh the list
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Failed to update status: ${e.toString().replaceFirst('Exception: ', '')}"), backgroundColor: Colors.red),
      );
    } finally {
      if (!mounted) return;
      setState(() { _isLoadingOrders = false; });
    }
  }

  Future<void> _deleteOrder(int orderId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this order?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (!mounted) return;
      setState(() { _isLoadingOrders = true; });
      try {
        final SingleOrderResponse response = await _apiService.deleteOrder(orderId);
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(response.message), backgroundColor: Colors.green),
        );
        await _fetchOrders(); // Refresh the list
      } catch (e) {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Failed to delete order: ${e.toString().replaceFirst('Exception: ', '')}"), backgroundColor: Colors.red),
        );
      } finally {
        if (!mounted) return;
        setState(() { _isLoadingOrders = false; });
      }
    }
  }

  Future<void> _handleLogout() async {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      _isLoadingOrders = true;
    });
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
        _isLoadingOrders = false;
      });
    }
  }

  // Helper to get color based on status
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
        title: const Text('My Orders'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoadingOrders
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $_errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchOrders,
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
              : _orders.isEmpty
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
                            'No orders placed yet!',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final selectedLayanan = await showDialog<String>(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Choose Service Detail'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          title: const Text('Antar'),
                                          onTap: () {
                                            Navigator.of(dialogContext).pop('Antar');
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Jemput'),
                                          onTap: () {
                                            Navigator.of(dialogContext).pop('Jemput');
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );

                              if (selectedLayanan != null) {
                                User? currentUserProfile;
                                try {
                                  final String? token = _apiService.authToken ?? await _localStorageService.getAuthToken();
                                  if (token == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("No authentication token found. Please log in."), backgroundColor: Colors.red),
                                    );
                                    _handleLogout();
                                    return;
                                  }
                                  _apiService.setAuthToken(token);

                                  final userResponse = await _apiService.getProfile();
                                  currentUserProfile = userResponse.data;
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Failed to load user profile for new order: ${e.toString().replaceFirst('Exception: ', '')}"), backgroundColor: Colors.red),
                                  );
                                  if (e.toString().contains("Unauthenticated")) {
                                     _handleLogout();
                                  }
                                  return;
                                }

                                if (currentUserProfile?.id == null) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("User ID not available. Cannot create order."), backgroundColor: Colors.red),
                                  );
                                  return;
                                }

                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateOrderScreen(
                                      userId: currentUserProfile!.id,
                                      initialLayanan: selectedLayanan,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _fetchOrders();
                                }
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Create New Order'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D47A1),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return GestureDetector(
                          onTap: () {
                            if (order.id != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailScreen(orderId: order.id!),
                                ),
                              ).then((_) => _fetchOrders());
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Order ID not available for details.'), backgroundColor: Colors.red),
                              );
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Order ID: ${order.id ?? 'N/A'}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0D47A1),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                            order.status,
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          order.status,
                                          style: TextStyle(
                                            color: _getStatusColor(order.status),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  Text(
                                    'Service Type: ${order.serviceType?.name ?? 'N/A'}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Service Option: ${order.layanan}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Created At: ${order.createdAt?.toLocal().toString().split('.')[0] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Updated At: ${order.updatedAt?.toLocal().toString().split('.')[0] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Estimated Cost: \$XX.XX',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Tombol "Mark as Proses"
                                      if (order.status.toLowerCase() == 'baru')
                                        ElevatedButton(
                                          onPressed: () =>
                                              _updateOrderStatus(order.id!, 'Proses'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Mark as "Proses"'),
                                        ),
                                      const SizedBox(width: 8),
                                      // Tombol "Mark as Selesai"
                                      if (order.status.toLowerCase() == 'proses')
                                        ElevatedButton(
                                          onPressed: () => _updateOrderStatus(
                                            order.id!,
                                            'Selesai',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Mark as "Selesai"'),
                                        ),
                                      const SizedBox(width: 8),
                                      // Tombol Hapus
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteOrder(order.id!),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final selectedLayanan = await showDialog<String>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Choose Service Detail'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: const Text('Antar'),
                      onTap: () {
                        Navigator.of(dialogContext).pop('Antar');
                      },
                    ),
                    ListTile(
                      title: const Text('Jemput'),
                      onTap: () {
                        Navigator.of(dialogContext).pop('Jemput');
                      },
                    ),
                  ],
                ),
              );
            },
          );

          if (selectedLayanan != null) {
            User? currentUserProfile;
            try {
              final String? token = _apiService.authToken ?? await _localStorageService.getAuthToken();
              if (token == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No authentication token found. Please log in."), backgroundColor: Colors.red),
                );
                _handleLogout();
                return;
              }
              _apiService.setAuthToken(token);

              final userResponse = await _apiService.getProfile();
              currentUserProfile = userResponse.data;
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to load user profile for new order: ${e.toString().replaceFirst('Exception: ', '')}"), backgroundColor: Colors.red),
              );
              if (e.toString().contains("Unauthenticated")) {
                 _handleLogout();
              }
              return;
            }

            if (currentUserProfile?.id == null) {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User ID not available. Cannot create order."), backgroundColor: Colors.red),
              );
              return;
            }

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateOrderScreen(
                  userId: currentUserProfile!.id,
                  initialLayanan: selectedLayanan,
                ),
              ),
            );
            if (result == true) {
              _fetchOrders();
            }
          }
        },
        backgroundColor: const Color(0xFF0D47A1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
