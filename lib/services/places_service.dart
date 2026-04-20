import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/place.dart';

class PlacesService extends ChangeNotifier {
  final Logger _logger = Logger();
  final String _googleMapsApiKey = 'YOUR_GOOGLE_PLACES_API_KEY'; // Set this from Firebase config
  
  List<Place> _allPlaces = [];
  List<Place> _filteredPlaces = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';

  List<Place> get allPlaces => _allPlaces;
  List<Place> get filteredPlaces => _filteredPlaces;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  final List<String> categories = ['All', 'Historical', 'Food', 'Nature', 'Temples'];

  Future<List<Place>> searchNearbyPlaces(
    double latitude,
    double longitude, {
    double radiusInMeters = 5000,
    String? category,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Query Google Places API
      final String types = _getCategoryTypes(category);
      final String url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
          '?location=$latitude,$longitude'
          '&radius=$radiusInMeters'
          '&type=$types'
          '&key=$_googleMapsApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> results = json['results'] ?? [];

        _allPlaces = await Future.wait(
          results.map((result) => _placeFromGooglePlace(result)),
        );

        _filteredPlaces = _allPlaces;
        _isLoading = false;
        notifyListeners();
        return _allPlaces;
      } else {
        throw Exception('Failed to load places');
      }
    } catch (e) {
      _error = 'Error searching places: $e';
      _logger.e('PlacesService error: $e');
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<Place> getPlaceDetails(String placeId) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=formatted_address,opening_hours,rating,reviews,url,website,international_phone_number,photos'
          '&key=$_googleMapsApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final details = json['result'] ?? {};

        // Find the place in our list and update it
        final index = _allPlaces.indexWhere((p) => p.id == placeId);
        if (index != -1) {
          _allPlaces[index] = _allPlaces[index].copyWith(
            openingHours: _formatOpeningHours(details['opening_hours']),
            rating: (details['rating'] ?? 0.0).toDouble(),
            reviewCount: details['reviews']?.length ?? 0,
          );
          notifyListeners();
        }

        return _allPlaces[index];
      }

      throw Exception('Failed to load place details');
    } catch (e) {
      _logger.e('Error getting place details: $e');
      rethrow;
    }
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    if (category == 'All') {
      _filteredPlaces = _allPlaces;
    } else {
      _filteredPlaces = _allPlaces
          .where((place) => place.category == category)
          .toList();
    }
    notifyListeners();
  }

  void searchByName(String query) {
    if (query.isEmpty) {
      _filteredPlaces = _allPlaces;
    } else {
      _filteredPlaces = _allPlaces
          .where((place) => place.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  String _getCategoryTypes(String? category) {
    switch (category) {
      case 'Historical':
        return 'museum|historical_landmark|ancient_place';
      case 'Food':
        return 'restaurant|cafe|bakery';
      case 'Nature':
        return 'park|natural_feature|garden';
      case 'Temples':
        return 'place_of_worship|temple|church|mosque';
      default:
        return 'tourist_attraction|museum|park|restaurant';
    }
  }

  Future<Place> _placeFromGooglePlace(Map<String, dynamic> json) async {
    try {
      final String placeId = json['place_id'] ?? 'unknown';
      final String name = json['name'] ?? 'Unknown';
      final double lat = (json['geometry']['location']['lat'] ?? 0.0).toDouble();
      final double lng = (json['geometry']['location']['lng'] ?? 0.0).toDouble();
      final String type = json['types']?[0] ?? 'tourist_attraction';

      return Place(
        id: placeId,
        name: name,
        category: _categorizePlace(type),
        latitude: lat,
        longitude: lng,
        description: json['vicinity'] ?? '',
        detailedDescription: 'Tap to see more details',
        imageUrls: _getPhotoUrls(json['photos']),
        rating: (json['rating'] ?? 0.0).toDouble(),
        reviewCount: json['user_ratings_total'] ?? 0,
        openingHours: json['opening_hours']?['open_now'] == true ? 'Open' : 'Check Hours',
        audioGuideUrl: '', // Will be populated from Firebase
        audioGuideKannada: '',
        audioGuideHindi: '',
      );
    } catch (e) {
      _logger.e('Error parsing place: $e');
      rethrow;
    }
  }

  String _categorizePlace(String type) {
    if (type.contains('museum') || type.contains('historical') || type.contains('monument')) {
      return 'Historical';
    } else if (type.contains('restaurant') || type.contains('cafe') || type.contains('bakery')) {
      return 'Food';
    } else if (type.contains('park') || type.contains('garden') || type.contains('natural')) {
      return 'Nature';
    } else if (type.contains('temple') || type.contains('church') || type.contains('mosque')) {
      return 'Temples';
    }
    return 'Other';
  }

  List<String> _getPhotoUrls(List<dynamic>? photos) {
    if (photos == null || photos.isEmpty) return [];
    return photos
        .map((photo) =>
            'https://maps.googleapis.com/maps/api/place/photo'
            '?maxwidth=400'
            '&photo_reference=${photo['photo_reference']}'
            '&key=$_googleMapsApiKey')
        .toList();
  }

  String _formatOpeningHours(dynamic openingHours) {
    if (openingHours == null) return 'Hours not available';
    try {
      final weekdayText = openingHours['weekday_text'] as List?;
      if (weekdayText != null && weekdayText.isNotEmpty) {
        return weekdayText.join('\n');
      }
    } catch (e) {
      _logger.e('Error formatting opening hours: $e');
    }
    return 'Check Google Maps for hours';
  }
}
