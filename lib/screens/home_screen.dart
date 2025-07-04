import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_16/constatnt/app_color.dart';
import 'package:tugas_16/constatnt/app_image.dart';
import 'package:tugas_16/constatnt/app_style.dart';

// PERBAIKAN KRITIS: Hanya import satu file ini untuk semua model
import 'package:tugas_16/models/api_model.dart';
import 'package:tugas_16/screens/google_maps.dart';
import 'package:tugas_16/screens/order_list_Screen.dart';
import 'package:tugas_16/services/api_service.dart';
import 'package:tugas_16/services/local_storage_service.dart';

// Import layar lain yang akan dinavigasi dari sini
import 'package:tugas_16/screens/profile_screen.dart';
import 'package:tugas_16/screens/login_screen.dart';
import 'package:tugas_16/screens/create_order_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String id = "/home_screen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentCarouselIndex = 0; // This tracks the current carousel page
  // final CarouselController _carouselController = CarouselController();

  final List<String> carouselImages = [
    'assets/images/promo1.png',
    'assets/images/promo2.jpg',
    'assets/images/promo3.jpg',
  ];

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
        print(
          'DEBUG(HomeScreen): No authentication token found. Redirecting to login.',
        );
        throw Exception("No authentication token found. Please log in.");
      }
      _apiService.setAuthToken(token);
      print('DEBUG(HomeScreen): Token set: ${token.substring(0, 10)}...');

      final SingleUserResponse response = await _apiService.getProfile();

      if (!mounted) return;
      if (response.data != null) {
        setState(() {
          _userProfile = response.data;
        });
        print(
          'DEBUG(HomeScreen): User profile fetched: ID=${_userProfile?.id}, Name=${_userProfile?.name}',
        );
      } else {
        setState(() {
          _profileErrorMessage = response.message;
        });
        print(
          'DEBUG(HomeScreen): User profile data is null or message: ${response.message}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profileErrorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      print(
        'DEBUG(HomeScreen): Error fetching user profile: $_profileErrorMessage',
      );
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
        print(
          'DEBUG(HomeScreen): No authentication token found for services. Redirecting to login.',
        );
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
        print(
          'DEBUG(HomeScreen): Service types fetched: ${_serviceTypes.length} items.',
        );
      } else {
        setState(() {
          _servicesErrorMessage = "No service types found.";
          _serviceTypes = [];
        });
        print(
          'DEBUG(HomeScreen): No service types found or message: ${response.message}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _servicesErrorMessage = e.toString().replaceFirst('Exception: ', '');
        _serviceTypes = [];
      });
      print(
        'DEBUG(HomeScreen): Error fetching service types: $_servicesErrorMessage',
      );
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
          backgroundColor: AppColor.primaryBlue,
          title: const Text(
            'Add New Service Type',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Service Name (e.g., Wash)",
              hintStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
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
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName:
                  _isLoadingProfile
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
                      : Text(
                        _userProfile?.name ??
                            (_profileErrorMessage ?? 'Loading Profile...'),
                        style: const TextStyle(color: Colors.white),
                      ),
              accountEmail: Text(
                _userProfile?.email ?? (_profileErrorMessage ?? 'Please Login'),
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child:
                    _userProfile != null && _userProfile!.name.isNotEmpty
                        ? Text(
                          _userProfile!.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            color: Color(0xFF0D47A1),
                          ),
                        )
                        : const Icon(
                          Icons.person,
                          size: 40,
                          color: Color(0xFF0D47A1),
                        ),
              ),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/blue.jpg"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color.fromARGB(55, 0, 0, 0),
                    BlendMode.darken,
                  ),
                ),
                color: Color(0xFF0D47A1),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: AppColor.facebookBlue),
              title: const Text('My Profile', style: AppStyle.StyleSatu),
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
              leading: const Icon(Icons.wash, color: AppColor.facebookBlue),
              title: const Text('Services', style: AppStyle.StyleSatu),
              onTap: () {
                if (mounted) {
                  Navigator.pop(context);
                  // _fetchServ
                  // iceTypes();
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.receipt_long,
                color: AppColor.facebookBlue,
              ),
              title: const Text('My Orders', style: AppStyle.StyleSatu),
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
            ListTile(
              leading: const Icon(
                Icons.my_location,
                color: AppColor.facebookBlue,
              ),
              title: const Text('My Location', style: AppStyle.StyleSatu),
              onTap: () {
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GoogleMapsScreen(),
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
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(255, 2, 0, 129),
                            Color.fromARGB(244, 4, 205, 219),
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
                                radius: 45,
                                backgroundImage: NetworkImage(
                                  'https://i.pravatar.cc/300', // Still using a random avatar image
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
                                      color: Colors.white.withOpacity(0.8),
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
                                        '\$1000', // Placeholder untuk saldo
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
                    /////////////////////CAROUSEL////////////////////////////////////////////////
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Promo & Highlights',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CarouselSlider(
                          items:
                              carouselImages.map((imagePath) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.asset(
                                      imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: Colors.grey[300],
                                                child: Icon(Icons.error),
                                              ),
                                    ),
                                  ),
                                );
                              }).toList(),
                          options: CarouselOptions(
                            autoPlay: true,
                            enlargeCenterPage: true,
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.9,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentCarouselIndex = index;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0; i < carouselImages.length; i++)
                              Container(
                                width: 8.0,
                                height: 8.0,
                                margin: EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      i == _currentCarouselIndex
                                          ? Color(0xFF0D47A1)
                                          : Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    //////////////////
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
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 4 / 4,
                                ),
                            itemCount: _serviceTypes.length,
                            itemBuilder: (context, index) {
                              final service = _serviceTypes[index];
                              return _buildServiceCard(service);
                            },
                          ),
                        ),
                    const SizedBox(height: 24),

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
                              'View All Orders',
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
                    Center(
                      child: Column(
                        children: [
                          Lottie.asset(
                            'assets/lottie/order.json',
                            height: 200,

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
          final selectedLayanan = await showDialog<String>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                backgroundColor: AppColor.primaryBlue,
                title: Center(
                  child: const Text(
                    'Choose Service Detail',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Antar Option
                    InkWell(
                      onTap: () {
                        Navigator.of(dialogContext).pop('Antar');
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 150,
                            width: 150,
                            child: Lottie.asset(
                              'assets/lottie/delivery.json', // Replace with your Lottie file
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColor.blueButton,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: const Text(
                              'Antar',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Jemput Option
                    InkWell(
                      onTap: () {
                        Navigator.of(dialogContext).pop('Jemput');
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 150,
                            width: 150,
                            child: Lottie.asset(
                              'assets/lottie/cash.json', // Replace with your Lottie file
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColor.blueButton,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: const Text(
                              'Jemput',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );

          if (selectedLayanan != null) {
            User? currentUserProfile;
            try {
              print('DEBUG(HomeScreen FAB): Attempting to get auth token...');
              final String? token =
                  _apiService.authToken ??
                  await _localStorageService.getAuthToken();
              if (token == null) {
                print(
                  'DEBUG(HomeScreen FAB): No auth token found. Redirecting to login.',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "No authentication token found. Please log in.",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                _handleLogout();
                return;
              }
              _apiService.setAuthToken(token);
              print(
                'DEBUG(HomeScreen FAB): Token set: ${token.substring(0, 10)}...',
              );

              print('DEBUG(HomeScreen FAB): Fetching user profile...');
              final userResponse = await _apiService.getProfile();
              currentUserProfile = userResponse.data;
              print(
                'DEBUG(HomeScreen FAB): User profile fetched: ${currentUserProfile?.id ?? 'NULL ID'}',
              );
            } catch (e) {
              print('DEBUG(HomeScreen FAB): Error fetching user profile: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Failed to load user profile for new order: ${e.toString().replaceFirst('Exception: ', '')}",
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              if (e.toString().contains("Unauthenticated")) {
                _handleLogout();
              }
              return;
            }

            if (currentUserProfile?.id == null) {
              print(
                'DEBUG(HomeScreen FAB): User ID is NULL after fetching profile. Cannot create order.',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("User ID not available. Cannot create order."),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            print(
              'DEBUG(HomeScreen FAB): User ID to be passed: ${currentUserProfile!.id}',
            );

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => CreateOrderScreen(
                      userId: currentUserProfile!.id,
                      initialLayanan: selectedLayanan,
                    ),
              ),
            );
            if (result == true) {
              _fetchServiceTypes();
            }
          }
        },
        ////////////////floating action button
        backgroundColor: const Color.fromARGB(255, 4, 41, 97),

        // child: const Icon(Icons.add, color: Colors.white),
        child: Lottie.asset(
          'assets/lottie/add.json',
          width: 50, // Sesuaikan ukuran
          height: 50,
          fit: BoxFit.contain,

          repeat: true,
        ),
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
      color: AppColor.facebookBlue,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 180, // Set minimum height
          maxHeight: 180, // Set maximum height to prevent overflow
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0), // Reduced padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 70, // Fixed height for image
                    child: Center(
                      child: Image.asset(
                        AppImage.logolaundrypolos,
                        fit: BoxFit.contain, // Ensure image fits
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Cost: \$XX.XX',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton<String>(
                iconSize: 20, // Smaller icon
                onSelected: (value) {
                  if (value == 'edit') {
                    _editServiceType(service);
                  } else if (value == 'delete') {
                    _deleteServiceType(service.id!);
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
