import 'package:archive/domain/entities/trip.dart';
import 'package:archive/domain/repositories/saved_repository.dart';

class AddStopToTrip {
  final SavedRepository repository;

  const AddStopToTrip(this.repository);

  Future<Trip> call(String tripId, String placeId, {String notes = ''}) {
    return repository.addStopToTrip(tripId, placeId, notes: notes);
  }
}
