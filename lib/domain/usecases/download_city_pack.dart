import 'package:archive/domain/entities/city_pack.dart';
import 'package:archive/domain/repositories/download_repository.dart';

class DownloadCityPack {
  final DownloadRepository repository;

  const DownloadCityPack(this.repository);

  Stream<double> call(String packId) => repository.downloadCityPack(packId);
}

class GetDownloadedPacks {
  final DownloadRepository repository;

  const GetDownloadedPacks(this.repository);

  Future<List<CityPack>> call() => repository.getCityPacks();
}
