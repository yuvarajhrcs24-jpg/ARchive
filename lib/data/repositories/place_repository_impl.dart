import 'package:archive/core/errors/failures.dart';
import 'package:archive/core/network/network_info.dart';
import 'package:archive/core/utils/distance_utils.dart';
import 'package:archive/data/datasources/places_local_datasource.dart';
import 'package:archive/data/datasources/places_remote_datasource.dart';
import 'package:archive/data/models/category_model.dart';
import 'package:archive/data/models/place_model.dart';
import 'package:archive/domain/entities/category.dart';
import 'package:archive/domain/entities/place.dart';
import 'package:archive/domain/repositories/place_repository.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  final PlacesRemoteDatasource remote;
  final PlacesLocalDatasource local;
  final NetworkInfo networkInfo;

  const PlaceRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  @override
  Future<List<Place>> getNearbyPlaces({
    required double lat,
    required double lng,
    double radiusMeters = 5000,
    String? categoryId,
    String language = 'en',
  }) async {
    final connected = await networkInfo.isConnected;
    if (connected) {
      try {
        final models = await remote.getNearbyPlaces(
          lat: lat,
          lng: lng,
          radiusMeters: radiusMeters,
          categoryId: categoryId,
          language: language,
        );
        final withDistance = models
            .map((m) => m.copyWith(
                  distanceMeters: DistanceUtils.haversine(lat, lng, m.lat, m.lng),
                ))
            .toList()
          ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
        await local.insertPlaces(withDistance);
        return withDistance.map(_toEntity).toList();
      } catch (_) {
        return _getCachedPlaces(lat, lng, categoryId);
      }
    } else {
      return _getCachedPlaces(lat, lng, categoryId);
    }
  }

  Future<List<Place>> _getCachedPlaces(
    double lat,
    double lng,
    String? categoryId,
  ) async {
    final models = await local.getNearbyPlaces(
      lat: lat,
      lng: lng,
      categoryId: categoryId,
    );
    return models
        .map((m) => _toEntity(m.copyWith(
              distanceMeters: DistanceUtils.haversine(lat, lng, m.lat, m.lng),
            )))
        .toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  }

  @override
  Future<Place> getPlaceDetails(String placeId, {String language = 'en'}) async {
    final connected = await networkInfo.isConnected;
    if (connected) {
      try {
        final model = await remote.getPlaceDetails(placeId, language: language);
        await local.insertPlace(model);
        return _toEntity(model);
      } catch (_) {
        final cached = await local.getPlaceById(placeId);
        if (cached != null) return _toEntity(cached);
        throw const NotFoundFailure();
      }
    } else {
      final cached = await local.getPlaceById(placeId);
      if (cached != null) return _toEntity(cached);
      throw const NetworkFailure();
    }
  }

  @override
  Future<List<Place>> searchPlaces({
    required String query,
    double? lat,
    double? lng,
    String language = 'en',
  }) async {
    final connected = await networkInfo.isConnected;
    if (connected) {
      try {
        final models = await remote.searchPlaces(
          query: query,
          lat: lat,
          lng: lng,
          language: language,
        );
        if (lat != null && lng != null) {
          final withDist = models
              .map((m) => m.copyWith(
                    distanceMeters: DistanceUtils.haversine(lat, lng, m.lat, m.lng),
                  ))
              .toList();
          await local.insertPlaces(withDist);
          return withDist.map(_toEntity).toList();
        }
        return models.map(_toEntity).toList();
      } catch (_) {
        final cached = await local.searchPlaces(query);
        return cached.map(_toEntity).toList();
      }
    } else {
      final cached = await local.searchPlaces(query);
      return cached.map(_toEntity).toList();
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    final connected = await networkInfo.isConnected;
    if (connected) {
      final models = await remote.getCategories();
      await local.insertCategories(models);
      return models.map(_toCategoryEntity).toList();
    }
    final cached = await local.getCategories();
    if (cached.isNotEmpty) return cached.map(_toCategoryEntity).toList();
    final remoteModels = await remote.getCategories();
    return remoteModels.map(_toCategoryEntity).toList();
  }

  @override
  Future<List<Place>> getPlacesByCategory(
    String categoryId, {
    double? lat,
    double? lng,
    String language = 'en',
  }) async {
    return getNearbyPlaces(
      lat: lat ?? 0,
      lng: lng ?? 0,
      categoryId: categoryId,
      language: language,
    );
  }

  Place _toEntity(PlaceModel m) {
    return Place(
      id: m.id,
      name: m.name,
      description: m.description,
      shortDescription: m.shortDescription,
      imageUrls: m.imageUrls,
      lat: m.lat,
      lng: m.lng,
      categoryId: m.categoryId,
      rating: m.rating,
      openingHours: m.openingHours,
      audioUrl: m.audioUrl,
      distanceMeters: m.distanceMeters,
      isOffline: m.isOffline,
      offlineImagePath: m.offlineImagePath,
      offlineAudioPath: m.offlineAudioPath,
    );
  }

  Category _toCategoryEntity(CategoryModel m) {
    return Category(
      id: m.id,
      name: m.name,
      iconName: m.iconName,
      color: m.color,
    );
  }
}
