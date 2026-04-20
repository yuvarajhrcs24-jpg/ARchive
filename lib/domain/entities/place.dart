class Place {
  final String id;
  final String name;
  final String description;
  final String shortDescription;
  final List<String> imageUrls;
  final double lat;
  final double lng;
  final String categoryId;
  final double rating;
  final String openingHours;
  final String audioUrl;
  final double distanceMeters;
  final bool isOffline;
  final String? offlineImagePath;
  final String? offlineAudioPath;

  const Place({
    required this.id,
    required this.name,
    required this.description,
    required this.shortDescription,
    required this.imageUrls,
    required this.lat,
    required this.lng,
    required this.categoryId,
    required this.rating,
    required this.openingHours,
    required this.audioUrl,
    required this.distanceMeters,
    required this.isOffline,
    this.offlineImagePath,
    this.offlineAudioPath,
  });

  Place copyWith({
    String? id,
    String? name,
    String? description,
    String? shortDescription,
    List<String>? imageUrls,
    double? lat,
    double? lng,
    String? categoryId,
    double? rating,
    String? openingHours,
    String? audioUrl,
    double? distanceMeters,
    bool? isOffline,
    String? offlineImagePath,
    String? offlineAudioPath,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      imageUrls: imageUrls ?? this.imageUrls,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      categoryId: categoryId ?? this.categoryId,
      rating: rating ?? this.rating,
      openingHours: openingHours ?? this.openingHours,
      audioUrl: audioUrl ?? this.audioUrl,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isOffline: isOffline ?? this.isOffline,
      offlineImagePath: offlineImagePath ?? this.offlineImagePath,
      offlineAudioPath: offlineAudioPath ?? this.offlineAudioPath,
    );
  }
}
