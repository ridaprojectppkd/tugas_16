import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({super.key});

  @override
  _GoogleMapsScreenState createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  GoogleMapController? mapController;
  LatLng _currentPosition = LatLng(0, 0);
  String _currentAddress = 'Alamat Tidak Diketahui';
  Marker? _marker;

  Future<void> _getCurrentLocation() async {
    // Periksa apakah layanan lokasi aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    // Periksa dan minta izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    // Ambil posisi saat ini dengan akurasi tinggi
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Simpan posisi dalam format LatLng
    _currentPosition = LatLng(position.latitude, position.longitude);

    // Ubah koordinat ke alamat manusiawi
    List<Placemark> placemarks = await placemarkFromCoordinates(
      _currentPosition.latitude,
      _currentPosition.longitude,
    );
    Placemark place = placemarks[0];

    // Update UI dengan marker dan alamat
    setState(() {
      _marker = Marker(
        markerId: MarkerId("lokasi_saya"),
        position: _currentPosition,
        infoWindow: InfoWindow(
          title: 'Lokasi Anda',
          snippet: "${place.street}, ${place.locality}",
        ),
      );

      _currentAddress =
          "${place.name}, ${place.street}, ${place.locality}, ${place.country}";

      // Pindahkan kamera ke posisi saat ini
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 16),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps'),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: () {
              if (_marker != null) {
                mapController?.animateCamera(
                  CameraUpdate.newLatLng(_currentPosition),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 16,
            ),
            markers: _marker != null ? {_marker!} : {},
            onMapCreated: (controller) {
              mapController = controller;
              _getCurrentLocation();
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_currentAddress),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
