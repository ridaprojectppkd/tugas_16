import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Corrected imports to match your project structure: tugas_16
import 'package:tugas_16/models/service_type.dart';
import 'package:tugas_16/models/service_type_list_responses.dart';
import 'package:tugas_16/models/single_user_responses.dart';
import 'package:tugas_16/models/user_model.dart';

import 'package:tugas_16/screens/profile_screen.dart'; // Corrected filename and class name assumption
import 'package:tugas_16/screens/login_screen.dart'; // Corrected class name assumption
import 'package:tugas_16/services/api_service.dart';
import 'package:tugas_16/services/local_storage_service.dart';
import 'package:tugas_16/screens/create_order_screen.dart'; // NEW: Import CreateOrderScreen
import 'package:tugas_16/screens/order_list_screen.dart'; // NEW: Import OrderListScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String id = "/home_screen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _userProfile;
  List<ServiceType> _serviceTypes = [];
  bool _isLoadingProfile = true;
  bool _isLoadingServices = true;
  String? _profileErrorMessage;
  String? _servicesErrorMessage;

  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _fetchUserProfile();
    await _fetchServiceTypes();
  }

  Future<void> _fetchUserProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProfile = true;
      _profileErrorMessage = null;
    });

    try {
      final String? token = await _localStorageService.getAuthToken();
      if (token == null) {
        throw Exception("No authentication token found. Please log in.");
      }
      _apiService.setAuthToken(token);
      final SingleUserResponse response = await _apiService.getProfile();

      if (!mounted) return;
      if (response.data != null) {
        setState(() {
          _userProfile = response.data;
        });
      } else {
        setState(() {
          _profileErrorMessage = response.message;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profileErrorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      if (_profileErrorMessage?.contains("Unauthenticated") == true) {
        _handleLogout();
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _fetchServiceTypes() async {
    if (!mounted) return;
    setState(() {
      _isLoadingServices = true;
      _servicesErrorMessage = null;
    });

    try {
      final String? token =
          _apiService.authToken ?? await _localStorageService.getAuthToken();
      if (token == null) {
        throw Exception("No authentication token found for services.");
      }
      _apiService.setAuthToken(token);

      final ServiceTypeListResponse response =
          await _apiService.getServiceTypes();

      if (!mounted) return;
      if (response.data.isNotEmpty) {
        setState(() {
          _serviceTypes = response.data;
        });
      } else {
        setState(() {
          _servicesErrorMessage = "No service types found.";
          _serviceTypes = [];
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _servicesErrorMessage = e.toString().replaceFirst('Exception: ', '');
        _serviceTypes = [];
      });
      if (_servicesErrorMessage?.contains("Unauthenticated") == true) {
        _handleLogout();
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingServices = false;
      });
    }
  }

  Future<void> _addServiceType() async {
    final TextEditingController nameController = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add New Service Type'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Service Name (e.g., Wash)",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text("Service name cannot be empty!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(); // Close dialog

                if (!mounted) return;
                setState(() {
                  _isLoadingServices = true;
                });

                try {
                  final response = await _apiService.addServiceType(
                    nameController.text.trim(),
                  );
                  if (!mounted) return;
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(response.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  await _fetchServiceTypes(); // Refresh list
                } catch (e) {
                  if (!mounted) return;
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        "Failed to add service: ${e.toString().replaceFirst('Exception: ', '')}",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  if (!mounted) return;
                  setState(() {
                    _isLoadingServices = false;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editServiceType(ServiceType service) async {
    final TextEditingController nameController = TextEditingController(
      text: service.name,
    );
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Service Type'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Service Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text("Service name cannot be empty!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(); // Close dialog

                if (!mounted) return;
                setState(() {
                  _isLoadingServices = true;
                });

                try {
                  final response = await _apiService.updateServiceType(
                    service.id!,
                    nameController.text.trim(),
                  );
                  if (!mounted) return;
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(response.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  await _fetchServiceTypes();
                } catch (e) {
                  if (!mounted) return;
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        "Failed to update service: ${e.toString().replaceFirst('Exception: ', '')}",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  if (!mounted) return;
                  setState(() {
                    _isLoadingServices = false;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteServiceType(int id) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
            'Are you sure you want to delete this service type?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
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
      if (!mounted) return;
      setState(() {
        _isLoadingServices = true;
      });
      try {
        final response = await _apiService.deleteServiceType(id);
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
        await _fetchServiceTypes();
      } catch (e) {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              "Failed to delete service: ${e.toString().replaceFirst('Exception: ', '')}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (!mounted) return;
        setState(() {
          _isLoadingServices = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() {
      _isLoadingProfile = true;
      _isLoadingServices = true;
    });
    try {
      // await _apiService.logout();
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
        MaterialPageRoute(
          builder: (context) => const LoginScreenLaundry(),
        ), // Corrected to LoginScreen
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
        _isLoadingProfile = false;
        _isLoadingServices = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FreshClean Laundry'),
        backgroundColor: const Color(0xFF0D47A1), // Dark blue
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _userProfile == null
                ? Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/download.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: UserAccountsDrawerHeader(
                    accountName:
                        _isLoadingProfile
                            ? const CircularProgressIndicator(
                              color: Color.fromARGB(255, 255, 255, 255),
                            )
                            : Text(
                              _profileErrorMessage ?? 'Loading Profile...',
                            ),
                    accountEmail: const Text(''),
                    currentAccountPicture: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    decoration: const BoxDecoration(color: Colors.transparent),
                  ),
                )
                : Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/download.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: UserAccountsDrawerHeader(
                    accountName: Text(_userProfile!.name),
                    accountEmail: Text(_userProfile!.email),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        _userProfile!.name.isNotEmpty
                            ? _userProfile!.name.substring(0, 1).toUpperCase()
                            : '',
                        style: const TextStyle(
                          fontSize: 40.0,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                    ),
                    decoration: const BoxDecoration(color: Colors.transparent),
                  ),
                ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.wash),
              title: const Text('Services'),
              onTap: () {
                if (mounted) {
                  Navigator.pop(context);
                  _fetchServiceTypes();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('My Orders'),
              onTap: () {
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderListScreen(),
                    ),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body:
          _isLoadingProfile || _isLoadingServices
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Section (similar to the image)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(255, 15, 255, 255),
                            Color.fromARGB(255, 198, 255, 145),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child:
                                    _userProfile != null &&
                                            _userProfile!.name.isNotEmpty
                                        ? Text(
                                          _userProfile!.name
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 30,
                                            color: Color(0xFF0D47A1),
                                          ),
                                        )
                                        : const Icon(
                                          Icons.person,
                                          size: 30,
                                          color: Color(0xFF0D47A1),
                                        ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userProfile?.name ?? 'Guest User',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _userProfile?.email ?? 'Unknown Email',
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        255,
                                        255,
                                        255,
                                      ).withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'My Balance:',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '\$1000', // Placeholder for balance
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildBalanceAction(
                                        'Drop-off',
                                        Icons.local_laundry_service,
                                      ),
                                      _buildBalanceAction(
                                        'Pick up',
                                        Icons.delivery_dining,
                                      ),
                                      _buildBalanceAction(
                                        'Shop',
                                        Icons.shopping_bag,
                                      ),
                                      _buildBalanceAction(
                                        'Top up',
                                        Icons.add_card,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Explore Services Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Explore Our Services',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          TextButton(
                            onPressed: _addServiceType,
                            child: const Text(
                              'Add New',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _isLoadingServices
                        ? const Center(child: CircularProgressIndicator())
                        : _servicesErrorMessage != null
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Error loading services: $_servicesErrorMessage',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        )
                        : _serviceTypes.isEmpty
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text('No services found. Add some!'),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: _addServiceType,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Service'),
                                ),
                              ],
                            ),
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // 2 items per row
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio:
                                      3 /
                                      3, // Adjust aspect ratio for better fit
                                ),
                            itemCount: _serviceTypes.length,
                            itemBuilder: (context, index) {
                              final service = _serviceTypes[index];
                              return _buildServiceCard(service);
                            },
                          ),
                        ),
                    const SizedBox(height: 24),

                    // Active Orders Section - Now navigates to OrderListScreen
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Active Orders',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OrderListScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'View All Orders', // Changed text to be more descriptive
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // You can still have a summary or a Lottie here, but clicking
                    // "View All Orders" will take them to the full list.
                    Center(
                      child: Column(
                        children: [
                          Lottie.asset(
                            'assets/lottie/blobs.json', // Corrected Lottie asset (ensure you have this in assets/lottie)
                            height: 100,
                            repeat: true,
                          ),
                          const Text(
                            'See your ongoing orders by clicking "View All Orders"',
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to CreateOrderScreen and await result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateOrderScreen()),
          );
          // If an order was successfully created (indicated by result == true)
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order created successfully!'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        },
        backgroundColor: const Color(0xFF0D47A1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBalanceAction(String title, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          radius: 25,
          child: Icon(icon, color: Colors.blue, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildServiceCard(ServiceType service) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Icon(
                    Icons.local_laundry_service,
                    size: 40,
                    color: Colors.blue[700],
                  ),
                ), // Generic icon
                const SizedBox(height: 10),
                Text(
                  service.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Since the API doesn't provide a cost, we'll put a placeholder
                const Expanded(
                  // Use Expanded to make sure the text fits
                  child: Text(
                    'Cost: \$XX.XX',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editServiceType(service);
                } else if (value == 'delete') {
                  _deleteServiceType(service.id!);
                }
              },
              itemBuilder:
                  (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
              icon: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
    );
  }
}
