enum CityPackDownloadStatus { none, downloading, downloaded, failed }

class CityPack {
  final String id;
  final String cityName;
  final String version;
  final int sizeBytes;
  final String checksum;
  final DateTime lastUpdated;
  final CityPackDownloadStatus downloadStatus;
  final double downloadProgress;

  const CityPack({
    required this.id,
    required this.cityName,
    required this.version,
    required this.sizeBytes,
    required this.checksum,
    required this.lastUpdated,
    this.downloadStatus = CityPackDownloadStatus.none,
    this.downloadProgress = 0.0,
  });

  CityPack copyWith({
    String? id,
    String? cityName,
    String? version,
    int? sizeBytes,
    String? checksum,
    DateTime? lastUpdated,
    CityPackDownloadStatus? downloadStatus,
    double? downloadProgress,
  }) {
    return CityPack(
      id: id ?? this.id,
      cityName: cityName ?? this.cityName,
      version: version ?? this.version,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      checksum: checksum ?? this.checksum,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  String get formattedSize {
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
