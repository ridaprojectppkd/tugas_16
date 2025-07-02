import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_16/constatnt/app_image.dart';
import 'package:tugas_16/models/api_model.dart';
import 'package:tugas_16/screens/home_screen.dart';
import 'package:tugas_16/screens/register_screen.dart';
import 'package:tugas_16/services/api_service.dart';
import 'package:tugas_16/services/local_storage_service.dart';
// Import your custom AppImage for local assets (ensure path is correct)

class LoginScreenLaundry extends StatefulWidget {
  const LoginScreenLaundry({super.key});
  static const String id = "/login_screen_api";

  @override
  State<LoginScreenLaundry> createState() => _LoginPageApiState();
}

class _LoginPageApiState extends State<LoginScreenLaundry>
    with TickerProviderStateMixin {
  // bool _isVisibility = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _loadingcontroller;

  // Initialize the ApiService and LocalStorageService
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  //////////////////
  /// @override
  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _loadingcontroller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _loadingcontroller.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

  ///////////////////////
  void _login() async {
    // Validate the form before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call the login method from ApiService
      final AuthResponse response = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );

      // Check if login was successful and a token is returned
      if (response.data != null && response.data!.token != null) {
        // Save the authentication token to shared preferences
        await _localStorageService.saveAuthToken(response.data!.token!);

        // Set the token in ApiService for subsequent authenticated requests
        _apiService.setAuthToken(response.data!.token!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to the ProfilePage or your main application screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ), // Adjust this to your main app screen
        );
      } else {
        // This case might occur if the API returns a success message
        // but no token (unlikely for a login, but good to handle).
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Handle API errors (e.g., password incorrect, email not registered)
      String errorMessage = 'An unknown error occurred.';
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        ); // Clean up exception message
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: $errorMessage"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with laundry-themed image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImage.bgkuningbiru),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(height: 70),
                  // App Logo
                  Image.asset(
                    AppImage.logolaundrypolos,
                    width: 200, // Add your logo
                    height: 300,
                  ),
                  // Welcome Text
                  Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Login to enjoy our premium services',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  SizedBox(height: 40),
                  // Registration Form
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        0,
                        255,
                        255,
                        255,
                      ).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              // Based on your API's error message, it expects 8+ chars and mixed case/symbols
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters.';
                              }
                              if (!value.contains(RegExp(r'[A-Z]'))) {
                                return 'Password must contain an uppercase letter.';
                              }
                              if (!value.contains(RegExp(r'[a-z]'))) {
                                return 'Password must contain a lowercase letter.';
                              }
                              if (!value.contains(
                                RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'),
                              )) {
                                return 'Password must contain a number or symbol.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF0D47A1,
                                ), // Dark blue
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 3,
                              ),
                              child:
                                  _isLoading
                                      ? SizedBox(
                                        width:
                                            24, // Match your CircularProgressIndicator size
                                        height: 24,
                                        child: Lottie.asset(
                                          'assets/lottie/loading.json', // Your loading animation
                                          fit: BoxFit.contain,
                                          controller: _loadingcontroller,
                                          onLoaded: (composition) {
                                            _loadingcontroller
                                              ..duration = composition.duration
                                              ..repeat();
                                          },
                                        ),
                                      )
                                      : const Text(
                                        'LOGIN',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  color: Colors.black54,
                                ), // Adjust color for visibility on white card
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigate back to the login screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              RegisterScreenLaundry(), // Ensure this path is correct
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }
}
