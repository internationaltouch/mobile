import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/event.dart';
import '../models/season.dart';
import '../models/division.dart';
import '../models/team.dart';
import '../models/fixture.dart';
import '../models/news_item.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'fit_mobile_app.db';
  static const int _dbVersion = 1;

  static Future<Database> get database async {
    if (_database != null) {
      debugPrint('🗄️ [SQLite] ♾️ Using existing database instance');
      return _database!;
    }
    debugPrint('🗄️ [SQLite] 🔧 Initializing database...');
    try {
      _database = await _initDB();
      debugPrint('🗄️ [SQLite] ✅ Database initialized successfully');
      return _database!;
    } catch (e) {
      debugPrint('🗄️ [SQLite] ❌ Database initialization failed: $e');
      rethrow;
    }
  }

  static Future<Database> _initDB() async {
    debugPrint('🗄️ [SQLite] 📁 Getting database path...');
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    debugPrint('🗄️ [SQLite] 📁 Database path: $path');

    // Delete existing database file to force fresh start
    final dbFile = File(path);
    if (await dbFile.exists()) {
      debugPrint(
          '🗄️ [SQLite] 🗑️ Deleting existing database file for fresh start...');
      await dbFile.delete();
      debugPrint('🗄️ [SQLite] ✅ Existing database deleted');
    }

    debugPrint('🗄️ [SQLite] 📊 Database version: $_dbVersion');
    debugPrint('🗄️ [SQLite] 📛 Opening database...');

    try {
      final db = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _createDB,
        onUpgrade: (db, oldVersion, newVersion) async {
          debugPrint(
              '🗄️ [SQLite] ⬆️ Database upgrade from $oldVersion to $newVersion (should not happen with file deletion)');
          await _dropAllTables(db);
          await _createDB(db, newVersion);
        },
      );
      debugPrint('🗄️ [SQLite] ✅ Database opened successfully');
      return db;
    } catch (e) {
      debugPrint('🗄️ [SQLite] ❌ Failed to open database: $e');
      rethrow;
    }
  }

  static Future<void> _createDB(Database db, int version) async {
    debugPrint(
        '🗄️ [SQLite] 🏠 Creating database tables (version $version)...');

    // Events table (Competition level)
    debugPrint('🗄️ [SQLite] 🏢 Creating events table...');
    await db.execute('''
      CREATE TABLE events (
        slug TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        logo_url TEXT,
        api_order INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Seasons table (Competition + Season level)
    await db.execute('''
      CREATE TABLE seasons (
        competition_slug TEXT NOT NULL,
        season_slug TEXT NOT NULL,
        title TEXT NOT NULL,
        api_order INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        PRIMARY KEY (competition_slug, season_slug),
        FOREIGN KEY (competition_slug) REFERENCES events (slug)
      )
    ''');

    // Divisions table (Competition + Season + Division level)
    await db.execute('''
      CREATE TABLE divisions (
        competition_slug TEXT NOT NULL,
        season_slug TEXT NOT NULL,
        division_slug TEXT NOT NULL,
        name TEXT NOT NULL,
        api_order INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        PRIMARY KEY (competition_slug, season_slug, division_slug),
        FOREIGN KEY (competition_slug, season_slug) REFERENCES seasons (competition_slug, season_slug)
      )
    ''');

    // Teams table
    await db.execute('''
      CREATE TABLE teams (
        id TEXT PRIMARY KEY,
        competition_slug TEXT NOT NULL,
        season_slug TEXT NOT NULL,
        division_slug TEXT NOT NULL,
        name TEXT NOT NULL,
        abbreviation TEXT,
        logo_url TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (competition_slug, season_slug, division_slug) REFERENCES divisions (competition_slug, season_slug, division_slug)
      )
    ''');

    // Fixtures table
    await db.execute('''
      CREATE TABLE fixtures (
        id TEXT PRIMARY KEY,
        competition_slug TEXT NOT NULL,
        season_slug TEXT NOT NULL,
        division_slug TEXT NOT NULL,
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
        FOREIGN KEY (competition_slug, season_slug, division_slug) REFERENCES divisions (competition_slug, season_slug, division_slug)
      )
    ''');

    // Ladder table
    await db.execute('''
      CREATE TABLE ladder_entries (
        id TEXT PRIMARY KEY,
        competition_slug TEXT NOT NULL,
        season_slug TEXT NOT NULL,
        division_slug TEXT NOT NULL,
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
        FOREIGN KEY (competition_slug, season_slug, division_slug) REFERENCES divisions (competition_slug, season_slug, division_slug)
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

    // Favourites table
    await db.execute('''
      CREATE TABLE favourites (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        competition_slug TEXT,
        competition_name TEXT,
        season_slug TEXT,
        season_name TEXT,
        division_slug TEXT,
        division_name TEXT,
        team_id TEXT,
        team_name TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    debugPrint('🗄️ [SQLite] ✅ All database tables created successfully');
  }

  // Helper method to drop all tables
  static Future<void> _dropAllTables(Database db) async {
    debugPrint('🗄️ [SQLite] 🗑️ Dropping all existing tables...');
    await db.execute('DROP TABLE IF EXISTS favourites');
    await db.execute('DROP TABLE IF EXISTS cache_metadata');
    await db.execute('DROP TABLE IF EXISTS news_items');
    await db.execute('DROP TABLE IF EXISTS ladder_entries');
    await db.execute('DROP TABLE IF EXISTS fixtures');
    await db.execute('DROP TABLE IF EXISTS teams');
    await db.execute('DROP TABLE IF EXISTS divisions');
    await db.execute('DROP TABLE IF EXISTS seasons');
    await db.execute('DROP TABLE IF EXISTS events');
    debugPrint('🗄️ [SQLite] ✅ All tables dropped successfully');
  }

  // Cache management
  static Future<bool> isCacheValid(String key, Duration maxAge) async {
    debugPrint('🕰️ [Cache] 🔍 Checking cache validity for key: $key');
    debugPrint('🕰️ [Cache] 📞 Getting database instance...');
    final db = await database;
    debugPrint(
        '🕰️ [Cache] ✅ Database instance obtained, querying cache_metadata...');
    final result = await db.query(
      'cache_metadata',
      where: 'key = ?',
      whereArgs: [key],
    );
    debugPrint(
        '🕰️ [Cache] 📋 Query completed, found ${result.length} results');

    if (result.isEmpty) {
      debugPrint('🕰️ [Cache] ❌ No cache metadata found for key: $key');
      return false;
    }

    final lastUpdated = result.first['last_updated'] as int;
    final expiryDuration = result.first['expiry_duration'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final ageMs = now - lastUpdated;
    final isValid = ageMs < expiryDuration;

    debugPrint(
        '🕰️ [Cache] 📅 Cache for $key: age=${ageMs}ms, ttl=${expiryDuration}ms, valid=$isValid');
    return isValid;
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

    for (int i = 0; i < events.length; i++) {
      final event = events[i];

      // Cache the event using slug as primary key
      batch.insert(
        'events',
        {
          'slug': event.slug ?? event.id,
          'name': event.name,
          'description': event.description,
          'logo_url': event.logoUrl,
          'api_order': i,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Cache the seasons for this event with composite keys
      debugPrint(
          '🗺️ [SQLite] 🏆 Caching ${event.seasons.length} seasons for event: ${event.name}');
      for (int j = 0; j < event.seasons.length; j++) {
        final season = event.seasons[j];
        batch.insert(
          'seasons',
          {
            'competition_slug': event.slug ?? event.id,
            'season_slug': season.slug,
            'title': season.title,
            'api_order': j,
            'created_at': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        debugPrint(
            '🗺️ [SQLite] 🏆 → Cached season: ${season.title} (${season.slug})');
      }
    }

    await batch.commit();
    await updateCacheMetadata('events', const Duration(hours: 1));
  }

  static Future<List<Event>> getCachedEvents() async {
    final db = await database;
    final eventMaps = await db.query('events', orderBy: 'api_order');

    final events = <Event>[];

    for (final eventMap in eventMaps) {
      final competitionSlug = eventMap['slug'] as String;

      // Get seasons for this event using competition slug
      final seasonMaps = await db.query(
        'seasons',
        where: 'competition_slug = ?',
        whereArgs: [competitionSlug],
        orderBy: 'api_order',
      );

      final seasons = seasonMaps
          .map((seasonMap) => Season(
                title: seasonMap['title'] as String,
                slug: seasonMap['season_slug'] as String,
              ))
          .toList();

      final event = Event(
        id: competitionSlug, // Use slug as ID for compatibility
        slug: competitionSlug,
        name: eventMap['name'] as String,
        description: eventMap['description'] as String? ?? '',
        logoUrl: eventMap['logo_url'] as String? ?? '',
        seasons: seasons,
      );

      events.add(event);
    }

    return events;
  }

  // Divisions
  static Future<void> cacheDivisions(String competitionSlug, String seasonSlug,
      List<Division> divisions) async {
    final db = await database;
    final batch = db.batch();

    // Clear existing divisions for this competition/season
    batch.delete('divisions',
        where: 'competition_slug = ? AND season_slug = ?',
        whereArgs: [competitionSlug, seasonSlug]);

    for (int i = 0; i < divisions.length; i++) {
      final division = divisions[i];
      batch.insert(
        'divisions',
        {
          'competition_slug': competitionSlug,
          'season_slug': seasonSlug,
          'division_slug': division.slug ?? division.id,
          'name': division.name,
          'api_order': i,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
    await updateCacheMetadata('divisions_${competitionSlug}_$seasonSlug',
        const Duration(minutes: 30));
  }

  static Future<List<Division>> getCachedDivisions(
      String competitionSlug, String seasonSlug) async {
    final db = await database;
    final maps = await db.query(
      'divisions',
      where: 'competition_slug = ? AND season_slug = ?',
      whereArgs: [competitionSlug, seasonSlug],
      orderBy: 'api_order',
    );

    return maps
        .map((map) => Division(
              id: map['division_slug'] as String,
              name: map['name'] as String,
              eventId: map['competition_slug'] as String,
              season: seasonSlug,
              slug: map['division_slug'] as String,
            ))
        .toList();
  }

  // Teams
  static Future<void> cacheTeams(String competitionSlug, String seasonSlug,
      String divisionSlug, List<Team> teams) async {
    final db = await database;
    final batch = db.batch();

    // Clear existing teams for this division
    batch.delete('teams',
        where: 'competition_slug = ? AND season_slug = ? AND division_slug = ?',
        whereArgs: [competitionSlug, seasonSlug, divisionSlug]);

    for (int i = 0; i < teams.length; i++) {
      final team = teams[i];
      batch.insert(
        'teams',
        {
          'id': team.id,
          'competition_slug': competitionSlug,
          'season_slug': seasonSlug,
          'division_slug': divisionSlug,
          'name': team.name,
          'abbreviation': team.abbreviation,
          'logo_url': '', // Team model doesn't have logoUrl
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
    await updateCacheMetadata(
        'teams_${competitionSlug}_${seasonSlug}_$divisionSlug',
        const Duration(minutes: 30));
  }

  static Future<List<Team>> getCachedTeams(
      String competitionSlug, String seasonSlug, String divisionSlug) async {
    final db = await database;
    final maps = await db.query(
      'teams',
      where: 'competition_slug = ? AND season_slug = ? AND division_slug = ?',
      whereArgs: [competitionSlug, seasonSlug, divisionSlug],
      orderBy: 'name', // Teams can be ordered alphabetically
    );

    return maps
        .map((map) => Team(
              id: map['id'] as String,
              name: map['name'] as String,
              divisionId: divisionSlug, // Use division slug for compatibility
              abbreviation: map['abbreviation'] as String?,
            ))
        .toList();
  }

  // Fixtures
  static Future<void> cacheFixtures(String competitionSlug, String seasonSlug,
      String divisionSlug, List<Fixture> fixtures) async {
    final db = await database;
    final batch = db.batch();

    // Clear existing fixtures for this division
    batch.delete('fixtures',
        where: 'competition_slug = ? AND season_slug = ? AND division_slug = ?',
        whereArgs: [competitionSlug, seasonSlug, divisionSlug]);

    for (final fixture in fixtures) {
      batch.insert(
        'fixtures',
        {
          'id': fixture.id,
          'competition_slug': competitionSlug,
          'season_slug': seasonSlug,
          'division_slug': divisionSlug,
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
    await updateCacheMetadata(
        'fixtures_${competitionSlug}_${seasonSlug}_$divisionSlug',
        const Duration(minutes: 15));
  }

  static Future<List<Fixture>> getCachedFixtures(
      String competitionSlug, String seasonSlug, String divisionSlug) async {
    final db = await database;
    final maps = await db.query(
      'fixtures',
      where: 'competition_slug = ? AND season_slug = ? AND division_slug = ?',
      whereArgs: [competitionSlug, seasonSlug, divisionSlug],
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
        divisionId: divisionSlug, // Use division slug for compatibility
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
    debugPrint(
        '🗺️ [SQLite] 💾 Caching ${newsItems.length} news items to database...');
    final db = await database;
    final batch = db.batch();

    // Clear existing news items first to avoid conflicts
    debugPrint('🗺️ [SQLite] 🧹 Clearing existing news items...');
    batch.delete('news_items');

    for (int i = 0; i < newsItems.length; i++) {
      final newsItem = newsItems[i];
      debugPrint(
          '🗺️ [SQLite] 📝 Inserting news item ${i + 1}/${newsItems.length}: ID="${newsItem.id}", Title="${newsItem.title.length > 50 ? '${newsItem.title.substring(0, 50)}...' : newsItem.title}"');

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

    try {
      await batch.commit();
      debugPrint(
          '🗺️ [SQLite] ✅ Successfully inserted ${newsItems.length} news items into database');
      await updateCacheMetadata('news', const Duration(minutes: 30));
      debugPrint('🗺️ [SQLite] ✅ Cache metadata updated for news (30min TTL)');
    } catch (e) {
      debugPrint('🗺️ [SQLite] ❌ Error caching news items: $e');
      rethrow;
    }
  }

  static Future<List<NewsItem>> getCachedNewsItems() async {
    debugPrint('🗺️ [SQLite] 🔍 Querying cached news items from database...');
    try {
      final db = await database;
      final maps = await db.query(
        'news_items',
        orderBy: 'published_at DESC',
      );

      debugPrint(
          '🗺️ [SQLite] 📄 Found ${maps.length} cached news items in database');

      final newsItems = maps
          .map((map) => NewsItem(
                id: map['id'] as String,
                title: map['title'] as String,
                summary: map['summary'] as String,
                imageUrl: map['image_url'] as String? ?? '',
                link: map['link'] as String?,
                publishedAt: DateTime.fromMillisecondsSinceEpoch(
                    map['published_at'] as int),
              ))
          .toList();

      debugPrint(
          '🗺️ [SQLite] ✅ Successfully loaded ${newsItems.length} news items from cache');
      return newsItems;
    } catch (e) {
      debugPrint('🗺️ [SQLite] ❌ Error loading cached news items: $e');
      return [];
    }
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    final db = await database;
    await _clearAllCacheWithDb(db);
  }

  // Helper method to clear cache with existing database instance
  static Future<void> _clearAllCacheWithDb(Database db) async {
    debugPrint('🗄️ [SQLite] 🧤 Clearing all cache data...');
    await db.delete('cache_metadata');
    await db.delete('events');
    await db.delete('seasons');
    await db.delete('divisions');
    await db.delete('teams');
    await db.delete('fixtures');
    await db.delete('ladder_entries');
    await db.delete('news_items');
    debugPrint('🗄️ [SQLite] ✅ All cache data cleared');
  }

  // Favourites management
  static Future<void> addFavourite({
    required String type,
    String? competitionSlug,
    String? competitionName,
    String? seasonSlug,
    String? seasonName,
    String? divisionSlug,
    String? divisionName,
    String? teamId,
    String? teamName,
  }) async {
    final db = await database;

    // Generate a unique ID based on the type and identifiers
    String id;
    switch (type) {
      case 'competition':
        id = 'comp_$competitionSlug';
        break;
      case 'season':
        id = 'season_${competitionSlug}_$seasonSlug';
        break;
      case 'division':
        id = 'div_${competitionSlug}_${seasonSlug}_$divisionSlug';
        break;
      case 'team':
        id = 'team_${competitionSlug}_${seasonSlug}_${divisionSlug}_$teamId';
        break;
      default:
        throw ArgumentError('Invalid favourite type: $type');
    }

    await db.insert(
      'favourites',
      {
        'id': id,
        'type': type,
        'competition_slug': competitionSlug,
        'competition_name': competitionName,
        'season_slug': seasonSlug,
        'season_name': seasonName,
        'division_slug': divisionSlug,
        'division_name': divisionName,
        'team_id': teamId,
        'team_name': teamName,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('🗄️ [SQLite] ✅ Added favourite: $type - $id');
  }

  static Future<void> removeFavourite(String id) async {
    final db = await database;
    await db.delete(
      'favourites',
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint('🗄️ [SQLite] ✅ Removed favourite: $id');
  }

  static Future<List<Map<String, dynamic>>> getFavourites() async {
    final db = await database;
    final result = await db.query(
      'favourites',
      orderBy: 'created_at DESC',
    );
    debugPrint('🗄️ [SQLite] 📄 Found ${result.length} favourites');
    return result;
  }

  static Future<bool> isFavourite({
    required String type,
    String? competitionSlug,
    String? seasonSlug,
    String? divisionSlug,
    String? teamId,
  }) async {
    final db = await database;

    String id;
    switch (type) {
      case 'competition':
        id = 'comp_$competitionSlug';
        break;
      case 'season':
        id = 'season_${competitionSlug}_$seasonSlug';
        break;
      case 'division':
        id = 'div_${competitionSlug}_${seasonSlug}_$divisionSlug';
        break;
      case 'team':
        id = 'team_${competitionSlug}_${seasonSlug}_${divisionSlug}_$teamId';
        break;
      default:
        return false;
    }

    final result = await db.query(
      'favourites',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
