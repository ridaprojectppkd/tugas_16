import 'package:flutter/material.dart';
import 'package:tugas_16/screens/order_list_Screen.dart';

// Import screens Anda
// Pastikan path ini benar untuk struktur proyek Anda
import 'package:tugas_16/screens/profile_screen.dart'; // Menggunakan profile_screen.dart dan ProfileScreen
import 'package:tugas_16/screens/create_order_screen.dart';
import 'package:tugas_16/screens/home_screen.dart';
import 'package:tugas_16/screens/login_screen.dart'; // Menggunakan login_screen.dart dan LoginScreen
import 'package:tugas_16/screens/register_screen.dart'; // Asumsi RegisterScreen
import 'package:tugas_16/screens/splashlottie.dart';

import 'package:tugas_16/screens/order_detail_screen.dart'; // Menambahkan import OrderDetailScreen

import 'package:tugas_16/services/api_service.dart';
import 'package:tugas_16/services/local_storage_service.dart';

Future<void> main() async {
  // Pastikan Flutter widgets diinisialisasi sebelum mengakses plugin seperti SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  final LocalStorageService localStorageService = LocalStorageService();
  final ApiService apiService = ApiService();

  // Cek apakah token ada saat aplikasi dimulai
  final String? authToken = await localStorageService.getAuthToken();

  // Set token di ApiService jika ada
  if (authToken != null) {
    apiService.setAuthToken(authToken);
    print(
      'App starting with existing token: ${authToken.substring(0, 10)}...',
    ); // Debug print
  } else {
    print('App starting without existing token.'); // Debug print
  }

  // initialRoute akan selalu Splashlottie.id, karena Splashlottie yang akan menangani navigasi
  // berdasarkan status login setelah animasinya selesai.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // initialRoute tidak lagi diperlukan di sini

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Laundry App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Selalu mulai dengan Splashlottie
      initialRoute: Splashlottie.id,
      routes: {
        Splashlottie.id: (context) => const Splashlottie(),
        LoginScreenLaundry.id:
            (context) =>
                const LoginScreenLaundry(), // Menggunakan LoginScreen.id
        RegisterScreenLaundry.id:
            (context) =>
                const RegisterScreenLaundry(), // Asumsi RegisterScreen.id
        HomeScreen.id: (context) => const HomeScreen(),
        '/profile':
            (context) => const ProfilePage(), // Menggunakan ProfileScreen.id
        CreateOrderScreen.id: (context) => const CreateOrderScreen(),
        OrderListScreen.id:
            (context) =>
                const OrderListScreen(), // Menambahkan rute OrderListScreen
        OrderDetailScreen.id:
            (context) => const OrderDetailScreen(
              orderId: 0,
            ), // Menambahkan rute OrderDetailScreen
      },
    );
  }
}
