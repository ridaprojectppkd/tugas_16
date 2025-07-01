import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_16/constatnt/app_image.dart';
import 'package:tugas_16/screens/home_screen.dart'; // Import HomeScreen
import 'package:tugas_16/screens/login_screen.dart'; // Import LoginScreen
import 'package:tugas_16/services/local_storage_service.dart'; // NEW: Import LocalStorageService

class Splashlottie extends StatefulWidget {
  static const String id = "/splash_lottie";
  const Splashlottie({super.key});

  @override
  State<Splashlottie> createState() => _SplashlottieState();
}

class _SplashlottieState extends State<Splashlottie>
    with TickerProviderStateMixin {
  late AnimationController _cornerController;
  late AnimationController _logoController; // Controller for logo animation
  final LocalStorageService _localStorageService =
      LocalStorageService(); // NEW: Instantiate LocalStorageService

  @override
  void initState() {
    super.initState();
    _cornerController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true); // Makes the animation pulse

    _logoController = AnimationController(
      // Initialize logo controller
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _navigateToHome();
  }

  _navigateToHome() async {
    // Tunggu durasi animasi splash screen
    await Future.delayed(
      const Duration(
        seconds: 3,
      ), // Sesuaikan dengan durasi total animasi Lottie Anda
    );

    if (!mounted) return;

    // NEW: Cek status login
    final String? authToken = await _localStorageService.getAuthToken();

    if (!mounted) return; // Pastikan widget masih ada sebelum navigasi

    if (authToken != null && authToken.isNotEmpty) {
      // Jika token ada, navigasi ke HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Jika token tidak ada, navigasi ke LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreenLaundry(),
        ), // Menggunakan LoginScreen
      );
    }
  }

  @override
  void dispose() {
    _cornerController.dispose();
    _logoController.dispose(); // Dispose logo controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1), // Match your app theme
      body: Stack(
        children: [
          // Top Left Blob
          Positioned(
            top: 0,
            left: 0,
            child: Lottie.asset(
              'assets/lottie/corner.json',
              controller: _cornerController,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              onLoaded: (composition) {
                _cornerController
                  ..duration = composition.duration
                  ..forward();
              },
            ),
          ),

          // Top Right Blob
          Positioned(
            top: 0,
            right: 0,
            child: Lottie.asset(
              'assets/lottie/corner.json',
              controller: _cornerController,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),

          // Bottom Left Blob
          Positioned(
            bottom: 0,
            left: 0,
            child: Lottie.asset(
              'assets/lottie/corner.json',
              controller: _cornerController,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),

          // Bottom Right Blob
          Positioned(
            bottom: 0,
            right: 0,
            child: Lottie.asset(
              'assets/lottie/corner.json',
              controller: _cornerController,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),

          // Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Menggunakan Lottie untuk logo utama jika Anda ingin animasi
                Image.asset(AppImage.logolaundrypolos, width: 200, height: 300),
                const SizedBox(height: 20),
                const Text(
                  'FreshClean Laundry', // Ganti dengan nama aplikasi Anda
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your clothes, our care.', // Slogan atau tagline
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
