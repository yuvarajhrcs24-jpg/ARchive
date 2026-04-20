import 'package:archive/domain/repositories/saved_repository.dart';

class BookmarkPlace {
  final SavedRepository repository;

  const BookmarkPlace(this.repository);

  Future<void> call(String placeId) => repository.savePlace(placeId);
}
