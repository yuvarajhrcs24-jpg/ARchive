class AppConstants {
  AppConstants._();

  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const String googlePlacesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY';

  static const double nearbyRadiusMeters = 5000;
  static const String defaultLanguage = 'en';

  static const String placesBaseUrl =
      'https://maps.googleapis.com/maps/api/place';

  static const int httpTimeoutSeconds = 30;
  static const int maxCacheAgeDays = 7;

  static const List<Map<String, dynamic>> samplePlaces = [
    {
      'id': 'sample_1',
      'name': 'Mysore Palace',
      'description':
          'Mysore Palace is a historical palace and a royal residence. It is one of the most famous tourist attractions in India and the most visited monument after the Taj Mahal.',
      'shortDescription': 'Iconic royal palace, a UNESCO heritage landmark.',
      'imageUrls': <String>[],
      'lat': 12.3052,
      'lng': 76.6552,
      'categoryId': 'historical',
      'rating': 4.7,
      'openingHours': '10:00 AM - 5:30 PM',
      'audioUrl': '',
      'distanceMeters': 1200.0,
      'isOffline': false,
    },
    {
      'id': 'sample_2',
      'name': 'Brindavan Gardens',
      'description':
          'Brindavan Gardens is a garden located at the Krishnarajasagara dam built by the Mysore Kingdom. Famous for its terraced gardens and musical fountain.',
      'shortDescription': 'Beautiful terraced gardens with musical fountains.',
      'imageUrls': <String>[],
      'lat': 12.4244,
      'lng': 76.5727,
      'categoryId': 'nature',
      'rating': 4.4,
      'openingHours': '6:00 AM - 8:00 PM',
      'audioUrl': '',
      'distanceMeters': 18000.0,
      'isOffline': false,
    },
    {
      'id': 'sample_3',
      'name': 'Chamundi Hills',
      'description':
          'Chamundi Hills is a hill located to the southeast of the city of Mysore. The hill is named after the goddess Chamundeshwari, the presiding deity of Mysore. At the top stands the Chamundeshwari Temple.',
      'shortDescription': 'Sacred hills with ancient Chamundeshwari temple.',
      'imageUrls': <String>[],
      'lat': 12.2725,
      'lng': 76.6702,
      'categoryId': 'temples',
      'rating': 4.6,
      'openingHours': '7:30 AM - 2:00 PM, 3:30 PM - 6:00 PM',
      'audioUrl': '',
      'distanceMeters': 3500.0,
      'isOffline': false,
    },
    {
      'id': 'sample_4',
      'name': 'Dasaprakash Restaurant',
      'description':
          'Dasaprakash is a famous vegetarian restaurant in Mysore known for its authentic South Indian cuisine. It has been serving traditional food since 1956.',
      'shortDescription': 'Famous vegetarian restaurant since 1956.',
      'imageUrls': <String>[],
      'lat': 12.2958,
      'lng': 76.6394,
      'categoryId': 'food',
      'rating': 4.3,
      'openingHours': '7:00 AM - 10:30 PM',
      'audioUrl': '',
      'distanceMeters': 800.0,
      'isOffline': false,
    },
  ];

  static const List<Map<String, dynamic>> sampleCategories = [
    {'id': 'historical', 'name': 'Historical', 'iconName': 'museum', 'color': 'amber'},
    {'id': 'nature', 'name': 'Nature', 'iconName': 'park', 'color': 'green'},
    {'id': 'temples', 'name': 'Temples', 'iconName': 'temple_hindu', 'color': 'deepOrange'},
    {'id': 'food', 'name': 'Food', 'iconName': 'restaurant', 'color': 'red'},
    {'id': 'shopping', 'name': 'Shopping', 'iconName': 'shopping_bag', 'color': 'purple'},
    {'id': 'adventure', 'name': 'Adventure', 'iconName': 'hiking', 'color': 'teal'},
  ];
}
