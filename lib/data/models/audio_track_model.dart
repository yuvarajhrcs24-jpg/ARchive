class AudioTrackModel {
  final String id;
  final String placeId;
  final String language;
  final String title;
  final String fileUrl;
  final String? localPath;
  final int durationSeconds;

  const AudioTrackModel({
    required this.id,
    required this.placeId,
    required this.language,
    required this.title,
    required this.fileUrl,
    this.localPath,
    required this.durationSeconds,
  });

  factory AudioTrackModel.fromJson(Map<String, dynamic> json) {
    return AudioTrackModel(
      id: json['id'] as String? ?? '',
      placeId: json['placeId'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      title: json['title'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
      localPath: json['localPath'] as String?,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'language': language,
      'title': title,
      'fileUrl': fileUrl,
      'localPath': localPath,
      'durationSeconds': durationSeconds,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  factory AudioTrackModel.fromMap(Map<String, dynamic> map) =>
      AudioTrackModel.fromJson(map);

  AudioTrackModel copyWith({
    String? id,
    String? placeId,
    String? language,
    String? title,
    String? fileUrl,
    String? localPath,
    int? durationSeconds,
  }) {
    return AudioTrackModel(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      language: language ?? this.language,
      title: title ?? this.title,
      fileUrl: fileUrl ?? this.fileUrl,
      localPath: localPath ?? this.localPath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  bool get isDownloaded => localPath != null && localPath!.isNotEmpty;

  String get effectiveUrl => isDownloaded ? localPath! : fileUrl;
}
