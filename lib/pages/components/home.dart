import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Suitable for most situations
import 'package:flutter_map/plugin_api.dart'; // Only import if required functionality is not exposed by default
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home(this.onItemTapped, {super.key});
  final void Function(int index, bool choose) onItemTapped;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var pagesName = 'Home';
  dynamic latitude = 0.0;
  dynamic longitude = 0.0;

  @override
  void initState() {
    super.initState();
    initLocationService();
  }

  Future<void> initLocationService() async {
    // Check if location permission is granted
    var status = await Permission.location.status;

    if (status.isDenied) {
      await Permission.location.request();
    }

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
        });

        print("Latitude: $latitude, Longitude: $longitude");
      } catch (e) {
        print("Error getting location: $e");
      }
    } else {
      print("Location permission is denied.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(-7.944152, 112.614816),
          zoom: 9.2,
        ),
        nonRotatedChildren: [
          AttributionWidget.defaultWidget(
            source: 'OpenStreetMap contributors',
            onSourceTapped: null,
          ),
        ],
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitude, longitude),
                width: 80,
                height: 80,
                builder: (context) => const Icon(Icons.my_location),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
