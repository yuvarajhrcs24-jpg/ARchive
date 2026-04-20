import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archive/core/constants/app_constants.dart';
import 'package:archive/core/database/database_helper.dart';
import 'package:archive/core/network/network_info.dart';
import 'package:archive/data/datasources/places_local_datasource.dart';
import 'package:archive/data/datasources/places_remote_datasource.dart';
import 'package:archive/data/repositories/place_repository_impl.dart';
import 'package:archive/domain/entities/category.dart';
import 'package:archive/domain/entities/place.dart';
import 'package:archive/domain/repositories/place_repository.dart';
import 'package:archive/presentation/providers/location_provider.dart';

// Infrastructure providers
final _dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: AppConstants.httpTimeoutSeconds),
    receiveTimeout: const Duration(seconds: AppConstants.httpTimeoutSeconds),
  ));
  return dio;
});

final _dbHelperProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final _networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfoImpl(Connectivity()),
);

final _remoteDatasourceProvider = Provider<PlacesRemoteDatasource>(
  (ref) => PlacesRemoteDatasource(ref.watch(_dioProvider)),
);

final _localDatasourceProvider = Provider<PlacesLocalDatasource>(
  (ref) => PlacesLocalDatasource(ref.watch(_dbHelperProvider)),
);

final placeRepositoryProvider = Provider<PlaceRepository>(
  (ref) => PlaceRepositoryImpl(
    remote: ref.watch(_remoteDatasourceProvider),
    local: ref.watch(_localDatasourceProvider),
    networkInfo: ref.watch(_networkInfoProvider),
  ),
);

// Nearby places
final nearbyPlacesProvider = FutureProvider<List<Place>>((ref) async {
  final locationState = ref.watch(locationProvider);
  final repo = ref.watch(placeRepositoryProvider);

  final position = locationState.valueOrNull;
  if (position == null) {
    return repo.getNearbyPlaces(lat: 12.2958, lng: 76.6394);
  }
  return repo.getNearbyPlaces(
    lat: position.latitude,
    lng: position.longitude,
  );
});

// Search
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Place>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final repo = ref.watch(placeRepositoryProvider);
  final locationState = ref.read(locationProvider);
  final position = locationState.valueOrNull;

  return repo.searchPlaces(
    query: query,
    lat: position?.latitude,
    lng: position?.longitude,
  );
});

// Place detail
final placeDetailProvider =
    FutureProvider.family<Place, String>((ref, id) async {
  final repo = ref.watch(placeRepositoryProvider);
  return repo.getPlaceDetails(id);
});

// Categories
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(placeRepositoryProvider);
  return repo.getCategories();
});

// Selected category filter
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Filtered nearby places
final filteredPlacesProvider = FutureProvider<List<Place>>((ref) async {
  final locationState = ref.watch(locationProvider);
  final category = ref.watch(selectedCategoryProvider);
  final repo = ref.watch(placeRepositoryProvider);

  final position = locationState.valueOrNull;
  return repo.getNearbyPlaces(
    lat: position?.latitude ?? 12.2958,
    lng: position?.longitude ?? 76.6394,
    categoryId: category,
  );
});
