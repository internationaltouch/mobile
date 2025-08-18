import 'dart:convert';
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
  static const int _dbVersion = 4;

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
    // Events table (Competition level)
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
  }

  static Future<void> _upgradeDB(
      Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades when schema changes
    if (oldVersion < 2) {
      // Add api_order column to events table
      await db
          .execute('ALTER TABLE events ADD COLUMN api_order INTEGER DEFAULT 0');
    }

    if (oldVersion < 3) {
      // Remove seasons column from events table and normalize the schema
      // First create a backup of the old events table
      await db.execute('ALTER TABLE events RENAME TO events_old');

      // Create new events table using slug as primary key
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

      // Copy data from old table using slug as primary key
      await db.execute('''
        INSERT INTO events (slug, name, description, logo_url, api_order, created_at, updated_at)
        SELECT COALESCE(slug, id), name, description, logo_url, 
               COALESCE(api_order, 0), created_at, updated_at
        FROM events_old
      ''');

      // Update seasons table structure with composite keys
      await db.execute('DROP TABLE IF EXISTS seasons');
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

      // Update divisions table structure with composite keys
      await db.execute('DROP TABLE IF EXISTS divisions');
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

      // Drop the old events table
      await db.execute('DROP TABLE events_old');

      // Clear cache to force fresh data loading
      await clearAllCache();
    }

    if (oldVersion < 4) {
      // Restructure all tables to use proper slug-based composite keys
      // Drop all tables and recreate with new schema
      await db.execute('DROP TABLE IF EXISTS ladder_entries');
      await db.execute('DROP TABLE IF EXISTS fixtures');
      await db.execute('DROP TABLE IF EXISTS teams');
      await db.execute('DROP TABLE IF EXISTS divisions');
      await db.execute('DROP TABLE IF EXISTS seasons');
      await db.execute('DROP TABLE IF EXISTS events');

      // Recreate all tables with new schema
      await _createDB(db, 4);

      // Clear cache to force fresh data loading
      await clearAllCache();
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

    return maps
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
