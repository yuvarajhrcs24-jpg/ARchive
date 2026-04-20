class AudioTrack {
  final String id;
  final String placeId;
  final String language;
  final String title;
  final String fileUrl;
  final String? localPath;
  final int durationSeconds;

  const AudioTrack({
    required this.id,
    required this.placeId,
    required this.language,
    required this.title,
    required this.fileUrl,
    this.localPath,
    required this.durationSeconds,
  });

  AudioTrack copyWith({
    String? id,
    String? placeId,
    String? language,
    String? title,
    String? fileUrl,
    String? localPath,
    int? durationSeconds,
  }) {
    return AudioTrack(
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
