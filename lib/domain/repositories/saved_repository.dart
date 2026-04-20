import 'package:archive/domain/entities/saved_place.dart';
import 'package:archive/domain/entities/trip.dart';

abstract class SavedRepository {
  Future<List<SavedPlace>> getSavedPlaces();

  Future<void> savePlace(String placeId);

  Future<void> removePlace(String placeId);

  Future<bool> isPlaceSaved(String placeId);

  Future<List<Trip>> getTrips();

  Future<Trip> createTrip(String name);

  Future<Trip> addStopToTrip(String tripId, String placeId, {String notes});

  Future<Trip> removeStopFromTrip(String tripId, String placeId);

  Future<void> deleteTrip(String tripId);

  Future<Trip> reorderTripStops(String tripId, List<TripStop> stops);
}
