import 'package:uuid/uuid.dart';
import 'package:archive/data/datasources/places_local_datasource.dart';
import 'package:archive/data/models/trip_model.dart';
import 'package:archive/data/models/trip_stop_model.dart';
import 'package:archive/domain/entities/saved_place.dart';
import 'package:archive/domain/entities/trip.dart';
import 'package:archive/domain/repositories/saved_repository.dart';

class SavedRepositoryImpl implements SavedRepository {
  final PlacesLocalDatasource local;
  final Uuid _uuid = const Uuid();

  SavedRepositoryImpl(this.local);

  @override
  Future<List<SavedPlace>> getSavedPlaces() async {
    final models = await local.getSavedPlaces();
    return models
        .map((m) => SavedPlace(placeId: m.placeId, savedAt: m.savedAt))
        .toList();
  }

  @override
  Future<void> savePlace(String placeId) => local.savePlace(placeId);

  @override
  Future<void> removePlace(String placeId) => local.removePlace(placeId);

  @override
  Future<bool> isPlaceSaved(String placeId) => local.isPlaceSaved(placeId);

  @override
  Future<List<Trip>> getTrips() async {
    final models = await local.getTrips();
    return models.map(_toTripEntity).toList();
  }

  @override
  Future<Trip> createTrip(String name) async {
    final model = TripModel(
      id: _uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
    );
    await local.insertTrip(model);
    return _toTripEntity(model);
  }

  @override
  Future<Trip> addStopToTrip(
    String tripId,
    String placeId, {
    String notes = '',
  }) async {
    final trips = await local.getTrips();
    final trip = trips.firstWhere((t) => t.id == tripId);
    final order = trip.stops.length;
    final stop = TripStopModel(placeId: placeId, order: order, notes: notes);
    await local.insertTripStop(tripId, stop);
    final updated = await local.getTrips();
    return _toTripEntity(updated.firstWhere((t) => t.id == tripId));
  }

  @override
  Future<Trip> removeStopFromTrip(String tripId, String placeId) async {
    await local.deleteTripStop(tripId, placeId);
    final updated = await local.getTrips();
    return _toTripEntity(updated.firstWhere((t) => t.id == tripId));
  }

  @override
  Future<void> deleteTrip(String tripId) => local.deleteTrip(tripId);

  @override
  Future<Trip> reorderTripStops(String tripId, List<TripStop> stops) async {
    for (var i = 0; i < stops.length; i++) {
      await local.deleteTripStop(tripId, stops[i].placeId);
      await local.insertTripStop(
        tripId,
        TripStopModel(placeId: stops[i].placeId, order: i, notes: stops[i].notes),
      );
    }
    final updated = await local.getTrips();
    return _toTripEntity(updated.firstWhere((t) => t.id == tripId));
  }

  Trip _toTripEntity(TripModel m) {
    return Trip(
      id: m.id,
      name: m.name,
      createdAt: m.createdAt,
      stops: m.stops
          .map((s) => TripStop(placeId: s.placeId, order: s.order, notes: s.notes))
          .toList(),
    );
  }
}
