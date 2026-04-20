import 'package:archive/domain/entities/place.dart';
import 'package:archive/domain/entities/category.dart';

abstract class PlaceRepository {
  Future<List<Place>> getNearbyPlaces({
    required double lat,
    required double lng,
    double radiusMeters,
    String? categoryId,
    String language,
  });

  Future<Place> getPlaceDetails(String placeId, {String language});

  Future<List<Place>> searchPlaces({
    required String query,
    double? lat,
    double? lng,
    String language,
  });

  Future<List<Category>> getCategories();

  Future<List<Place>> getPlacesByCategory(
    String categoryId, {
    double? lat,
    double? lng,
    String language,
  });
}
