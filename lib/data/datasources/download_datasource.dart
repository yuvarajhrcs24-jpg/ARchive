import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:archive/core/database/database_helper.dart';
import 'package:archive/core/errors/failures.dart';
import 'package:archive/data/models/city_pack_model.dart';

class DownloadDatasource {
  final Dio dio;
  final DatabaseHelper dbHelper;
  final Map<String, StreamController<double>> _progressControllers = {};

  DownloadDatasource(this.dio, this.dbHelper);

  Future<List<CityPackModel>> getCityPacks() async {
    final db = await dbHelper.database;
    final maps = await db.query('city_packs');
    if (maps.isEmpty) {
      return _getDefaultCityPacks();
    }
    return maps.map((m) => CityPackModel.fromMap(m)).toList();
  }

  List<CityPackModel> _getDefaultCityPacks() {
    return [
      CityPackModel(
        id: 'mysore',
        cityName: 'Mysore',
        version: '1.0',
        sizeBytes: 15 * 1024 * 1024,
        checksum: 'abc123',
        lastUpdated: DateTime.now(),
        downloadStatus: DownloadStatus.none,
      ),
      CityPackModel(
        id: 'bangalore',
        cityName: 'Bangalore',
        version: '1.0',
        sizeBytes: 22 * 1024 * 1024,
        checksum: 'def456',
        lastUpdated: DateTime.now(),
        downloadStatus: DownloadStatus.none,
      ),
    ];
  }

  Stream<double> downloadCityPack(String packId) {
    final controller = StreamController<double>.broadcast();
    _progressControllers[packId] = controller;

    _startDownload(packId, controller);

    return controller.stream;
  }

  Future<void> _startDownload(
    String packId,
    StreamController<double> controller,
  ) async {
    try {
      await _updatePackStatus(packId, DownloadStatus.downloading, 0.0);

      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/packs/$packId.zip';
      await Directory('${dir.path}/packs').create(recursive: true);

      // Phase-2: implement real city pack bundle download from CDN
      // Simulate download progress for demo
      for (var i = 0; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        final progress = i / 10;
        controller.add(progress);
        await _updatePackStatus(packId, DownloadStatus.downloading, progress);
      }

      await File(savePath).writeAsString('{}');
      await _updatePackStatus(packId, DownloadStatus.downloaded, 1.0);
      controller.close();
    } catch (e) {
      await _updatePackStatus(packId, DownloadStatus.failed, 0.0);
      controller.addError(DownloadFailure('Download failed: $e'));
      controller.close();
    }
  }

  Future<void> _updatePackStatus(
    String packId,
    DownloadStatus status,
    double progress,
  ) async {
    final db = await dbHelper.database;
    await db.insert(
      'city_packs',
      {
        'id': packId,
        'cityName': packId,
        'version': '1.0',
        'sizeBytes': 0,
        'checksum': '',
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        'downloadStatus': status.name,
        'downloadProgress': progress,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCityPack(String packId) async {
    final db = await dbHelper.database;
    await db.delete('city_packs', where: 'id = ?', whereArgs: [packId]);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/packs/$packId.zip');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Stream<double> getDownloadProgress(String packId) {
    return _progressControllers[packId]?.stream ?? Stream.value(0.0);
  }

  Future<int> getStorageUsageBytes() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final packsDir = Directory('${dir.path}/packs');
      if (!await packsDir.exists()) return 0;

      int total = 0;
      await for (final entity in packsDir.list()) {
        if (entity is File) {
          total += await entity.length();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  void dispose() {
    for (final c in _progressControllers.values) {
      if (!c.isClosed) c.close();
    }
    _progressControllers.clear();
  }
}
