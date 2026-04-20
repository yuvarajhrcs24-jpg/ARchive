import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  static const int _version = 2;
  static const String _dbName = 'archive.db';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_createPlacesTable);
    await db.execute(_createCategoriesTable);
    await db.execute(_createSavedPlacesTable);
    await db.execute(_createTripsTable);
    await db.execute(_createTripStopsTable);
    await db.execute(_createAudioTracksTable);
    await db.execute(_createCityPacksTable);
    await db.execute(_createUserPrefsTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration v1 → v2: add offlineImagePath, offlineAudioPath to places
      try {
        await db.execute(
          'ALTER TABLE places ADD COLUMN offlineImagePath TEXT',
        );
        await db.execute(
          'ALTER TABLE places ADD COLUMN offlineAudioPath TEXT',
        );
      } catch (_) {
        // columns may already exist
      }
    }
  }

  static const String _createPlacesTable = '''
    CREATE TABLE IF NOT EXISTS places (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      shortDescription TEXT,
      imageUrls TEXT,
      lat REAL NOT NULL,
      lng REAL NOT NULL,
      categoryId TEXT,
      rating REAL,
      openingHours TEXT,
      audioUrl TEXT,
      distanceMeters REAL,
      isOffline INTEGER DEFAULT 0,
      offlineImagePath TEXT,
      offlineAudioPath TEXT,
      cachedAt INTEGER
    )
  ''';

  static const String _createCategoriesTable = '''
    CREATE TABLE IF NOT EXISTS categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      iconName TEXT,
      color TEXT
    )
  ''';

  static const String _createSavedPlacesTable = '''
    CREATE TABLE IF NOT EXISTS saved_places (
      placeId TEXT PRIMARY KEY,
      savedAt INTEGER NOT NULL
    )
  ''';

  static const String _createTripsTable = '''
    CREATE TABLE IF NOT EXISTS trips (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      createdAt INTEGER NOT NULL
    )
  ''';

  static const String _createTripStopsTable = '''
    CREATE TABLE IF NOT EXISTS trip_stops (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tripId TEXT NOT NULL,
      placeId TEXT NOT NULL,
      stopOrder INTEGER NOT NULL,
      notes TEXT,
      FOREIGN KEY (tripId) REFERENCES trips(id) ON DELETE CASCADE
    )
  ''';

  static const String _createAudioTracksTable = '''
    CREATE TABLE IF NOT EXISTS audio_tracks (
      id TEXT PRIMARY KEY,
      placeId TEXT NOT NULL,
      language TEXT NOT NULL,
      title TEXT,
      fileUrl TEXT,
      localPath TEXT,
      durationSeconds INTEGER,
      FOREIGN KEY (placeId) REFERENCES places(id) ON DELETE CASCADE
    )
  ''';

  static const String _createCityPacksTable = '''
    CREATE TABLE IF NOT EXISTS city_packs (
      id TEXT PRIMARY KEY,
      cityName TEXT NOT NULL,
      version TEXT,
      sizeBytes INTEGER,
      checksum TEXT,
      lastUpdated INTEGER,
      downloadStatus TEXT DEFAULT 'none',
      downloadProgress REAL DEFAULT 0.0
    )
  ''';

  static const String _createUserPrefsTable = '''
    CREATE TABLE IF NOT EXISTS user_prefs (
      id INTEGER PRIMARY KEY,
      preferredLanguage TEXT DEFAULT 'en',
      selectedCategoryIds TEXT,
      downloadedCityIds TEXT
    )
  ''';

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
