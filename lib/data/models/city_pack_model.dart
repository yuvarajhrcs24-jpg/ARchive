enum DownloadStatus { none, downloading, downloaded, failed }

class CityPackModel {
  final String id;
  final String cityName;
  final String version;
  final int sizeBytes;
  final String checksum;
  final DateTime lastUpdated;
  final DownloadStatus downloadStatus;
  final double downloadProgress;

  const CityPackModel({
    required this.id,
    required this.cityName,
    required this.version,
    required this.sizeBytes,
    required this.checksum,
    required this.lastUpdated,
    this.downloadStatus = DownloadStatus.none,
    this.downloadProgress = 0.0,
  });

  factory CityPackModel.fromJson(Map<String, dynamic> json) {
    return CityPackModel(
      id: json['id'] as String? ?? '',
      cityName: json['cityName'] as String? ?? '',
      version: json['version'] as String? ?? '1.0',
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      checksum: json['checksum'] as String? ?? '',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastUpdated'] as int)
          : DateTime.now(),
      downloadStatus: _statusFromString(json['downloadStatus'] as String?),
      downloadProgress: (json['downloadProgress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static DownloadStatus _statusFromString(String? s) {
    switch (s) {
      case 'downloading':
        return DownloadStatus.downloading;
      case 'downloaded':
        return DownloadStatus.downloaded;
      case 'failed':
        return DownloadStatus.failed;
      default:
        return DownloadStatus.none;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityName': cityName,
      'version': version,
      'sizeBytes': sizeBytes,
      'checksum': checksum,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'downloadStatus': downloadStatus.name,
      'downloadProgress': downloadProgress,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  factory CityPackModel.fromMap(Map<String, dynamic> map) =>
      CityPackModel.fromJson(map);

  CityPackModel copyWith({
    String? id,
    String? cityName,
    String? version,
    int? sizeBytes,
    String? checksum,
    DateTime? lastUpdated,
    DownloadStatus? downloadStatus,
    double? downloadProgress,
  }) {
    return CityPackModel(
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
