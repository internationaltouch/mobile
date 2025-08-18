import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/event.dart';
import '../models/season.dart';
import '../models/fixture.dart';
import '../models/news_item.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'fit_mobile_app.db';
  static const int _dbVersion = 1;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  static Future<void> _createDB(Database db, int version) async {
    // Events table
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        slug TEXT,
        name TEXT NOT NULL,
        description TEXT,
        logo_url TEXT,
        seasons TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Seasons table
    await db.execute('''
      CREATE TABLE seasons (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        title TEXT NOT NULL,
        slug TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events (id)
      )
    ''');

    // Divisions table
    await db.execute('''
      CREATE TABLE divisions (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        season_slug TEXT NOT NULL,
        name TEXT NOT NULL,
        slug TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events (id)
      )
    ''');

    // Teams table
    await db.execute('''
      CREATE TABLE teams (
        id TEXT PRIMARY KEY,
        division_id TEXT NOT NULL,
        name TEXT NOT NULL,
        abbreviation TEXT,
        logo_url TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (division_id) REFERENCES divisions (id)
      )
    ''');

    // Fixtures table
    await db.execute('''
      CREATE TABLE fixtures (
        id TEXT PRIMARY KEY,
        division_id TEXT NOT NULL,
        home_team_id TEXT NOT NULL,
        away_team_id TEXT NOT NULL,
        home_team_name TEXT NOT NULL,
        away_team_name TEXT NOT NULL,
        home_team_abbreviation TEXT,
        away_team_abbreviation TEXT,
        date_time INTEGER NOT NULL,
        field TEXT,
        home_score INTEGER,
        away_score INTEGER,
        is_completed INTEGER NOT NULL,
        round_info TEXT,
        is_bye INTEGER,
        videos TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (division_id) REFERENCES divisions (id)
      )
    ''');

    // Ladder table
    await db.execute('''
      CREATE TABLE ladder_entries (
        id TEXT PRIMARY KEY,
        division_id TEXT NOT NULL,
        team_name TEXT NOT NULL,
        position INTEGER NOT NULL,
        played INTEGER NOT NULL,
        won INTEGER NOT NULL,
        drawn INTEGER NOT NULL,
        lost INTEGER NOT NULL,
        points_for INTEGER NOT NULL,
        points_against INTEGER NOT NULL,
        points_difference INTEGER NOT NULL,
        points INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (division_id) REFERENCES divisions (id)
      )
    ''');

    // News table
    await db.execute('''
      CREATE TABLE news_items (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        summary TEXT NOT NULL,
        image_url TEXT,
        link TEXT,
        published_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Cache metadata table
    await db.execute('''
      CREATE TABLE cache_metadata (
        key TEXT PRIMARY KEY,
        last_updated INTEGER NOT NULL,
        expiry_duration INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades when schema changes
    if (oldVersion < 2) {
      // Future upgrades can be handled here
    }
  }

  // Cache management
  static Future<bool> isCacheValid(String key, Duration maxAge) async {
    final db = await database;
    final result = await db.query(
      'cache_metadata',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isEmpty) return false;

    final lastUpdated = result.first['last_updated'] as int;
    final expiryDuration = result.first['expiry_duration'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;

    return (now - lastUpdated) < expiryDuration;
  }

  static Future<void> updateCacheMetadata(String key, Duration maxAge) async {
    final db = await database;
    await db.insert(
      'cache_metadata',
      {
        'key': key,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
        'expiry_duration': maxAge.inMilliseconds,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Events
  static Future<void> cacheEvents(List<Event> events) async {
    final db = await database;
    final batch = db.batch();

    for (final event in events) {
      batch.insert(
        'events',
        {
          'id': event.id,
          'slug': event.slug,
          'name': event.name,
          'description': event.description,
          'logo_url': event.logoUrl,
          'seasons': jsonEncode(event.seasons.map((s) => s.toJson()).toList()),
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
    await updateCacheMetadata('events', const Duration(hours: 1));
  }

  static Future<List<Event>> getCachedEvents() async {
    final db = await database;
    final maps = await db.query('events', orderBy: 'name');
    
    return maps.map((map) {
      final seasonsJson = map['seasons'] as String?;
      final seasons = seasonsJson != null
          ? (jsonDecode(seasonsJson) as List)
              .map((s) => Season.fromJson(s))
              .toList()
          : <Season>[];

      return Event(
        id: map['id'] as String,
        slug: map['slug'] as String?,
        name: map['name'] as String,
        description: map['description'] as String? ?? '',
        logoUrl: map['logo_url'] as String? ?? '',
        seasons: seasons,
      );
    }).toList();
  }

  // Fixtures
  static Future<void> cacheFixtures(String divisionId, List<Fixture> fixtures) async {
    final db = await database;
    final batch = db.batch();

    // Clear existing fixtures for this division
    batch.delete('fixtures', where: 'division_id = ?', whereArgs: [divisionId]);

    for (final fixture in fixtures) {
      batch.insert(
        'fixtures',
        {
          'id': fixture.id,
          'division_id': divisionId,
          'home_team_id': fixture.homeTeamId,
          'away_team_id': fixture.awayTeamId,
          'home_team_name': fixture.homeTeamName,
          'away_team_name': fixture.awayTeamName,
          'home_team_abbreviation': fixture.homeTeamAbbreviation,
          'away_team_abbreviation': fixture.awayTeamAbbreviation,
          'date_time': fixture.dateTime.millisecondsSinceEpoch,
          'field': fixture.field,
          'home_score': fixture.homeScore,
          'away_score': fixture.awayScore,
          'is_completed': fixture.isCompleted ? 1 : 0,
          'round_info': fixture.round,
          'is_bye': fixture.isBye == true ? 1 : 0,
          'videos': jsonEncode(fixture.videos),
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
    await updateCacheMetadata('fixtures_$divisionId', const Duration(minutes: 15));
  }

  static Future<List<Fixture>> getCachedFixtures(String divisionId) async {
    final db = await database;
    final maps = await db.query(
      'fixtures',
      where: 'division_id = ?',
      whereArgs: [divisionId],
      orderBy: 'date_time',
    );

    return maps.map((map) {
      final videosJson = map['videos'] as String?;
      final videos = videosJson != null
          ? (jsonDecode(videosJson) as List).cast<String>()
          : <String>[];

      return Fixture(
        id: map['id'] as String,
        homeTeamId: map['home_team_id'] as String,
        awayTeamId: map['away_team_id'] as String,
        homeTeamName: map['home_team_name'] as String,
        awayTeamName: map['away_team_name'] as String,
        homeTeamAbbreviation: map['home_team_abbreviation'] as String?,
        awayTeamAbbreviation: map['away_team_abbreviation'] as String?,
        dateTime: DateTime.fromMillisecondsSinceEpoch(map['date_time'] as int),
        field: map['field'] as String? ?? '',
        divisionId: divisionId,
        homeScore: map['home_score'] as int?,
        awayScore: map['away_score'] as int?,
        isCompleted: (map['is_completed'] as int) == 1,
        round: map['round_info'] as String?,
        isBye: (map['is_bye'] as int?) == 1,
        videos: videos,
      );
    }).toList();
  }

  // News
  static Future<void> cacheNewsItems(List<NewsItem> newsItems) async {
    final db = await database;
    final batch = db.batch();

    for (final newsItem in newsItems) {
      batch.insert(
        'news_items',
        {
          'id': newsItem.id,
          'title': newsItem.title,
          'summary': newsItem.summary,
          'image_url': newsItem.imageUrl,
          'link': newsItem.link,
          'published_at': newsItem.publishedAt.millisecondsSinceEpoch,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
    await updateCacheMetadata('news', const Duration(minutes: 30));
  }

  static Future<List<NewsItem>> getCachedNewsItems() async {
    final db = await database;
    final maps = await db.query(
      'news_items',
      orderBy: 'published_at DESC',
    );

    return maps.map((map) => NewsItem(
      id: map['id'] as String,
      title: map['title'] as String,
      summary: map['summary'] as String,
      imageUrl: map['image_url'] as String? ?? '',
      link: map['link'] as String?,
      publishedAt: DateTime.fromMillisecondsSinceEpoch(map['published_at'] as int),
    )).toList();
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('cache_metadata');
    await db.delete('events');
    await db.delete('seasons');
    await db.delete('divisions');
    await db.delete('teams');
    await db.delete('fixtures');
    await db.delete('ladder_entries');
    await db.delete('news_items');
  }

  // Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}