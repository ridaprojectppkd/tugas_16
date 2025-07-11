import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_16/constatnt/app_color.dart';
import 'package:tugas_16/models/api_model.dart';
import 'package:tugas_16/screens/login_screen.dart';
import 'package:tugas_16/services/api_service.dart';
import 'package:tugas_16/services/local_storage_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isEditingName = false; // New state to control edit mode for name
  final TextEditingController _nameController =
      TextEditingController(); // Controller for editing name

  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? token = await _localStorageService.getAuthToken();
      if (token == null) {
        throw Exception("No authentication token found. Please log in.");
      }

      _apiService.setAuthToken(token);
      final SingleUserResponse response = await _apiService.getProfile();

      if (response.data != null) {
        setState(() {
          _userProfile = response.data;
          _nameController.text =
              _userProfile!.name; // Set initial value for controller
        });
      } else {
        setState(() {
          _errorMessage = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      if (_errorMessage?.contains("Unauthenticated") == true) {
        _handleLogout();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // New method to handle profile update
  Future<void> _updateProfileName() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name cannot be empty."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading for update operation
    });

    try {
      final SingleUserResponse response = await _apiService.updateProfile(
        _nameController.text.trim(),
      );

      if (response.data != null) {
        setState(() {
          _userProfile = response.data; // Update local profile with new data
          _isEditingName = false; // Exit editing mode
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );

        //////////tambahan navigator/////////////////
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreenLaundry(),
          ), // Navigate to LoginScreen
          (Route<dynamic> route) => false, // Remove all previous routes
        );

        ////////////////////////////
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: $errorMessage"),
          backgroundColor: Colors.red,
        ),
      );
      if (errorMessage.contains("Unauthenticated") == true) {
        _handleLogout();
      }
    } finally {
      setState(() {
        _isLoading = false; // Hide loading
      });
    }
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _localStorageService.clearAuthToken();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Logged out successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreenLaundry()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Logout failed: $errorMessage"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF0D47A1), // Dark blue
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          if (_userProfile !=
              null) // Only show edit button if profile is loaded
            IconButton(
              icon: Icon(_isEditingName ? Icons.check : Icons.edit),
              onPressed: () {
                if (_isEditingName) {
                  _updateProfileName(); // Save changes
                } else {
                  setState(() {
                    _isEditingName = true; // Enter editing mode
                  });
                }
              },
            ),
        ],
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
                        'Error: $_errorMessage',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchUserProfile,
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
              : Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottie/profile.json',
                        height: 300,
                        repeat: true,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Welcome!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child:
                                        _isEditingName
                                            ? TextFormField(
                                              controller: _nameController,
                                              decoration: const InputDecoration(
                                                labelText: 'Name',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 10,
                                                    ),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: AppColor.facebookBlue,
                                              ),
                                            )
                                            : Text(
                                              'Name: ${_userProfile!.name}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: AppColor.facebookBlue,
                                              ),
                                            ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.email_outlined,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Email: ${_userProfile!.email}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: AppColor.facebookBlue,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _handleLogout,
                        icon: const Icon(
                          Icons.logout,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
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
