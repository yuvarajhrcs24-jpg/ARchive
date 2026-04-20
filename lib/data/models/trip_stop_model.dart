class TripStopModel {
  final String placeId;
  final int order;
  final String notes;

  const TripStopModel({
    required this.placeId,
    required this.order,
    this.notes = '',
  });

  factory TripStopModel.fromJson(Map<String, dynamic> json) {
    return TripStopModel(
      placeId: json['placeId'] as String? ?? '',
      order: json['order'] as int? ?? json['stopOrder'] as int? ?? 0,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'order': order,
      'notes': notes,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'stopOrder': order,
      'notes': notes,
    };
  }

  factory TripStopModel.fromMap(Map<String, dynamic> map) =>
      TripStopModel.fromJson(map);

  TripStopModel copyWith({
    String? placeId,
    int? order,
    String? notes,
  }) {
    return TripStopModel(
      placeId: placeId ?? this.placeId,
      order: order ?? this.order,
      notes: notes ?? this.notes,
    );
  }
}
