import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../models/event.dart';
import '../models/season.dart';
import '../models/division.dart';
import '../models/team.dart';
import '../models/fixture.dart';
import '../models/ladder_entry.dart';
import '../models/ladder_stage.dart';
import '../config/app_config.dart';
import 'api_service.dart';
import 'database_service.dart';
import 'device_service.dart';

class DataService {
  // Cache for API data
  static List<Event>? _cachedEvents;
  static final Map<String, List<Division>> _cachedDivisions = {};
  static final Map<String, List<Team>> _cachedTeams = {};
  static final Map<String, List<Fixture>> _cachedFixtures = {};

  // HTTP client for dependency injection in tests
  static http.Client? _httpClient;
  static http.Client get httpClient => _httpClient ?? http.Client();

  // Method to set HTTP client for testing
  static void setHttpClient(http.Client client) {
    _httpClient = client;
  }

  // Method to reset HTTP client (for tests)
  static void resetHttpClient() {
    _httpClient = null;
  }

  // Test network connectivity
  static Future<bool> testConnectivity() async {
    try {
      final response = await httpClient.get(
        Uri.parse('https://www.google.com'),
        headers: {'User-Agent': 'FIT-Mobile-App/1.0'},
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Fetch events from API
  static Future<List<Event>> getEvents() async {
    // Check if cache is valid
    if (await DatabaseService.isCacheValid(
        'events', const Duration(hours: 1))) {
      final cachedEvents = await DatabaseService.getCachedEvents();
      if (cachedEvents.isNotEmpty) {
        _cachedEvents = cachedEvents;
        return cachedEvents;
      }
    }

    try {
      final apiCompetitions = await ApiService.fetchCompetitions();
      final events = <Event>[];

      for (final competition in apiCompetitions) {
        try {
          // Create event without seasons for fast UI loading
          final event = Event(
            id: competition['slug'],
            name: competition['title'],
            logoUrl: AppConfig.getCompetitionLogoUrl(
                competition['title'].substring(0, 3).toUpperCase()),
            seasons: [], // Empty initially for fast loading
            description: 'International touch tournament',
            slug: competition['slug'],
            seasonsLoaded: false, // Mark as not loaded
          );
          events.add(event);
        } catch (e) {
          // Skip competitions that fail to load details
          debugPrint(
              '🏆 [Events] ⚠️ Failed to add competition ${competition['title']}: $e');
        }
      }

      // Cache the events first (without seasons) for fast UI
      final ttl = await DeviceService.instance.recommendedCacheExpiry;
      await DatabaseService.cacheEvents(events, ttlMs: ttl);
      _cachedEvents = events;

      // Load seasons in background without blocking UI
      debugPrint('🏆 [Events] 🔄 Starting background seasons loading...');
      _loadSeasonsInBackground(apiCompetitions);

      return events;
    } catch (e) {
      debugPrint('Failed to fetch events from API: $e');

      // Try to return cached data as fallback
      final cachedEvents = await DatabaseService.getCachedEvents();
      if (cachedEvents.isNotEmpty) {
        _cachedEvents = cachedEvents;
        return cachedEvents;
      }

      rethrow;
    }
  }

  // Load seasons and divisions for all competitions in background using breadth-first strategy
  static void _loadSeasonsInBackground(List<dynamic> apiCompetitions) {
    // Run in background without awaiting
    () async {
      debugPrint(
          '🏆 [Events] 🔄 Background: Starting breadth-first loading for ${apiCompetitions.length} competitions...');

      // PHASE 1: Load all seasons for all competitions (breadth-first)
      debugPrint(
          '🏆 [Events] 🔄 Background: Phase 1 - Loading seasons for all competitions...');
      final updatedEvents = <Event>[];
      final allSeasonData = <Map<String, dynamic>>[];

      for (final competition in apiCompetitions) {
        try {
          debugPrint(
              '🏆 [Events] 🔄 Background: Loading seasons for ${competition['title']}');
          final competitionDetails =
              await ApiService.fetchCompetitionDetails(competition['slug']);
          final seasons = (competitionDetails['seasons'] as List)
              .map((season) => Season.fromJson(season))
              .toList();

          final event = Event(
            id: competition['slug'],
            name: competition['title'],
            logoUrl: AppConfig.getCompetitionLogoUrl(
                competition['title'].substring(0, 3).toUpperCase()),
            seasons: seasons,
            description: 'International touch tournament',
            slug: competition['slug'],
            seasonsLoaded: true,
          );

          updatedEvents.add(event);
          debugPrint(
              '🏆 [Events] ✅ Background: Loaded ${seasons.length} seasons for ${competition['title']}');

          // Store season data for phase 2
          for (final season in seasons) {
            allSeasonData.add({
              'competitionSlug': competition['slug'],
              'competitionTitle': competition['title'],
              'season': season,
            });
          }
        } catch (e) {
          debugPrint(
              '🏆 [Events] ⚠️ Background: Failed to load seasons for ${competition['title']}: $e');
        }
      }

      // Cache events with seasons after phase 1
      if (updatedEvents.isNotEmpty) {
        debugPrint(
            '🏆 [Events] 💾 Background: Phase 1 complete - Caching ${updatedEvents.length} events with seasons...');
        final ttl = await DeviceService.instance.recommendedCacheExpiry;
        await DatabaseService.cacheEvents(updatedEvents, ttlMs: ttl);
        _cachedEvents = updatedEvents; // Update in-memory cache
        debugPrint(
            '🏆 [Events] ✅ Background: Phase 1 complete - All seasons cached successfully');
      }

      // PHASE 2: Load divisions for all seasons across all competitions
      if (allSeasonData.isNotEmpty) {
        debugPrint(
            '🏆 [Events] 🔄 Background: Phase 2 - Loading divisions for ${allSeasonData.length} seasons across all competitions...');
        await _loadAllDivisionsBreadthFirst(allSeasonData);
      }

      debugPrint('🏆 [Events] ✅ Background: Breadth-first loading complete!');
    }();
  }

  // Load divisions for all seasons across all competitions (breadth-first approach)
  static Future<void> _loadAllDivisionsBreadthFirst(
      List<Map<String, dynamic>> allSeasonData) async {
    debugPrint(
        '🏆 [Divisions] 📊 Background: Starting division loading for ${allSeasonData.length} seasons');
    int completed = 0;
    int totalDivisionsCached = 0;

    for (final seasonData in allSeasonData) {
      try {
        final competitionSlug = seasonData['competitionSlug'] as String;
        final competitionTitle = seasonData['competitionTitle'] as String;
        final season = seasonData['season'] as Season;

        completed++;
        debugPrint(
            '🏆 [Divisions] 🔄 Background: [$completed/${allSeasonData.length}] Loading divisions for $competitionTitle/${season.title}');

        final seasonDetails =
            await ApiService.fetchSeasonDetails(competitionSlug, season.slug);
        final divisions = <Division>[];

        final colors = [
          '#1976D2',
          '#388E3C',
          '#F57C00',
          '#7B1FA2',
          '#D32F2F',
          '#303F9F',
          '#00796B',
          '#FF6F00',
          '#C2185B',
          '#5D4037',
          '#455A64',
          '#F57F17'
        ];

        for (int i = 0; i < (seasonDetails['divisions'] as List).length; i++) {
          final divisionData = seasonDetails['divisions'][i];
          final division = Division(
            id: divisionData['slug'],
            name: divisionData['title'],
            eventId: competitionSlug,
            season: season.slug,
            color: colors[i % colors.length],
            slug: divisionData['slug'],
          );
          divisions.add(division);
        }

        // Cache divisions for this competition/season
        final ttl = await DeviceService.instance.recommendedCacheExpiry;
        await DatabaseService.cacheDivisions(
            competitionSlug, season.slug, divisions,
            ttlMs: ttl);
        totalDivisionsCached += divisions.length;
        debugPrint(
            '🏆 [Divisions] ✅ Background: [$completed/${allSeasonData.length}] Cached ${divisions.length} divisions for $competitionTitle/${season.title}');
      } catch (e) {
        final competitionTitle = seasonData['competitionTitle'] as String;
        final season = seasonData['season'] as Season;
        debugPrint(
            '🏆 [Divisions] ⚠️ Background: [$completed/${allSeasonData.length}] Failed to load divisions for $competitionTitle/${season.title}: $e');
      }
    }

    debugPrint(
        '🏆 [Divisions] 🎉 Background: Division loading complete! Cached $totalDivisionsCached divisions across ${allSeasonData.length} seasons');
  }

  // Load seasons for a specific event (lazy loading)
  static Future<Event> loadEventSeasons(Event event) async {
    if (event.seasonsLoaded || event.slug == null) {
      return event; // Already loaded or no slug available
    }

    try {
      final competitionDetails =
          await ApiService.fetchCompetitionDetails(event.slug!);
      final seasons = (competitionDetails['seasons'] as List)
          .map((season) => Season.fromJson(season))
          .toList();

      final updatedEvent = event.copyWith(
        seasons: seasons,
        seasonsLoaded: true,
      );

      // Update cache
      if (_cachedEvents != null) {
        final index = _cachedEvents!.indexWhere((e) => e.id == event.id);
        if (index != -1) {
          _cachedEvents![index] = updatedEvent;
        }
      }

      return updatedEvent;
    } catch (e) {
      debugPrint('Failed to load seasons for ${event.name}: $e');
      return event; // Return original event if loading fails
    }
  }

  // Helper method to find season slug from season title/string
  static String _findSeasonSlug(String eventId, String seasonTitle) {
    if (_cachedEvents != null) {
      final event = _cachedEvents!.firstWhere(
        (e) => e.id == eventId || e.slug == eventId,
        orElse: () =>
            Event(id: '', name: '', logoUrl: '', seasons: [], description: ''),
      );

      if (event.seasons.isNotEmpty) {
        // Try to find season by title first
        final season =
            event.seasons.where((s) => s.title == seasonTitle).firstOrNull;
        if (season != null) {
          return season.slug;
        }

        // If not found by title, try to find by slug (for backwards compatibility)
        final seasonBySlug =
            event.seasons.where((s) => s.slug == seasonTitle).firstOrNull;
        if (seasonBySlug != null) {
          return seasonBySlug.slug;
        }
      }
    }

    // Fallback: assume the season string is already a slug
    return seasonTitle;
  }

  // Fetch divisions from API
  static Future<List<Division>> getDivisions(
      String eventId, String season) async {
    final cacheKey = '${eventId}_$season';

    // Check in-memory cache first
    if (_cachedDivisions.containsKey(cacheKey)) {
      debugPrint(
          '🏆 [Divisions] ♾️ Using in-memory cache for $eventId/$season');
      return _cachedDivisions[cacheKey]!;
    }

    // Check database cache
    final seasonSlug = _findSeasonSlug(eventId, season);
    final cachedDivisions =
        await DatabaseService.getCachedDivisions(eventId, seasonSlug);
    if (cachedDivisions.isNotEmpty) {
      debugPrint(
          '🏆 [Divisions] ✅ Loaded ${cachedDivisions.length} divisions from SQLite cache for $eventId/$season');
      _cachedDivisions[cacheKey] = cachedDivisions;
      return cachedDivisions;
    }

    debugPrint(
        '🏆 [Divisions] 🌐 No cache found, fetching from API for $eventId/$season');

    try {
      // Find the correct season slug
      final seasonSlug = _findSeasonSlug(eventId, season);
      final seasonDetails =
          await ApiService.fetchSeasonDetails(eventId, seasonSlug);
      final divisions = <Division>[];

      final colors = [
        '#1976D2',
        '#388E3C',
        '#F57C00',
        '#7B1FA2',
        '#D32F2F',
        '#303F9F',
        '#00796B',
        '#FF6F00',
        '#C2185B',
        '#5D4037',
        '#455A64',
        '#F57F17'
      ];

      for (int i = 0; i < (seasonDetails['divisions'] as List).length; i++) {
        final divisionData = seasonDetails['divisions'][i];
        final division = Division(
          id: divisionData['slug'],
          name: divisionData['title'],
          eventId: eventId,
          season: season,
          color: colors[i % colors.length],
          slug: divisionData['slug'],
        );
        divisions.add(division);
      }

      _cachedDivisions[cacheKey] = divisions;
      return divisions;
    } catch (e) {
      debugPrint('Failed to fetch divisions from API: $e');
      rethrow;
    }
  }

  // Fetch teams from API
  static Future<List<Team>> getTeams(String divisionId,
      {String? eventId, String? season}) async {
    if (_cachedTeams.containsKey(divisionId)) {
      return _cachedTeams[divisionId]!;
    }

    if (eventId == null || season == null) {
      throw Exception(
          'eventId and season are required to fetch teams from API');
    }

    try {
      final seasonSlug = _findSeasonSlug(eventId, season);
      final divisionDetails = await ApiService.fetchDivisionDetails(
          eventId, seasonSlug, divisionId);
      final teams = <Team>[];

      for (final teamData in divisionDetails['teams']) {
        final team = Team(
          id: teamData['id'].toString(),
          name: teamData['title'],
          divisionId: divisionId,
          slug: teamData['slug'],
          abbreviation: teamData['club']?['abbreviation'],
        );
        teams.add(team);
      }

      _cachedTeams[divisionId] = teams;
      return teams;
    } catch (e) {
      debugPrint('Failed to fetch teams from API: $e');
      rethrow;
    }
  }

  // Fetch fixtures from API
  static Future<List<Fixture>> getFixtures(String divisionId,
      {String? eventId, String? season}) async {
    if (eventId == null || season == null) {
      throw Exception(
          'eventId and season are required to fetch fixtures from API');
    }

    final seasonSlug = _findSeasonSlug(eventId, season);
    final cacheKey = 'fixtures_${eventId}_${seasonSlug}_$divisionId';

    // Check if cache is valid (fixtures update frequently, so shorter cache)
    if (await DatabaseService.isCacheValid(
        cacheKey, const Duration(minutes: 15))) {
      final cachedFixtures = await DatabaseService.getCachedFixtures(
          eventId, seasonSlug, divisionId);
      if (cachedFixtures.isNotEmpty) {
        _cachedFixtures[divisionId] = cachedFixtures;
        return cachedFixtures;
      }
    }

    try {
      final divisionDetails = await ApiService.fetchDivisionDetails(
          eventId, seasonSlug, divisionId);
      final fixtures = <Fixture>[];
      final teams =
          await getTeams(divisionId, eventId: eventId, season: season);
      final teamMap = {for (final team in teams) team.id: team};

      // Process all stages and their matches
      for (final stage in divisionDetails['stages']) {
        for (final match in stage['matches']) {
          if (match['is_bye'] == true) continue; // Skip bye matches

          final homeTeam = teamMap[match['home_team']?.toString()];
          final awayTeam = teamMap[match['away_team']?.toString()];

          final fixture = Fixture(
            id: match['id'].toString(),
            homeTeamId: homeTeam?.id ?? match['home_team']?.toString() ?? '',
            awayTeamId: awayTeam?.id ?? match['away_team']?.toString() ?? '',
            homeTeamName: homeTeam?.name ?? 'TBD',
            awayTeamName: awayTeam?.name ?? 'TBD',
            homeTeamAbbreviation: homeTeam?.abbreviation,
            awayTeamAbbreviation: awayTeam?.abbreviation,
            dateTime: match['datetime'] != null
                ? DateTime.parse(match['datetime'])
                : DateTime.now(),
            field: match['play_at']?['title'] ?? 'Field ${fixtures.length + 1}',
            divisionId: divisionId,
            homeScore: match['home_team_score'],
            awayScore: match['away_team_score'],
            isCompleted: match['home_team_score'] != null &&
                match['away_team_score'] != null,
            round: match['round'],
            isBye: match['is_bye'],
            videos: (match['videos'] as List<dynamic>?)?.cast<String>() ?? [],
            poolId: match['stage_group'] as int?,
          );

          fixtures.add(fixture);
        }
      }

      // Cache the fixtures in database with new schema
      final ttl = await DeviceService.instance.recommendedCacheExpiry;
      await DatabaseService.cacheFixtures(
          eventId, seasonSlug, divisionId, fixtures,
          ttlMs: ttl);
      _cachedFixtures[divisionId] = fixtures;
      return fixtures;
    } catch (e) {
      debugPrint('Failed to fetch fixtures from API: $e');

      // Try to return cached data as fallback
      final cachedFixtures = await DatabaseService.getCachedFixtures(
          eventId, seasonSlug, divisionId);
      if (cachedFixtures.isNotEmpty) {
        _cachedFixtures[divisionId] = cachedFixtures;
        return cachedFixtures;
      }

      rethrow;
    }
  }

  // Get ladder stages from API
  static Future<List<LadderStage>> getLadderStages(String divisionId,
      {String? eventId, String? season}) async {
    if (eventId == null || season == null) {
      throw Exception(
          'eventId and season are required to fetch ladder from API');
    }

    try {
      final seasonSlug = _findSeasonSlug(eventId, season);
      final divisionDetails = await ApiService.fetchDivisionDetails(
          eventId, seasonSlug, divisionId);

      final stages = <LadderStage>[];
      final teams = divisionDetails['teams'] as List<dynamic>? ?? [];

      // Process each stage and extract ladder data
      for (final stage in divisionDetails['stages']) {
        if (stage['ladder_summary'] != null &&
            (stage['ladder_summary'] as List).isNotEmpty) {
          final ladderStage = LadderStage.fromJson(stage, teams: teams);
          stages.add(ladderStage);
        }
      }

      return stages;
    } catch (e) {
      debugPrint('Failed to fetch ladder from API: $e');
      rethrow;
    }
  }

  // Get ladder data from API (backward compatibility - returns first stage's ladder)
  static Future<List<LadderEntry>> getLadder(String divisionId,
      {String? eventId, String? season}) async {
    try {
      final ladderStages =
          await getLadderStages(divisionId, eventId: eventId, season: season);

      // Return the first stage's ladder for backward compatibility
      if (ladderStages.isNotEmpty) {
        return ladderStages.first.ladder;
      }

      // If no ladder data from API, return empty list
      return [];
    } catch (e) {
      debugPrint('Failed to fetch ladder: $e');
      rethrow;
    }
  }

  // Clear cache to force refresh
  static void clearCache() {
    _cachedEvents = null;
    _cachedDivisions.clear();
    _cachedTeams.clear();
    _cachedFixtures.clear();
  }

  // Clear cache for a specific division (selective clearing)
  static Future<void> clearDivisionCache(String divisionId,
      {String? eventId, String? season}) async {
    // Clear in-memory cache for this division
    _cachedTeams.remove(divisionId);
    _cachedFixtures.remove(divisionId);

    // Clear database cache for this division's fixtures if we have the event/season info
    if (eventId != null && season != null) {
      final seasonSlug = _findSeasonSlug(eventId, season);
      final fixturesCacheKey = 'fixtures_${eventId}_${seasonSlug}_$divisionId';

      // Clear specific cache entries from database
      await DatabaseService.clearSpecificCache(fixturesCacheKey);

      debugPrint('🗄️ [Cache] 🧤 Cleared cache for division $divisionId');
    }
  }

  // Clear database cache (for testing or cache invalidation)
  static Future<void> clearDatabaseCache() async {
    await DatabaseService.clearAllCache();
    clearCache(); // Also clear in-memory cache
  }
}
