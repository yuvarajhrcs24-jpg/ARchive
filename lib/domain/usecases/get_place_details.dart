import 'package:archive/domain/entities/place.dart';
import 'package:archive/domain/repositories/place_repository.dart';

class GetPlaceDetails {
  final PlaceRepository repository;

  const GetPlaceDetails(this.repository);

  Future<Place> call(String placeId, {String language = 'en'}) {
    return repository.getPlaceDetails(placeId, language: language);
  }
}
