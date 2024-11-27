import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Toilet {
  final String name;
  final String description;
  final double rating;
  final double latitude; // Tambahkan latitude
  final double longitude; // Tambahkan longitude

  Toilet({
    required this.name,
    required this.description,
    required this.rating,
    required this.latitude,
    required this.longitude,
  });
}

class GoogleMapScreen extends StatefulWidget {
  final Toilet toilet;

  const GoogleMapScreen({Key? key, required this.toilet}) : super(key: key);

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController mapController;
  late LatLng toiletLocation;

  @override
  void initState() {
    super.initState();
    // Inisialisasi lokasi toilet
    toiletLocation = LatLng(widget.toilet.latitude, widget.toilet.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lokasi ${widget.toilet.name}'),
        backgroundColor: Colors.teal,
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: toiletLocation,
          zoom: 15.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId(widget.toilet.name),
            position: toiletLocation,
            infoWindow: InfoWindow(
              title: widget.toilet.name,
              snippet: widget.toilet.description,
            ),
          ),
        },
      ),
    );
  }
}
