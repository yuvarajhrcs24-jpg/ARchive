class SavedPlace {
  final String placeId;
  final DateTime savedAt;

  const SavedPlace({required this.placeId, required this.savedAt});

  SavedPlace copyWith({String? placeId, DateTime? savedAt}) {
    return SavedPlace(
      placeId: placeId ?? this.placeId,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}
