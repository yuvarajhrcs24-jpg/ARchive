class TripStop {
  final String placeId;
  final int order;
  final String notes;

  const TripStop({
    required this.placeId,
    required this.order,
    this.notes = '',
  });

  TripStop copyWith({String? placeId, int? order, String? notes}) {
    return TripStop(
      placeId: placeId ?? this.placeId,
      order: order ?? this.order,
      notes: notes ?? this.notes,
    );
  }
}

class Trip {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<TripStop> stops;

  const Trip({
    required this.id,
    required this.name,
    required this.createdAt,
    this.stops = const [],
  });

  Trip copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<TripStop>? stops,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      stops: stops ?? this.stops,
    );
  }
}
