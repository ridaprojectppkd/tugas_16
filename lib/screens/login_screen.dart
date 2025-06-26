import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_16/constatnt/app_image.dart';
import 'package:tugas_16/models/auth_responses.dart';
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

class _LoginPageApiState extends State<LoginScreenLaundry> {
  bool _isVisibility = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Initialize the ApiService and LocalStorageService
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

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
          // Background with washing bubbles theme
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImage.bgkuningbiru),
                fit: BoxFit.cover,
              ),
            ),
            child: Opacity(
              opacity: 0.1,
              child: Center(
                child: Positioned(
                  right: 20, // Jarak dari kanan
                  bottom: 20, // Jarak dari bawah
                  child: Lottie.asset(
                    'assets/lottie/blobs.json',
                    width: 150,
                    height: 150,
                    delegates: LottieDelegates(
                      values: [
                        ValueDelegate.color(
                          const ['**'],
                          value: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ).withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  // App Logo and Title
                  Column(
                    children: [
                      Image.asset(
                        AppImage.logolaundrywhite, // Your laundry app logo
                        height: 100,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1), // Dark blue
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Login Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(144, 255, 255, 255),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sign in to continue',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Colors.blue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
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

                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isVisibility,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.blue,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isVisibility
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  setState(
                                    () => _isVisibility = !_isVisibility,
                                  );
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                // Minimum length as per your API example's password requirements (though API expects 8+ with special chars)
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 8),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Navigate to forgot password screen
                                // You can implement navigation to a ForgotPasswordScreen here
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

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
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
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

                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  'OR',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Social Login (Placeholder)
                          SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () {
                                // Handle Google sign in
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Google login not implemented yet!",
                                    ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/google.png', // Add your Google icon asset
                                    height: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Continue with Google',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to your RegisterScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const RegisterScreenLaundry(), // Ensure this path is correct
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
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
    );
  }
}
