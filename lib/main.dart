import 'package:flutter/material.dart';
import 'package:tugas_16/lottie.dart';

// Import your login and registration screens
// Ensure these paths are correct for your project structure
import 'package:tugas_16/screens/Profile_screen.dart';
import 'package:tugas_16/screens/create_order_screen.dart';
import 'package:tugas_16/screens/home_screen.dart';
import 'package:tugas_16/screens/login_screen.dart';
import 'package:tugas_16/screens/register_screen.dart';
import 'package:tugas_16/services/api_service.dart';
import 'package:tugas_16/services/local_storage_service.dart'; // Your profile page

Future<void> main() async {
  // Ensure Flutter widgets are initialized before accessing plugins like SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  final LocalStorageService localStorageService = LocalStorageService();
  final ApiService apiService = ApiService();

  // Check if a token exists when the app starts
  final String? authToken = await localStorageService.getAuthToken();

  // Set the token in ApiService if it exists
  if (authToken != null) {
    apiService.setAuthToken(authToken);
    print(
      'App starting with existing token: ${authToken.substring(0, 10)}...',
    ); // Debug print
  } else {
    print('App starting without existing token.'); // Debug print
  }

  // Determine the initial route based on token presence
  String initialRoute =
      authToken != null ? HomeScreen.id : LoginScreenLaundry.id;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laundry App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Use the determined initial route
      initialRoute: initialRoute,
      routes: {
        LoginScreenLaundry.id: (context) => const LoginScreenLaundry(),
        RegisterScreenLaundry.id: (context) => const RegisterScreenLaundry(),
        HomeScreen.id: (context) => const HomeScreen(),
        '/profile': (context) => const ProfilePage(),
          CreateOrderScreen.id: (context) => const CreateOrderScreen(), // ADD THIS LINE
      },
    );
  }
}
