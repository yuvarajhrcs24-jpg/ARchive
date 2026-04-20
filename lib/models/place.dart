import 'package:hive/hive.dart';

part 'place.g.dart';

@HiveType(typeId: 0)
class Place {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String category; // Historical, Food, Nature, Temples
  
  @HiveField(3)
  final double latitude;
  
  @HiveField(4)
  final double longitude;
  
  @HiveField(5)
  final String description;
  
  @HiveField(6)
  final String detailedDescription;
  
  @HiveField(7)
  final List<String> imageUrls;
  
  @HiveField(8)
  final double rating;
  
  @HiveField(9)
  final int reviewCount;
  
  @HiveField(10)
  final String openingHours;
  
  @HiveField(11)
  final String audioGuideUrl;
  
  @HiveField(12)
  final String audioGuideKannada;
  
  @HiveField(13)
  final String audioGuideHindi;
  
  @HiveField(14)
  final double distance; // in km, calculated runtime
  
  @HiveField(15)
  final bool isSaved;
  
  @HiveField(16)
  final String placeType; // google_maps, manual, etc.

  Place({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.detailedDescription,
    required this.imageUrls,
    required this.rating,
    required this.reviewCount,
    required this.openingHours,
    required this.audioGuideUrl,
    required this.audioGuideKannada,
    required this.audioGuideHindi,
    this.distance = 0.0,
    this.isSaved = false,
    this.placeType = 'google_maps',
  });

  Place copyWith({
    String? id,
    String? name,
    String? category,
    double? latitude,
    double? longitude,
    String? description,
    String? detailedDescription,
    List<String>? imageUrls,
    double? rating,
    int? reviewCount,
    String? openingHours,
    String? audioGuideUrl,
    String? audioGuideKannada,
    String? audioGuideHindi,
    double? distance,
    bool? isSaved,
    String? placeType,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      openingHours: openingHours ?? this.openingHours,
      audioGuideUrl: audioGuideUrl ?? this.audioGuideUrl,
      audioGuideKannada: audioGuideKannada ?? this.audioGuideKannada,
      audioGuideHindi: audioGuideHindi ?? this.audioGuideHindi,
      distance: distance ?? this.distance,
      isSaved: isSaved ?? this.isSaved,
      placeType: placeType ?? this.placeType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'detailedDescription': detailedDescription,
      'imageUrls': imageUrls,
      'rating': rating,
      'reviewCount': reviewCount,
      'openingHours': openingHours,
      'audioGuideUrl': audioGuideUrl,
      'audioGuideKannada': audioGuideKannada,
      'audioGuideHindi': audioGuideHindi,
      'placeType': placeType,
    };
  }

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      detailedDescription: map['detailedDescription'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      openingHours: map['openingHours'] ?? '',
      audioGuideUrl: map['audioGuideUrl'] ?? '',
      audioGuideKannada: map['audioGuideKannada'] ?? '',
      audioGuideHindi: map['audioGuideHindi'] ?? '',
      placeType: map['placeType'] ?? 'google_maps',
    );
  }
}
