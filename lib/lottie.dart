import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottiePage extends StatelessWidget {
  static var id;

  const LottiePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            // Konten utama Anda (bisa ListView/Column/dll)
            ListView(
              children: [
                // Konten halaman Anda di sini
              ],
            ),

            // Animasi Lottie di posisi tertentu
            Positioned(
              right: 20, // Jarak dari kanan
              bottom: 20, // Jarak dari bawah
              child: Lottie.asset(
                'assets/lottie/blobs.json',
                width: 150,
                height: 150,
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.color(const [
                      '**',
                    ], value: Colors.blue.withOpacity(0.2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
