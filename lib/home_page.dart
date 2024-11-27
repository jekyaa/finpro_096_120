import 'package:finpro/toilet_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poop Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PoopMapScreen(),
    );
  }
}

class Toilet {
  final String id;
  final String name;
  final String description;
  final int rating;
  final String price;
  final LatLng position;
  final Map<String, bool> features;
  final String timestamp;
  List<Comment> comments; // Menambahkan daftar komentar ke dalam objek Toilet

  Toilet({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.price,
    required this.position,
    required this.features,
    required this.timestamp,
    this.comments = const [], // Inisialisasi dengan list kosong
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'rating': rating,
        'price': price,
        'position': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        'features': features,
        'timestamp': timestamp,
      };

  factory Toilet.fromJson(Map<String, dynamic> json) {
    return Toilet(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      rating: json['rating'],
      price: json['price'],
      position: LatLng(
        json['position']['latitude'],
        json['position']['longitude'],
      ),
      features: Map<String, bool>.from(json['features']),
      timestamp: json['timestamp'],
    );
  }

  double? get longitude => null;
}

class PoopMapScreen extends StatefulWidget {
  const PoopMapScreen({Key? key}) : super(key: key);

  @override
  _PoopMapScreenState createState() => _PoopMapScreenState();
}

class _PoopMapScreenState extends State<PoopMapScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  List<Toilet> toilets = [];
  final String storageKey = 'poop_map_toilets';

  // Default camera position (Jakarta)
  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(-6.2088, 106.8456),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _loadToilets();
    _getCurrentLocation();
  }

  Future<void> _loadToilets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? toiletsJson = prefs.getString(storageKey);
    if (toiletsJson != null) {
      final List<dynamic> decoded = json.decode(toiletsJson);
      setState(() {
        toilets = decoded.map((item) => Toilet.fromJson(item)).toList();
        _updateMarkers();
      });
    }
  }

  Future<void> _saveToilets() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(toilets.map((t) => t.toJson()).toList());
    await prefs.setString(storageKey, encoded);
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      final CameraPosition newPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14.0,
      );

      mapController?.animateCamera(CameraUpdate.newCameraPosition(newPosition));
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _updateMarkers() {
    setState(() {
      markers = toilets
          .map((toilet) => Marker(
                markerId: MarkerId(toilet.id),
                position: toilet.position,
                infoWindow: InfoWindow(
                  title: toilet.name,
                  snippet: '${toilet.description}\nRating: ${toilet.rating}/5',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
              ))
          .toSet();
    });
  }

  void _showAddToiletDialog(LatLng position) {
    String name = '';
    String description = '';
    String price = '';
    int rating = 0;
    Map<String, bool> features = {
      'handicapAccessible': false,
      'babyStation': false,
      'parkingAvailable': false,
      'publicRestroom': false,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tambah Toilet Baru',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nama Lokasi',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => name = value,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) => description = value,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Harga (opsional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => price = value,
                  ),
                  const SizedBox(height: 12),
                  const Text('Rating:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  const Text('Fasilitas:'),
                  CheckboxListTile(
                    title: const Text('Akses Difabel'),
                    value: features['handicapAccessible'],
                    onChanged: (bool? value) {
                      setState(() {
                        features['handicapAccessible'] = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Baby Station'),
                    value: features['babyStation'],
                    onChanged: (bool? value) {
                      setState(() {
                        features['babyStation'] = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Parking Available'),
                    value: features['parkingAvailable'],
                    onChanged: (bool? value) {
                      setState(() {
                        features['parkingAvailable'] = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Public Restroom'),
                    value: features['publicRestroom'],
                    onChanged: (bool? value) {
                      setState(() {
                        features['publicRestroom'] = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (name.isNotEmpty) {
                            final newToilet = Toilet(
                              id: DateTime.now().toString(),
                              name: name,
                              description: description,
                              rating: rating,
                              price: price,
                              position: position,
                              features: features,
                              timestamp: DateTime.now().toIso8601String(),
                            );
                            setState(() {
                              toilets.add(newToilet);
                              _updateMarkers();
                              _saveToilets();
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poop Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            initialCameraPosition: initialPosition,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onLongPress: _showAddToiletDialog,
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Peta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Daftar Toilet',
          ),
        ],
        onTap: (index) {
          // Logika untuk berpindah antar halaman
          if (index == 0) {
            // Peta
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PoopMapScreen()),
            );
          } else if (index == 1) {
            // Daftar Toilet
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ToiletListScreen(toilets: toilets)),
            );
          }
        },
      ),
    );
  }
}

class ToiletListScreen extends StatelessWidget {
  final List<Toilet> toilets;

  const ToiletListScreen({Key? key, required this.toilets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Daftar Toilet',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.deepPurpleAccent),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: toilets.length,
          itemBuilder: (context, index) {
            final toilet = toilets[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: () {
                    // Navigasi ke layar detail toilet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ToiletDetailScreen(toilet: toilet)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurpleAccent.shade100,
                          Colors.deepPurpleAccent.shade100
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon placeholder untuk gambar toilet
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.wc,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Detail toilet
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                toilet.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                toilet.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${toilet.rating}/5',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
