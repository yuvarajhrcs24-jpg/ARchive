import 'package:archive/domain/entities/trip.dart';
import 'package:archive/domain/repositories/saved_repository.dart';

class CreateTrip {
  final SavedRepository repository;

  const CreateTrip(this.repository);

  Future<Trip> call(String name) => repository.createTrip(name);
}
