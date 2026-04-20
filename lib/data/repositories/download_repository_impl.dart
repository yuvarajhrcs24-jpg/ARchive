import 'package:archive/data/datasources/download_datasource.dart';
import 'package:archive/domain/entities/city_pack.dart';
import 'package:archive/domain/repositories/download_repository.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  final DownloadDatasource datasource;

  DownloadRepositoryImpl(this.datasource);

  @override
  Future<List<CityPack>> getCityPacks() async {
    final models = await datasource.getCityPacks();
    return models
        .map((m) => CityPack(
              id: m.id,
              cityName: m.cityName,
              version: m.version,
              sizeBytes: m.sizeBytes,
              checksum: m.checksum,
              lastUpdated: m.lastUpdated,
              downloadStatus: _toEntityStatus(m.downloadStatus),
              downloadProgress: m.downloadProgress,
            ))
        .toList();
  }

  @override
  Stream<double> downloadCityPack(String packId) =>
      datasource.downloadCityPack(packId);

  @override
  Future<void> deleteCityPack(String packId) =>
      datasource.deleteCityPack(packId);

  @override
  Stream<double> getDownloadProgress(String packId) =>
      datasource.getDownloadProgress(packId);

  @override
  Future<int> getStorageUsageBytes() => datasource.getStorageUsageBytes();

  CityPackDownloadStatus _toEntityStatus(DownloadStatus s) {
    return switch (s) {
      DownloadStatus.downloading => CityPackDownloadStatus.downloading,
      DownloadStatus.downloaded => CityPackDownloadStatus.downloaded,
      DownloadStatus.failed => CityPackDownloadStatus.failed,
      DownloadStatus.none => CityPackDownloadStatus.none,
    };
  }
}
