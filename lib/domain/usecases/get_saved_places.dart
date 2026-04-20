import 'package:archive/domain/entities/saved_place.dart';
import 'package:archive/domain/repositories/saved_repository.dart';

class GetSavedPlaces {
  final SavedRepository repository;

  const GetSavedPlaces(this.repository);

  Future<List<SavedPlace>> call() => repository.getSavedPlaces();
}
