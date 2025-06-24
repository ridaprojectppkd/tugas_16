import 'package:flutter/material.dart';

// Import your login and registration screens
// Ensure these paths are correct for your project structure
import 'package:tugas_16/screens/Profile_screen.dart';
import 'package:tugas_16/screens/login_screen.dart';
import 'package:tugas_16/screens/register_screen.dart'; // Your profile page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laundry App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Define your initial route and other routes
      initialRoute: LoginScreenLaundry.id, // Set LoginScreenLaundry as the initial route
      routes: {
        LoginScreenLaundry.id: (context) => const LoginScreenLaundry(),
        RegisterScreenLaundry.id: (context) => const RegisterScreenLaundry(),
        // You might want to define other routes here, e.g., ProfilePage.id
        '/profile': (context) => const ProfilePage(), // Example for ProfilePage
      },
    );
  }
}
