import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archive/core/database/database_helper.dart';
import 'package:archive/data/datasources/places_local_datasource.dart';
import 'package:archive/data/repositories/saved_repository_impl.dart';
import 'package:archive/domain/entities/saved_place.dart';
import 'package:archive/domain/entities/trip.dart';
import 'package:archive/domain/repositories/saved_repository.dart';

final _savedLocalDatasourceProvider = Provider<PlacesLocalDatasource>(
  (ref) => PlacesLocalDatasource(DatabaseHelper.instance),
);

final savedRepositoryProvider = Provider<SavedRepository>((ref) {
  return SavedRepositoryImpl(ref.watch(_savedLocalDatasourceProvider));
});

final savedPlacesProvider = FutureProvider<List<SavedPlace>>((ref) async {
  final repo = ref.watch(savedRepositoryProvider);
  return repo.getSavedPlaces();
});

final tripsProvider = FutureProvider<List<Trip>>((ref) async {
  final repo = ref.watch(savedRepositoryProvider);
  return repo.getTrips();
});

final isPlaceSavedProvider =
    FutureProvider.family<bool, String>((ref, placeId) async {
  final repo = ref.watch(savedRepositoryProvider);
  return repo.isPlaceSaved(placeId);
});
