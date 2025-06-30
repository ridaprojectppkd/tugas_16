import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_16/screens/home_screen.dart';

class Splashlottie extends StatefulWidget {
  static const String id = "/splash_lottie";
  const Splashlottie({super.key});

  @override
  State<Splashlottie> createState() => _SplashlottieState();
}

class _SplashlottieState extends State<Splashlottie>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(
      const Duration(seconds: 10),
    ); // Match animation duration
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1), // Match your app theme
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // Lottie.asset(
            //   'assets/lottie/laundrylottie.json', // Your Lottie file
            //   controller: _controller,
            //   height: 200,
            //   fit: BoxFit.contain,
            //   onLoaded: (composition) {
            //     _controller
            //       ..duration = composition.duration
            //       ..forward();
            //   },
            // ),
            Positioned(
  top: Tween<double>(begin: 0, end: 100).animate(_controller).value,
  left: 20,

              child: Lottie.asset(
                'assets/lottie/laundrylottie.json', // Your Lottie file
                controller: _controller,
                height: 200,
                fit: BoxFit.contain,
                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..forward();
                },
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Cuci Bersih',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
