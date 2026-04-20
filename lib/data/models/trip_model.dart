import 'package:archive/data/models/trip_stop_model.dart';
import 'dart:convert';

class TripModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<TripStopModel> stops;

  const TripModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.stops = const [],
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final stopsList = json['stops'];
    List<TripStopModel> stops = [];
    if (stopsList is String) {
      try {
        final decoded = jsonDecode(stopsList) as List?;
        stops = decoded
                ?.map((s) => TripStopModel.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [];
      } catch (_) {}
    } else if (stopsList is List) {
      stops = stopsList
          .map((s) => TripStopModel.fromJson(s as Map<String, dynamic>))
          .toList();
    }
    return TripModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
      stops: stops,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'stops': stops.map((s) => s.toJson()).toList(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory TripModel.fromMap(Map<String, dynamic> map) =>
      TripModel.fromJson(map);

  TripModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<TripStopModel>? stops,
  }) {
    return TripModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      stops: stops ?? this.stops,
    );
  }
}
