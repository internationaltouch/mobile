import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../models/event.dart' as models;
import '../models/season.dart' as models;
import '../models/division.dart' as models;
import '../models/team.dart' as models;
import '../models/fixture.dart' as models;
import '../models/news_item.dart' as models;
import '../models/ladder_entry.dart' as models;
import 'database.dart';

class DatabaseService {
  static AppDatabase? _database;
  static AppDatabase? _testDatabase;

  static AppDatabase get database {
    if (_testDatabase != null) {
      debugPrint('🗄️ [Drift] ♾️ Using test database instance');
      return _testDatabase!;
    }

    if (_database != null) {
      debugPrint('🗄️ [Drift] ♾️ Using existing database instance');
      return _database!;
    }
    debugPrint('🗄️ [Drift] 🔧 Initializing database...');
    try {
      _database = AppDatabase();
      debugPrint('🗄️ [Drift] ✅ Database initialized successfully');
      return _database!;
    } catch (e) {
      debugPrint('🗄️ [Drift] ❌ Database initialization failed: $e');
      rethrow;
    }
  }

  // Test helper methods
  static void setTestDatabase(AppDatabase testDb) {
    _testDatabase = testDb;
  }

  static void clearTestDatabase() {
    _testDatabase?.close();
    _testDatabase = null;
  }

  // Cache management
  static Future<bool> isCacheValid(String key, Duration maxAge) async {
    debugPrint('🕰️ [Cache] 🔍 Checking cache validity for key: $key');
    debugPrint('🕰️ [Cache] 📞 Getting database instance...');
    final db = database;
    debugPrint(
        '🕰️ [Cache] ✅ Database instance obtained, querying cache_metadata...');

    final result = await (db.select(db.cacheMetadata)
          ..where((metadata) => metadata.key.equals(key)))
        .getSingleOrNull();

    debugPrint(
        '🕰️ [Cache] 📋 Query completed, found ${result != null ? 1 : 0} results');

    if (result == null) {
      debugPrint('🕰️ [Cache] ❌ No cache metadata found for key: $key');
      return false;
    }

    final lastUpdated = result.lastUpdated;
    final expiryDuration = result.expiryDuration;
    final now = DateTime.now().millisecondsSinceEpoch;
    final ageMs = now - lastUpdated;
    final isValid = ageMs < expiryDuration;

    debugPrint(
        '🕰️ [Cache] 📅 Cache for $key: age=${ageMs}ms, ttl=${expiryDuration}ms, valid=$isValid');
    return isValid;
  }

  static Future<void> updateCacheMetadata(String key, Duration maxAge) async {
    final db = database;
    await db.into(db.cacheMetadata).insertOnConflictUpdate(
          CacheMetadataCompanion.insert(
            key: key,
            lastUpdated: DateTime.now().millisecondsSinceEpoch,
            expiryDuration: maxAge.inMilliseconds,
          ),
        );
  }

