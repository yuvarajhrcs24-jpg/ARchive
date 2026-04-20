import 'package:archive/domain/entities/city_pack.dart';

abstract class DownloadRepository {
  Future<List<CityPack>> getCityPacks();

  Stream<double> downloadCityPack(String packId);

  Future<void> deleteCityPack(String packId);

  Stream<double> getDownloadProgress(String packId);

  Future<int> getStorageUsageBytes();
}
