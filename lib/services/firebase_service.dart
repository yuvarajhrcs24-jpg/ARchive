import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_firestore/firebase_firestore.dart';
import 'package:logger/logger.dart';
import '../models/place.dart';
import '../models/trip.dart';

class FirebaseService {
  final Logger _logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Authentication methods
  Future<User?> signInWithGoogle() async {
    try {
      // Implementation would depend on google_sign_in package
      _logger.i('Signing in with Google...');
      return _auth.currentUser;
    } catch (e) {
      _logger.e('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _logger.i('User signed out');
    } catch (e) {
      _logger.e('Error signing out: $e');
      rethrow;
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Places operations
  Future<void> uploadPlace(Place place) async {
    try {
      await _firestore
          .collection('places')
          .doc(place.id)
          .set(place.toMap());
      _logger.i('Place uploaded: ${place.id}');
    } catch (e) {
      _logger.e('Error uploading place: $e');
      rethrow;
    }
  }

  Future<List<Place>> getPlacesForCity(String cityName) async {
    try {
      final snapshot = await _firestore
          .collection('places')
          .where('city', isEqualTo: cityName)
          .get();

      return snapshot.docs
          .map((doc) => Place.fromMap(doc.data()))
          .toList();
    } catch (e) {
      _logger.e('Error fetching places: $e');
      return [];
    }
  }

  Future<Place?> getPlaceDetails(String placeId) async {
    try {
      final doc = await _firestore
          .collection('places')
          .doc(placeId)
          .get();

      if (doc.exists) {
        return Place.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      _logger.e('Error fetching place details: $e');
      return null;
    }
  }

  Stream<List<Place>> watchPlaces(String cityName) {
    return _firestore
        .collection('places')
        .where('city', isEqualTo: cityName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Place.fromMap(doc.data()))
            .toList());
  }

  // User bookmarks/saved places
  Future<void> saveBookmark(String userId, String placeId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(placeId)
          .set({
        'placeId': placeId,
        'savedAt': DateTime.now().toIso8601String(),
      });
      _logger.i('Bookmark saved: $placeId');
    } catch (e) {
      _logger.e('Error saving bookmark: $e');
      rethrow;
    }
  }

  Future<void> removeBookmark(String userId, String placeId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(placeId)
          .delete();
      _logger.i('Bookmark removed: $placeId');
    } catch (e) {
      _logger.e('Error removing bookmark: $e');
      rethrow;
    }
  }

  Stream<List<String>> watchBookmarks(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc['placeId'] as String)
            .toList());
  }

  // Trips operations
  Future<void> uploadTrip(Trip trip) async {
    try {
      await _firestore
          .collection('users')
          .doc(trip.userId)
          .collection('trips')
          .doc(trip.id)
          .set(trip.toMap());
      _logger.i('Trip uploaded: ${trip.id}');
    } catch (e) {
      _logger.e('Error uploading trip: $e');
      rethrow;
    }
  }

  Future<List<Trip>> getUserTrips(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .get();

      return snapshot.docs
          .map((doc) => Trip.fromMap(doc.data()))
          .toList();
    } catch (e) {
      _logger.e('Error fetching trips: $e');
      return [];
    }
  }

  Future<void> deleteTrip(String userId, String tripId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(tripId)
          .delete();
      _logger.i('Trip deleted: $tripId');
    } catch (e) {
      _logger.e('Error deleting trip: $e');
      rethrow;
    }
  }

  // Audio guides
  Future<String?> getAudioGuideUrl(
    String placeId,
    String language,
  ) async {
    try {
      final doc = await _firestore
          .collection('places')
          .doc(placeId)
          .collection('audioGuides')
          .doc(language)
          .get();

      if (doc.exists) {
        return doc['url'] as String?;
      }
      return null;
    } catch (e) {
      _logger.e('Error fetching audio guide: $e');
      return null;
    }
  }

  // Offline download management
  Future<void> markForOfflineDownload(
    String userId,
    String placeId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('offlineDownloads')
          .doc(placeId)
          .set({
        'placeId': placeId,
        'downloadedAt': DateTime.now().toIso8601String(),
        'languages': ['English', 'Kannada', 'Hindi'],
      });
      _logger.i('Marked for offline: $placeId');
    } catch (e) {
      _logger.e('Error marking for offline: $e');
      rethrow;
    }
  }

  Future<List<String>> getOfflineDownloads(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('offlineDownloads')
          .get();

      return snapshot.docs.map((doc) => doc['placeId'] as String).toList();
    } catch (e) {
      _logger.e('Error fetching offline downloads: $e');
      return [];
    }
  }
}
