class SavedPlaceModel {
  final String placeId;
  final DateTime savedAt;

  const SavedPlaceModel({
    required this.placeId,
    required this.savedAt,
  });

  factory SavedPlaceModel.fromJson(Map<String, dynamic> json) {
    return SavedPlaceModel(
      placeId: json['placeId'] as String? ?? '',
      savedAt: json['savedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['savedAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'savedAt': savedAt.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  factory SavedPlaceModel.fromMap(Map<String, dynamic> map) =>
      SavedPlaceModel.fromJson(map);

  SavedPlaceModel copyWith({String? placeId, DateTime? savedAt}) {
    return SavedPlaceModel(
      placeId: placeId ?? this.placeId,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}
