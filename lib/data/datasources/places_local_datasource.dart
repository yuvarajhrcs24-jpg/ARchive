import 'package:sqflite/sqflite.dart';
import 'package:archive/core/database/database_helper.dart';
import 'package:archive/data/models/place_model.dart';
import 'package:archive/data/models/category_model.dart';
import 'package:archive/data/models/saved_place_model.dart';
import 'package:archive/data/models/trip_model.dart';
import 'package:archive/data/models/trip_stop_model.dart';

class PlacesLocalDatasource {
  final DatabaseHelper dbHelper;

  PlacesLocalDatasource(this.dbHelper);

  Future<List<PlaceModel>> getNearbyPlaces({
    required double lat,
    required double lng,
    double radiusMeters = 5000,
    String? categoryId,
  }) async {
    final db = await dbHelper.database;
    final query = categoryId != null && categoryId.isNotEmpty
        ? 'SELECT * FROM places WHERE categoryId = ?'
        : 'SELECT * FROM places';
    final args = categoryId != null && categoryId.isNotEmpty
        ? [categoryId]
        : null;
    final maps = await db.rawQuery(query, args);
    return maps.map((m) => PlaceModel.fromMap(m)).toList();
  }

  Future<PlaceModel?> getPlaceById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query('places', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return PlaceModel.fromMap(maps.first);
  }

  Future<void> insertPlace(PlaceModel place) async {
    final db = await dbHelper.database;
    await db.insert(
      'places',
      place.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPlaces(List<PlaceModel> places) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (final place in places) {
      batch.insert(
        'places',
        place.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<PlaceModel>> searchPlaces(String query) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'places',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((m) => PlaceModel.fromMap(m)).toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final db = await dbHelper.database;
    final maps = await db.query('categories');
    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<void> insertCategories(List<CategoryModel> categories) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (final cat in categories) {
      batch.insert(
        'categories',
        cat.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Saved places
  Future<List<SavedPlaceModel>> getSavedPlaces() async {
    final db = await dbHelper.database;
    final maps = await db.query('saved_places', orderBy: 'savedAt DESC');
    return maps.map((m) => SavedPlaceModel.fromMap(m)).toList();
  }

  Future<void> savePlace(String placeId) async {
    final db = await dbHelper.database;
    await db.insert(
      'saved_places',
      {
        'placeId': placeId,
        'savedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removePlace(String placeId) async {
    final db = await dbHelper.database;
    await db.delete('saved_places', where: 'placeId = ?', whereArgs: [placeId]);
  }

  Future<bool> isPlaceSaved(String placeId) async {
    final db = await dbHelper.database;
    final maps =
        await db.query('saved_places', where: 'placeId = ?', whereArgs: [placeId]);
    return maps.isNotEmpty;
  }

  // Trips
  Future<List<TripModel>> getTrips() async {
    final db = await dbHelper.database;
    final tripMaps = await db.query('trips', orderBy: 'createdAt DESC');
    final trips = <TripModel>[];
    for (final tripMap in tripMaps) {
      final tripId = tripMap['id'] as String;
      final stopMaps = await db.query(
        'trip_stops',
        where: 'tripId = ?',
        whereArgs: [tripId],
        orderBy: 'stopOrder ASC',
      );
      final stops = stopMaps.map((s) => TripStopModel.fromMap(s)).toList();
      trips.add(TripModel(
        id: tripId,
        name: tripMap['name'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(tripMap['createdAt'] as int),
        stops: stops,
      ));
    }
    return trips;
  }

  Future<TripModel> insertTrip(TripModel trip) async {
    final db = await dbHelper.database;
    await db.insert(
      'trips',
      trip.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return trip;
  }

  Future<void> insertTripStop(String tripId, TripStopModel stop) async {
    final db = await dbHelper.database;
    await db.insert(
      'trip_stops',
      {...stop.toMap(), 'tripId': tripId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteTripStop(String tripId, String placeId) async {
    final db = await dbHelper.database;
    await db.delete(
      'trip_stops',
      where: 'tripId = ? AND placeId = ?',
      whereArgs: [tripId, placeId],
    );
  }

  Future<void> deleteTrip(String tripId) async {
    final db = await dbHelper.database;
    await db.delete('trips', where: 'id = ?', whereArgs: [tripId]);
    await db.delete('trip_stops', where: 'tripId = ?', whereArgs: [tripId]);
  }
}
