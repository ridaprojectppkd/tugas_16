import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_16/models/api_model.dart';

// Import semua model dari satu file flutter_models.dart
import 'package:tugas_16/services/api_service.dart';
import 'package:tugas_16/services/local_storage_service.dart';

class CreateOrderScreen extends StatefulWidget {
  final int? userId;
  final String? initialLayanan; // Parameter opsional untuk layanan awal

  const CreateOrderScreen({
    super.key,
    this.userId,
    this.initialLayanan, // Inisialisasi di konstruktor
  });
  static const String id = "/create_order_screen";

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen>
    with TickerProviderStateMixin {
  final TextEditingController _layananController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _loadingController;

  List<ServiceType> _availableServiceTypes = [];
  ServiceType? _selectedServiceType;
  bool _isLoadingServiceTypes = true;
  bool _isCreatingOrder = false;
  String? _serviceTypesErrorMessage;

  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 15000),
      vsync: this,
    )..repeat();
    // Jika initialLayanan diberikan, set ke controller
    if (widget.initialLayanan != null) {
      _layananController.text = widget.initialLayanan!;
    }
    _fetchAvailableServiceTypes();
  }

  @override
  void dispose() {
    _layananController.dispose();
    _loadingController.dispose();
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
          // Hanya set _selectedServiceType jika itu null, atau list berubah signifikan
          if (_selectedServiceType == null ||
              !_availableServiceTypes.contains(_selectedServiceType)) {
            _selectedServiceType =
                _availableServiceTypes
                    .first; // Pilih yang pertama secara default
          }
        });
      } else {
        setState(() {
          _serviceTypesErrorMessage =
              "No service types available. Please add some from the home screen.";
          _availableServiceTypes = [];
          _selectedServiceType =
              null; // Pastikan tidak ada service type yang terpilih jika list kosong
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
        _selectedServiceType = null;
      });
      // Handle unauthenticated case (e.g., redirect to login)
      if (_serviceTypesErrorMessage?.contains("Unauthenticated") == true) {
        // Anda mungkin ingin menavigasi ke layar login di sini
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

    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User ID not available. Please log in again.'),
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
      final int customerId = widget.userId!;
      final String layanan = _layananController.text.trim();
      final int serviceTypeId = _selectedServiceType!.id!;

      print('DEBUG: Creating order with:');
      print('DEBUG:   customer_id: $customerId');
      print('DEBUG:   layanan: $layanan');
      print('DEBUG:   service_type_id: $serviceTypeId');

      final SingleOrderResponse response = await _apiService.createOrder(
        customerId,
        layanan,
        serviceTypeId,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottie/createorder.json', // Add a suitable Lottie animation
                        height: 300,
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
                        'Service Details (e.g., Antar, Jemput)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _layananController,
                        readOnly:
                            widget.initialLayanan !=
                            null, // Membuat readOnly jika initialLayanan diberikan
                        decoration: InputDecoration(
                          labelText: 'Service Option',
                          hintText:
                              widget.initialLayanan ??
                              'e.g., 2kg shirts and trousers', // Menampilkan hint sesuai initialLayanan
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
                                  ? SizedBox(
                                    width:
                                        24, // Match your CircularProgressIndicator size
                                    height: 24,
                                    child: Lottie.asset(
                                      'assets/lottie/loading.json', // Your loading animation
                                      fit: BoxFit.contain,
                                      controller: _loadingController,
                                      onLoaded: (composition) {
                                        _loadingController
                                          ..duration = composition.duration
                                          ..repeat();
                                      },
                                    ),
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
