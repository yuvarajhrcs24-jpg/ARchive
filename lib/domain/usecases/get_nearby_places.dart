import 'package:archive/domain/entities/place.dart';
import 'package:archive/domain/repositories/place_repository.dart';

class GetNearbyPlaces {
  final PlaceRepository repository;

  const GetNearbyPlaces(this.repository);

  Future<List<Place>> call({
    required double lat,
    required double lng,
    double radiusMeters = 5000,
    String? categoryId,
    String language = 'en',
  }) {
    return repository.getNearbyPlaces(
      lat: lat,
      lng: lng,
      radiusMeters: radiusMeters,
      categoryId: categoryId,
      language: language,
    );
  }
}
