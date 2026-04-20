import 'package:archive/domain/entities/place.dart';
import 'package:archive/domain/repositories/place_repository.dart';

class SearchPlaces {
  final PlaceRepository repository;

  const SearchPlaces(this.repository);

  Future<List<Place>> call({
    required String query,
    double? lat,
    double? lng,
    String language = 'en',
  }) {
    return repository.searchPlaces(
      query: query,
      lat: lat,
      lng: lng,
      language: language,
    );
  }
}
