import 'package:hive/hive.dart';

part 'trip.g.dart';

@HiveType(typeId: 1)
class Trip {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final List<String> placeIds; // IDs of places in order
  
  @HiveField(3)
  final DateTime createdDate;
  
  @HiveField(4)
  final DateTime? startDate;
  
  @HiveField(5)
  final DateTime? endDate;
  
  @HiveField(6)
  final String description;
  
  @HiveField(7)
  final String userId; // For syncing across devices

  Trip({
    required this.id,
    required this.title,
    required this.placeIds,
    required this.createdDate,
    this.startDate,
    this.endDate,
    required this.description,
    required this.userId,
  });

  Trip copyWith({
    String? id,
    String? title,
    List<String>? placeIds,
    DateTime? createdDate,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    String? userId,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      placeIds: placeIds ?? this.placeIds,
      createdDate: createdDate ?? this.createdDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'placeIds': placeIds,
      'createdDate': createdDate.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
      'userId': userId,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      placeIds: List<String>.from(map['placeIds'] ?? []),
      createdDate: DateTime.parse(map['createdDate'] ?? DateTime.now().toIso8601String()),
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      description: map['description'] ?? '',
      userId: map['userId'] ?? '',
    );
  }
}