  // Events
  static Future<void> cacheEvents(List<models.Event> events) async {
    final db = database;

    await db.transaction(() async {
      for (int i = 0; i < events.length; i++) {
        final event = events[i];

        // Cache the event using slug as primary key
        await db.into(db.events).insertOnConflictUpdate(
              EventsCompanion.insert(
                slug: event.slug ?? event.id,
                name: event.name,
                description: Value(event.description),
                logoUrl: Value(event.logoUrl),
                apiOrder: i,
                createdAt: DateTime.now().millisecondsSinceEpoch,
                updatedAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );

        // Cache the seasons for this event with composite keys
        debugPrint(
            '🗺️ [Drift] 🏆 Caching ${event.seasons.length} seasons for event: ${event.name}');
        for (int j = 0; j < event.seasons.length; j++) {
          final season = event.seasons[j];
          await db.into(db.seasons).insertOnConflictUpdate(
                SeasonsCompanion.insert(
                  competitionSlug: event.slug ?? event.id,
                  seasonSlug: season.slug,
                  title: season.title,
                  apiOrder: j,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                ),
              );
          debugPrint(
              '🗺️ [Drift] 🏆 → Cached season: ${season.title} (${season.slug})');
        }
      }
    });

    await updateCacheMetadata('events', const Duration(hours: 1));
  }

  static Future<List<models.Event>> getCachedEvents() async {
    final db = database;
    final eventRows = await (db.select(db.events)
          ..orderBy([(e) => OrderingTerm(expression: e.apiOrder)]))
        .get();

    final events = <models.Event>[];

    for (final eventRow in eventRows) {
      final competitionSlug = eventRow.slug;

      // Get seasons for this event using competition slug
      final seasonRows = await (db.select(db.seasons)
            ..where((s) => s.competitionSlug.equals(competitionSlug))
            ..orderBy([(s) => OrderingTerm(expression: s.apiOrder)]))
          .get();

      final seasons = seasonRows
          .map((seasonRow) => models.Season(
                title: seasonRow.title,
                slug: seasonRow.seasonSlug,
              ))
          .toList();

      final event = models.Event(
        id: competitionSlug, // Use slug as ID for compatibility
        slug: competitionSlug,
        name: eventRow.name,
        description: eventRow.description ?? '',
        logoUrl: eventRow.logoUrl ?? '',
        seasons: seasons,
      );

      events.add(event);
    }

    return events;
  }

  // Divisions
  static Future<void> cacheDivisions(String competitionSlug, String seasonSlug,
      List<models.Division> divisions) async {
    final db = database;

    await db.transaction(() async {
      // Clear existing divisions for this competition/season
      await (db.delete(db.divisions)
            ..where((d) =>
                d.competitionSlug.equals(competitionSlug) &
                d.seasonSlug.equals(seasonSlug)))
          .go();

      for (int i = 0; i < divisions.length; i++) {
        final division = divisions[i];
        await db.into(db.divisions).insert(
              DivisionsCompanion.insert(
                competitionSlug: competitionSlug,
                seasonSlug: seasonSlug,
                divisionSlug: division.slug ?? division.id,
                name: division.name,
                apiOrder: i,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );
      }
    });

    await updateCacheMetadata('divisions_${competitionSlug}_$seasonSlug',
        const Duration(minutes: 30));
  }

  static Future<List<models.Division>> getCachedDivisions(
      String competitionSlug, String seasonSlug) async {
    final db = database;
    final rows = await (db.select(db.divisions)
          ..where((d) =>
              d.competitionSlug.equals(competitionSlug) &
              d.seasonSlug.equals(seasonSlug))
          ..orderBy([(d) => OrderingTerm(expression: d.apiOrder)]))
        .get();

    return rows
        .map((row) => models.Division(
              id: row.divisionSlug,
              name: row.name,
              eventId: row.competitionSlug,
              season: seasonSlug,
              slug: row.divisionSlug,
            ))
        .toList();
  }

  // Teams
  static Future<void> cacheTeams(String competitionSlug, String seasonSlug,
      String divisionSlug, List<models.Team> teams) async {
    final db = database;

    await db.transaction(() async {
      // Clear existing teams for this division
      await (db.delete(db.teams)
            ..where((t) =>
                t.competitionSlug.equals(competitionSlug) &
                t.seasonSlug.equals(seasonSlug) &
                t.divisionSlug.equals(divisionSlug)))
          .go();

      for (int i = 0; i < teams.length; i++) {
        final team = teams[i];
        await db.into(db.teams).insert(
              TeamsCompanion.insert(
                id: team.id,
                competitionSlug: competitionSlug,
                seasonSlug: seasonSlug,
                divisionSlug: divisionSlug,
                name: team.name,
                abbreviation: Value(team.abbreviation),
                logoUrl: const Value(''), // Team model doesn't have logoUrl
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );
      }
    });

    await updateCacheMetadata(
        'teams_${competitionSlug}_${seasonSlug}_$divisionSlug',
        const Duration(minutes: 30));
  }

  static Future<List<models.Team>> getCachedTeams(
      String competitionSlug, String seasonSlug, String divisionSlug) async {
    final db = database;
    final rows = await (db.select(db.teams)
          ..where((t) =>
              t.competitionSlug.equals(competitionSlug) &
              t.seasonSlug.equals(seasonSlug) &
              t.divisionSlug.equals(divisionSlug))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();

    return rows
        .map((row) => models.Team(
              id: row.id,
              name: row.name,
              divisionId: divisionSlug, // Use division slug for compatibility
              abbreviation: row.abbreviation,
            ))
        .toList();
  }

  // Fixtures
  static Future<void> cacheFixtures(String competitionSlug, String seasonSlug,
      String divisionSlug, List<models.Fixture> fixtures) async {
    final db = database;

    await db.transaction(() async {
      // Clear existing fixtures for this division
      await (db.delete(db.fixtures)
            ..where((f) =>
                f.competitionSlug.equals(competitionSlug) &
                f.seasonSlug.equals(seasonSlug) &
                f.divisionSlug.equals(divisionSlug)))
          .go();

      for (final fixture in fixtures) {
        await db.into(db.fixtures).insert(
              FixturesCompanion.insert(
                id: fixture.id,
                competitionSlug: competitionSlug,
                seasonSlug: seasonSlug,
                divisionSlug: divisionSlug,
                homeTeamId: fixture.homeTeamId,
                awayTeamId: fixture.awayTeamId,
                homeTeamName: fixture.homeTeamName,
                awayTeamName: fixture.awayTeamName,
                homeTeamAbbreviation: Value(fixture.homeTeamAbbreviation),
                awayTeamAbbreviation: Value(fixture.awayTeamAbbreviation),
                dateTimeMs: fixture
                    .dateTime.millisecondsSinceEpoch, // Updated field name
                field: Value(fixture.field),
                homeScore: Value(fixture.homeScore),
                awayScore: Value(fixture.awayScore),
                isCompleted: fixture.isCompleted ? 1 : 0,
                roundInfo: Value(fixture.round),
                isBye: Value(fixture.isBye == true ? 1 : 0),
                videos: Value(jsonEncode(fixture.videos)),
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );
      }
    });

    await updateCacheMetadata(
        'fixtures_${competitionSlug}_${seasonSlug}_$divisionSlug',
        const Duration(minutes: 15));
  }

  static Future<List<models.Fixture>> getCachedFixtures(
      String competitionSlug, String seasonSlug, String divisionSlug) async {
    final db = database;
    final rows = await (db.select(db.fixtures)
          ..where((f) =>
              f.competitionSlug.equals(competitionSlug) &
              f.seasonSlug.equals(seasonSlug) &
              f.divisionSlug.equals(divisionSlug))
          ..orderBy([(f) => OrderingTerm(expression: f.dateTimeMs)]))
        .get(); // Updated field name

    return rows.map((row) {
      final videosJson = row.videos;
      final videos = videosJson != null
          ? (jsonDecode(videosJson) as List).cast<String>()
          : <String>[];

      return models.Fixture(
        id: row.id,
        homeTeamId: row.homeTeamId,
        awayTeamId: row.awayTeamId,
        homeTeamName: row.homeTeamName,
        awayTeamName: row.awayTeamName,
        homeTeamAbbreviation: row.homeTeamAbbreviation,
        awayTeamAbbreviation: row.awayTeamAbbreviation,
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            row.dateTimeMs), // Updated field name
        field: row.field ?? '',
        divisionId: divisionSlug, // Use division slug for compatibility
        homeScore: row.homeScore,
        awayScore: row.awayScore,
        isCompleted: row.isCompleted == 1,
        round: row.roundInfo,
        isBye: row.isBye == 1,
        videos: videos,
      );
    }).toList();
  }

  // News
  static Future<void> cacheNewsItems(List<models.NewsItem> newsItems) async {
    debugPrint(
        '🗺️ [Drift] 💾 Caching ${newsItems.length} news items to database...');
    final db = database;

    await db.transaction(() async {
      // Clear existing news items first to avoid conflicts
      debugPrint('🗺️ [Drift] 🧹 Clearing existing news items...');
      await db.delete(db.newsItems).go();

      for (int i = 0; i < newsItems.length; i++) {
        final newsItem = newsItems[i];
        debugPrint(
            '🗺️ [Drift] 📝 Inserting news item ${i + 1}/${newsItems.length}: ID="${newsItem.id}", Title="${newsItem.title.length > 50 ? '${newsItem.title.substring(0, 50)}...' : newsItem.title}"');

        await db.into(db.newsItems).insert(
              NewsItemsCompanion.insert(
                id: newsItem.id,
                title: newsItem.title,
                summary: newsItem.summary,
                imageUrl: Value(newsItem.imageUrl),
                link: Value(newsItem.link),
                publishedAt: newsItem.publishedAt.millisecondsSinceEpoch,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );
      }
    });

    try {
      debugPrint(
          '🗺️ [Drift] ✅ Successfully inserted ${newsItems.length} news items into database');
      await updateCacheMetadata('news', const Duration(minutes: 30));
      debugPrint('🗺️ [Drift] ✅ Cache metadata updated for news (30min TTL)');
    } catch (e) {
      debugPrint('🗺️ [Drift] ❌ Error caching news items: $e');
      rethrow;
    }
  }

  static Future<List<models.NewsItem>> getCachedNewsItems() async {
    debugPrint('🗺️ [Drift] 🔍 Querying cached news items from database...');
    try {
      final db = database;
      final rows = await (db.select(db.newsItems)
            ..orderBy([
              (n) => OrderingTerm(
                  expression: n.publishedAt, mode: OrderingMode.desc)
            ]))
          .get();

      debugPrint(
          '🗺️ [Drift] 📄 Found ${rows.length} cached news items in database');

      final newsItems = rows
          .map((row) => models.NewsItem(
                id: row.id,
                title: row.title,
                summary: row.summary,
                imageUrl: row.imageUrl ?? '',
                link: row.link,
                publishedAt:
                    DateTime.fromMillisecondsSinceEpoch(row.publishedAt),
              ))
          .toList();

      debugPrint(
          '🗺️ [Drift] ✅ Successfully loaded ${newsItems.length} news items from cache');
      return newsItems;
    } catch (e) {
      debugPrint('🗺️ [Drift] ❌ Error loading cached news items: $e');
      return [];
    }
  }

  // Ladder entries
  static Future<void> cacheLadderEntries(
      String competitionSlug,
      String seasonSlug,
      String divisionSlug,
      List<models.LadderEntry> ladderEntries) async {
    final db = database;

    await db.transaction(() async {
      // Clear existing ladder entries for this division
      await (db.delete(db.ladderEntries)
            ..where((l) =>
                l.competitionSlug.equals(competitionSlug) &
                l.seasonSlug.equals(seasonSlug) &
                l.divisionSlug.equals(divisionSlug)))
          .go();

      for (int i = 0; i < ladderEntries.length; i++) {
        final entry = ladderEntries[i];
        await db.into(db.ladderEntries).insert(
              LadderEntriesCompanion.insert(
                id: '${competitionSlug}_${seasonSlug}_${divisionSlug}_${entry.teamId}',
                competitionSlug: competitionSlug,
                seasonSlug: seasonSlug,
                divisionSlug: divisionSlug,
                teamName: entry.teamName,
                position: i + 1, // Position based on order in list
                played: entry.played,
                won: entry.wins,
                drawn: entry.draws,
                lost: entry.losses,
                pointsFor: entry.goalsFor,
                pointsAgainst: entry.goalsAgainst,
                pointsDifference: entry.goalDifference,
                points: entry.points,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );
      }
    });

    await updateCacheMetadata(
        'ladder_${competitionSlug}_${seasonSlug}_$divisionSlug',
        const Duration(minutes: 15));
  }

  static Future<List<models.LadderEntry>> getCachedLadderEntries(
      String competitionSlug, String seasonSlug, String divisionSlug) async {
    final db = database;
    final rows = await (db.select(db.ladderEntries)
          ..where((l) =>
              l.competitionSlug.equals(competitionSlug) &
              l.seasonSlug.equals(seasonSlug) &
              l.divisionSlug.equals(divisionSlug))
          ..orderBy([(l) => OrderingTerm(expression: l.position)]))
        .get();

    return rows
        .map((row) => models.LadderEntry(
              teamId: row.id,
              teamName: row.teamName,
              played: row.played,
              wins: row.won,
              draws: row.drawn,
              losses: row.lost,
              points: row.points,
              goalDifference: row.pointsDifference,
              goalsFor: row.pointsFor,
              goalsAgainst: row.pointsAgainst,
              percentage: row.pointsAgainst > 0
                  ? (row.pointsFor / row.pointsAgainst * 100)
                  : (row.pointsFor > 0 ? 100.0 : 0.0),
            ))
        .toList();
  }

  // Clear specific cache entry by key
  static Future<void> clearSpecificCache(String cacheKey) async {
    final db = database;
    debugPrint('🗄️ [Drift] 🧤 Clearing specific cache entry: $cacheKey');

    await db.transaction(() async {
      // Remove cache metadata entry
      await (db.delete(db.cacheMetadata)
            ..where((metadata) => metadata.key.equals(cacheKey)))
          .go();

      // Clear associated data based on cache key type
      if (cacheKey.startsWith('fixtures_')) {
        // Parse eventId, seasonSlug, divisionId from key: fixtures_{eventId}_{seasonSlug}_{divisionId}
        final parts = cacheKey.split('_');
        if (parts.length >= 4) {
          final divisionId = parts
              .sublist(3)
              .join('_'); // Handle division IDs with underscores
          await (db.delete(db.fixtures)
                ..where((fixture) => fixture.divisionSlug.equals(divisionId)))
              .go();

          debugPrint(
              '🗄️ [Drift] ✅ Cleared fixtures cache for division: $divisionId');
        }
      }
      // Add more cache types as needed (teams, ladder, etc.)
    });
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    final db = database;
    await _clearAllCacheWithDb(db);
  }

  // Helper method to clear cache with existing database instance
  static Future<void> _clearAllCacheWithDb(AppDatabase db) async {
    debugPrint('🗄️ [Drift] 🧤 Clearing all cache data...');
    await db.transaction(() async {
      await db.delete(db.cacheMetadata).go();
      await db.delete(db.events).go();
      await db.delete(db.seasons).go();
      await db.delete(db.divisions).go();
      await db.delete(db.teams).go();
      await db.delete(db.fixtures).go();
      await db.delete(db.ladderEntries).go();
      await db.delete(db.newsItems).go();
    });
    debugPrint('🗄️ [Drift] ✅ All cache data cleared');
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
    final db = database;

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

    await db.into(db.favourites).insertOnConflictUpdate(
          FavouritesCompanion.insert(
            id: id,
            type: type,
            competitionSlug: Value(competitionSlug),
            competitionName: Value(competitionName),
            seasonSlug: Value(seasonSlug),
            seasonName: Value(seasonName),
            divisionSlug: Value(divisionSlug),
            divisionName: Value(divisionName),
            teamId: Value(teamId),
            teamName: Value(teamName),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );

    debugPrint('🗄️ [Drift] ✅ Added favourite: $type - $id');
  }

  static Future<void> removeFavourite(String id) async {
    final db = database;
    await (db.delete(db.favourites)..where((f) => f.id.equals(id))).go();
    debugPrint('🗄️ [Drift] ✅ Removed favourite: $id');
  }

  static Future<List<Map<String, dynamic>>> getFavourites() async {
    final db = database;
    final rows = await (db.select(db.favourites)
          ..orderBy([
            (f) =>
                OrderingTerm(expression: f.createdAt, mode: OrderingMode.desc)
          ]))
        .get();

    final result = rows
        .map((row) => {
              'id': row.id,
              'type': row.type,
              'competition_slug': row.competitionSlug,
              'competition_name': row.competitionName,
              'season_slug': row.seasonSlug,
              'season_name': row.seasonName,
              'division_slug': row.divisionSlug,
              'division_name': row.divisionName,
              'team_id': row.teamId,
              'team_name': row.teamName,
              'created_at': row.createdAt,
            })
        .toList();

    debugPrint('🗄️ [Drift] 📄 Found ${result.length} favourites');
    return result;
  }

  static Future<bool> isFavourite({
    required String type,
    String? competitionSlug,
    String? seasonSlug,
    String? divisionSlug,
    String? teamId,
  }) async {
    final db = database;

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

    final result = await (db.select(db.favourites)
          ..where((f) => f.id.equals(id))
          ..limit(1))
        .getSingleOrNull();

    return result != null;
  }

  // Close database
  static Future<void> close() async {
    if (_testDatabase != null) {
      await _testDatabase!.close();
      _testDatabase = null;
    }
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
