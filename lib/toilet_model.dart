import 'package:google_maps_flutter/google_maps_flutter.dart';

class Toilet {
  final String id;
  final String name;
  final String description;
  final int rating;
  final String price;
  final LatLng position;
  final Map<String, bool> features;
  final String timestamp;

  Toilet({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.price,
    required this.position,
    required this.features,
    required this.timestamp,
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
}
