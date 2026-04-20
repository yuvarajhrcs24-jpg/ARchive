import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../models/place.dart';
import '../models/trip.dart';
import '../models/user_preferences.dart';

class OfflineService extends ChangeNotifier {
  final Logger _logger = Logger();
  
  late Box<Place> _placesBox;
  late Box<Trip> _tripsBox;
  late Box<UserPreferences> _preferencesBox;
  late Box<dynamic> _settingsBox;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(PlaceAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(TripAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(UserPreferencesAdapter());
      }

      // Open boxes
      _placesBox = await Hive.openBox<Place>('places');
      _tripsBox = await Hive.openBox<Trip>('trips');
      _preferencesBox = await Hive.openBox<UserPreferences>('user_preferences');
      _settingsBox = await Hive.openBox('settings');

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _logger.e('Error initializing OfflineService: $e');
      rethrow;
    }
  }

  // Places operations
  Future<void> savePlace(Place place) async {
    try {
      await _placesBox.put(place.id, place);
      notifyListeners();
    } catch (e) {
      _logger.e('Error saving place: $e');
    }
  }

  Future<void> savePlaces(List<Place> places) async {
    try {
      final Map<String, Place> placeMap = {
        for (var place in places) place.id: place
      };
      await _placesBox.putAll(placeMap);
      notifyListeners();
    } catch (e) {
      _logger.e('Error saving places: $e');
    }
  }

  Place? getPlace(String placeId) {
    try {
      return _placesBox.get(placeId);
    } catch (e) {
      _logger.e('Error getting place: $e');
      return null;
    }
  }

  List<Place> getAllPlaces() {
    try {
      return _placesBox.values.toList();
    } catch (e) {
      _logger.e('Error getting all places: $e');
      return [];
    }
  }

  List<Place> getSavedPlaces() {
    try {
      return _placesBox.values
          .where((place) => place.isSaved)
          .toList();
    } catch (e) {
      _logger.e('Error getting saved places: $e');
      return [];
    }
  }

  Future<void> deletePlace(String placeId) async {
    try {
      await _placesBox.delete(placeId);
      notifyListeners();
    } catch (e) {
      _logger.e('Error deleting place: $e');
    }
  }

  // Trips operations
  Future<void> saveTrip(Trip trip) async {
    try {
      await _tripsBox.put(trip.id, trip);
      notifyListeners();
    } catch (e) {
      _logger.e('Error saving trip: $e');
    }
  }

  Trip? getTrip(String tripId) {
    try {
      return _tripsBox.get(tripId);
    } catch (e) {
      _logger.e('Error getting trip: $e');
      return null;
    }
  }

  List<Trip> getAllTrips() {
    try {
      return _tripsBox.values.toList();
    } catch (e) {
      _logger.e('Error getting all trips: $e');
      return [];
    }
  }

  Future<void> updateTrip(Trip trip) async {
    try {
      await _tripsBox.put(trip.id, trip);
      notifyListeners();
    } catch (e) {
      _logger.e('Error updating trip: $e');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _tripsBox.delete(tripId);
      notifyListeners();
    } catch (e) {
      _logger.e('Error deleting trip: $e');
    }
  }

  // User preferences operations
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    try {
      await _preferencesBox.put(preferences.userId, preferences);
      notifyListeners();
    } catch (e) {
      _logger.e('Error saving preferences: $e');
    }
  }

  UserPreferences? getUserPreferences(String userId) {
    try {
      return _preferencesBox.get(userId);
    } catch (e) {
      _logger.e('Error getting preferences: $e');
      return null;
    }
  }

  Future<void> updateUserPreferences(UserPreferences preferences) async {
    try {
      await _preferencesBox.put(preferences.userId, preferences);
      notifyListeners();
    } catch (e) {
      _logger.e('Error updating preferences: $e');
    }
  }

  // Settings operations
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      await _settingsBox.put(key, value);
      notifyListeners();
    } catch (e) {
      _logger.e('Error saving setting: $e');
    }
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    try {
      return _settingsBox.get(key, defaultValue: defaultValue);
    } catch (e) {
      _logger.e('Error getting setting: $e');
      return defaultValue;
    }
  }

  // Sync operations
  Future<void> syncWithFirebase() async {
    try {
      // In a real app, this would sync with Firebase
      _logger.i('Syncing with Firebase...');
      notifyListeners();
    } catch (e) {
      _logger.e('Error syncing with Firebase: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      await _placesBox.clear();
      await _tripsBox.clear();
      await _preferencesBox.clear();
      await _settingsBox.clear();
      notifyListeners();
    } catch (e) {
      _logger.e('Error clearing data: $e');
    }
  }

  @override
  void dispose() {
    // Don't close boxes as they may be needed elsewhere
    super.dispose();
  }
}

// Adapter stubs - these would be generated by build_runner
class PlaceAdapter {
  int get typeId => 0;
}

class TripAdapter {
  int get typeId => 1;
}

class UserPreferencesAdapter {
  int get typeId => 2;
}
