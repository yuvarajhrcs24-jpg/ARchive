import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class LocationService extends ChangeNotifier {
  final Logger _logger = Logger();
  
  Position? _currentPosition;
  bool _isListening = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  bool get isListening => _isListening;
  String? get error => _error;

  Future<void> initialize() async {
    try {
      // Request permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied) {
          _error = 'Location permission denied';
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'Location permission permanently denied';
        Geolocator.openLocationSettings();
        notifyListeners();
        return;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error getting location: $e';
      _logger.e('LocationService error: $e');
      notifyListeners();
    }
  }

  Future<void> startLocationUpdates() async {
    try {
      _isListening = true;
      notifyListeners();

      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((Position position) {
        _currentPosition = position;
        _error = null;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Error starting location updates: $e';
      _logger.e('LocationService error: $e');
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> stopLocationUpdates() async {
    _isListening = false;
    notifyListeners();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula to calculate distance between two coordinates
    const int earthRadiusKm = 6371;
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  @override
  void dispose() {
    stopLocationUpdates();
    super.dispose();
  }
}
