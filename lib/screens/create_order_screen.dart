import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_16/models/order_responses.dart';
import 'package:tugas_16/models/service_type_list_responses.dart';

// Import services and models
import 'package:tugas_16/services/api_service.dart';
import 'package:tugas_16/services/local_storage_service.dart';
import 'package:tugas_16/models/service_type.dart';
// For the response of creating a single order

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});
  static const String id = "/create_order_screen";

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final TextEditingController _layananController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<ServiceType> _availableServiceTypes = [];
  ServiceType? _selectedServiceType; // The currently selected service type
  bool _isLoadingServiceTypes = true;
  bool _isCreatingOrder = false;
  String? _serviceTypesErrorMessage;

  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _fetchAvailableServiceTypes();
  }

  @override
  void dispose() {
    _layananController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailableServiceTypes() async {
    if (!mounted) return;
    setState(() {
      _isLoadingServiceTypes = true;
      _serviceTypesErrorMessage = null;
    });

    try {
      final String? token =
          _apiService.authToken ?? await _localStorageService.getAuthToken();
      if (token == null) {
        throw Exception("No authentication token found. Please log in.");
      }
      _apiService.setAuthToken(token);

      final ServiceTypeListResponse response =
          await _apiService.getServiceTypes();

      if (!mounted) return;
      if (response.data.isNotEmpty) {
        setState(() {
          _availableServiceTypes = response.data;
          _selectedServiceType =
              _availableServiceTypes.first; // Select the first by default
        });
      } else {
        setState(() {
          _serviceTypesErrorMessage =
              "No service types available. Please add some from the home screen.";
          _availableServiceTypes = [];
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _serviceTypesErrorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
        _availableServiceTypes = [];
      });
      // Handle unauthenticated case (e.g., redirect to login)
      if (_serviceTypesErrorMessage?.contains("Unauthenticated") == true) {
        // You might want to navigate to login screen here
        // For now, it will just show the error message.
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingServiceTypes = false;
      });
    }
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedServiceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service type.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isCreatingOrder = true;
    });
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // customer_id is hardcoded to 1 for this example.
      // In a real app, you would get the customer_id from the logged-in user's profile.
      // For instance, from _userProfile.id if you fetched it on HomeScreen and passed here.
      // Since we don't have _userProfile directly here, we use a placeholder.
      // If your API automatically associates the order with the authenticated user,
      // you might not even need to send customer_id. Please verify with your backend.
      final SingleOrderResponse response = await _apiService.createOrder(
        1, // Placeholder customer_id. Adjust this based on your app's logic.
        _layananController.text.trim(),
        _selectedServiceType!.id!,
      );

      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // Pop with true to indicate success
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Failed to create order: $errorMessage"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isCreatingOrder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Order'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body:
          _isLoadingServiceTypes
              ? const Center(child: CircularProgressIndicator())
              : _serviceTypesErrorMessage != null
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
                        'Error loading service types: $_serviceTypesErrorMessage',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchAvailableServiceTypes,
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
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Lottie.asset(
                        'assets/lottie/blobs.json', // Add a suitable Lottie animation
                        height: 150,
                        repeat: true,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Select Service Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Dropdown for Service Types
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ServiceType>(
                            isExpanded: true,
                            value: _selectedServiceType,
                            hint: const Text('Choose a service type'),
                            onChanged: (ServiceType? newValue) {
                              setState(() {
                                _selectedServiceType = newValue;
                              });
                            },
                            items:
                                _availableServiceTypes
                                    .map<DropdownMenuItem<ServiceType>>((
                                      ServiceType service,
                                    ) {
                                      return DropdownMenuItem<ServiceType>(
                                        value: service,
                                        child: Text(service.name),
                                      );
                                    })
                                    .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Service Details (e.g., 2kg clothes, shirts only)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _layananController,
                        decoration: InputDecoration(
                          labelText: 'Service Option',
                          hintText: 'e.g., 2kg shirts and trousers',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter service details.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isCreatingOrder ? null : _createOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 3,
                          ),
                          child:
                              _isCreatingOrder
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'PLACE ORDER',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
