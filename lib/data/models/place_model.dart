import 'dart:convert';

class PlaceModel {
  final String id;
  final String name;
  final String description;
  final String shortDescription;
  final List<String> imageUrls;
  final double lat;
  final double lng;
  final String categoryId;
  final double rating;
  final String openingHours;
  final String audioUrl;
  final double distanceMeters;
  final bool isOffline;
  final String? offlineImagePath;
  final String? offlineAudioPath;

  const PlaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.shortDescription,
    required this.imageUrls,
    required this.lat,
    required this.lng,
    required this.categoryId,
    required this.rating,
    required this.openingHours,
    required this.audioUrl,
    required this.distanceMeters,
    required this.isOffline,
    this.offlineImagePath,
    this.offlineAudioPath,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'] as String? ?? json['place_id'] as String? ?? '',
      name: _extractName(json),
      description: _extractDescription(json),
      shortDescription: json['shortDescription'] as String? ??
          json['editorial_summary']?['overview'] as String? ?? '',
      imageUrls: _extractImageUrls(json),
      lat: (json['lat'] as num?)?.toDouble() ??
          (json['geometry']?['location']?['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ??
          (json['geometry']?['location']?['lng'] as num?)?.toDouble() ?? 0,
      categoryId: json['categoryId'] as String? ?? _extractCategoryId(json),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      openingHours: _extractOpeningHours(json),
      audioUrl: json['audioUrl'] as String? ?? '',
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
      isOffline: (json['isOffline'] as int? ?? 0) == 1,
      offlineImagePath: json['offlineImagePath'] as String?,
      offlineAudioPath: json['offlineAudioPath'] as String?,
    );
  }

  static String _extractName(Map<String, dynamic> json) {
    return json['name'] as String? ?? json['displayName']?['text'] as String? ?? '';
  }

  static String _extractDescription(Map<String, dynamic> json) {
    return json['description'] as String? ??
        json['editorial_summary']?['overview'] as String? ?? '';
  }

  static List<String> _extractImageUrls(Map<String, dynamic> json) {
    if (json['imageUrls'] != null) {
      if (json['imageUrls'] is String) {
        try {
          final decoded = jsonDecode(json['imageUrls'] as String);
          if (decoded is List) return List<String>.from(decoded);
        } catch (_) {}
        return [];
      }
      if (json['imageUrls'] is List) {
        return List<String>.from(json['imageUrls'] as List);
      }
    }
    final photos = json['photos'] as List?;
    if (photos != null && photos.isNotEmpty) {
      return photos
          .take(5)
          .map((p) => p['photo_reference'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  static String _extractOpeningHours(Map<String, dynamic> json) {
    if (json['openingHours'] != null) return json['openingHours'] as String;
    final hours = json['opening_hours'];
    if (hours == null) return '';
    final weekday = hours['weekday_text'] as List?;
    if (weekday != null && weekday.isNotEmpty) return weekday.join('\n');
    return (hours['open_now'] == true) ? 'Open now' : 'Closed';
  }

  static String _extractCategoryId(Map<String, dynamic> json) {
    final types = json['types'] as List?;
    if (types == null || types.isEmpty) return '';
    if (types.contains('museum') || types.contains('historical')) return 'historical';
    if (types.contains('park') || types.contains('natural_feature')) return 'nature';
    if (types.contains('place_of_worship') || types.contains('church')) return 'temples';
    if (types.contains('restaurant') || types.contains('food')) return 'food';
    if (types.contains('shopping_mall') || types.contains('store')) return 'shopping';
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'shortDescription': shortDescription,
      'imageUrls': imageUrls,
      'lat': lat,
      'lng': lng,
      'categoryId': categoryId,
      'rating': rating,
      'openingHours': openingHours,
      'audioUrl': audioUrl,
      'distanceMeters': distanceMeters,
      'isOffline': isOffline,
      'offlineImagePath': offlineImagePath,
      'offlineAudioPath': offlineAudioPath,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'shortDescription': shortDescription,
      'imageUrls': jsonEncode(imageUrls),
      'lat': lat,
      'lng': lng,
      'categoryId': categoryId,
      'rating': rating,
      'openingHours': openingHours,
      'audioUrl': audioUrl,
      'distanceMeters': distanceMeters,
      'isOffline': isOffline ? 1 : 0,
      'offlineImagePath': offlineImagePath,
      'offlineAudioPath': offlineAudioPath,
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory PlaceModel.fromMap(Map<String, dynamic> map) => PlaceModel.fromJson(map);

  PlaceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? shortDescription,
    List<String>? imageUrls,
    double? lat,
    double? lng,
    String? categoryId,
    double? rating,
    String? openingHours,
    String? audioUrl,
    double? distanceMeters,
    bool? isOffline,
    String? offlineImagePath,
    String? offlineAudioPath,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      imageUrls: imageUrls ?? this.imageUrls,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      categoryId: categoryId ?? this.categoryId,
      rating: rating ?? this.rating,
      openingHours: openingHours ?? this.openingHours,
      audioUrl: audioUrl ?? this.audioUrl,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isOffline: isOffline ?? this.isOffline,
      offlineImagePath: offlineImagePath ?? this.offlineImagePath,
      offlineAudioPath: offlineAudioPath ?? this.offlineAudioPath,
    );
  }
}
