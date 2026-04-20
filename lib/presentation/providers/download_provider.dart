import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archive/core/database/database_helper.dart';
import 'package:archive/data/datasources/download_datasource.dart';
import 'package:archive/data/repositories/download_repository_impl.dart';
import 'package:archive/domain/entities/city_pack.dart';
import 'package:archive/domain/repositories/download_repository.dart';

final _downloadDioProvider = Provider<Dio>((ref) => Dio());

final downloadDatasourceProvider = Provider<DownloadDatasource>((ref) {
  return DownloadDatasource(
    ref.watch(_downloadDioProvider),
    DatabaseHelper.instance,
  );
});

final downloadRepositoryProvider = Provider<DownloadRepository>((ref) {
  return DownloadRepositoryImpl(ref.watch(downloadDatasourceProvider));
});

final cityPacksProvider = FutureProvider<List<CityPack>>((ref) async {
  final repo = ref.watch(downloadRepositoryProvider);
  return repo.getCityPacks();
});

final storageUsageProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(downloadRepositoryProvider);
  return repo.getStorageUsageBytes();
});

class DownloadNotifier extends StateNotifier<Map<String, double>> {
  final DownloadRepository repository;

  DownloadNotifier(this.repository) : super({});

  Future<void> startDownload(String packId) async {
    repository.downloadCityPack(packId).listen(
      (progress) {
        state = {...state, packId: progress};
      },
      onDone: () {
        state = {...state, packId: 1.0};
      },
      onError: (e) {
        state = Map.from(state)..remove(packId);
      },
    );
  }

  Future<void> deletePack(String packId) async {
    await repository.deleteCityPack(packId);
    state = Map.from(state)..remove(packId);
  }
}

final downloadProgressProvider =
    StateNotifierProvider<DownloadNotifier, Map<String, double>>((ref) {
  return DownloadNotifier(ref.watch(downloadRepositoryProvider));
});
