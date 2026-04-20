import 'package:archive/domain/repositories/saved_repository.dart';

class RemoveBookmark {
  final SavedRepository repository;

  const RemoveBookmark(this.repository);

  Future<void> call(String placeId) => repository.removePlace(placeId);
}
