import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:touchtech_competitions/models/event.dart';
import 'package:touchtech_competitions/models/season.dart';
import 'package:touchtech_competitions/models/division.dart';
import 'package:touchtech_competitions/models/fixture.dart';
import 'package:touchtech_competitions/models/ladder_entry.dart';
import 'package:touchtech_competitions/models/team.dart';
import '../models/clubs/club.dart';
import 'package:touchtech_core/services/api_service.dart';
import 'package:touchtech_competitions/services/competition_filter_service.dart';
import '../models/favorites/favorite.dart';
import '../services/favorites/favorites_service.dart';
// TODO: Re-implement caching with new database service
// import 'package:touchtech_core/services/database_service.dart';
import 'package:touchtech_core/config/config_service.dart';
import 'package:touchtech_core/config/app_config.dart';

// HTTP Client provider
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

// Raw API providers with offline caching support
final rawEventsProvider = FutureProvider<List<Event>>((ref) async {
  // Keep provider alive for offline caching
  ref.keepAlive();

  try {
    final apiCompetitions = await ApiService.fetchCompetitions();
    final events = <Event>[];

    for (final competition in apiCompetitions) {
      try {
        final event = Event(
          id: competition['slug'],
          name: competition['title'],
          logoUrl: AppConfig.getCompetitionLogoUrl(
              competition['title'].substring(0, 3).toUpperCase()),
          seasons: [], // Load on demand
          description: 'International touch tournament',
          slug: competition['slug'],
          seasonsLoaded: false,
        );
        events.add(event);
      } catch (e) {
        // Skip competitions that fail to load
      }
    }

    return events;
  } catch (e) {
    // Check if it's a network error
    if (e.toString().contains('network') ||
        e.toString().contains('connection')) {
      // TODO: Re-implement caching with new database service
      // Try to get cached data if available
      // try {
      //   final cachedEvents = await DatabaseService.getCachedEvents();
      //   if (cachedEvents.isNotEmpty) {
      //     return cachedEvents;
      //   }
      // } catch (_) {
      //   // Cache unavailable or empty
      // }
    }
    // Rethrow the error if no cache available
    rethrow;
  }
});

// Filtered events (applies competition filtering)
final eventsProvider = FutureProvider<List<Event>>((ref) async {
  // Keep provider alive for offline caching
  ref.keepAlive();

  final events = await ref.read(rawEventsProvider.future);
  return CompetitionFilterService.filterEvents(events);
});

// Seasons provider for specific event with offline support
final seasonsProvider =
    FutureProvider.family<List<Season>, String>((ref, eventSlug) async {
  // Keep provider alive for offline caching
  ref.keepAlive();

  try {
    final competitionDetails =
        await ApiService.fetchCompetitionDetails(eventSlug);
    final seasons = (competitionDetails['seasons'] as List)
        .map((season) => Season.fromJson(season))
        .toList();

    // Apply season filtering would go here if needed
    // For now, return all seasons
    return seasons;
  } catch (e) {
    // For now, rethrow - can add caching later if needed
    rethrow;
  }
});

// Divisions provider for specific event/season with offline support
final divisionsProvider = FutureProvider.family<List<Division>,
    ({String eventId, String seasonSlug})>((ref, params) async {
  // Keep provider alive for offline caching
  ref.keepAlive();

  final seasonDetails =
      await ApiService.fetchSeasonDetails(params.eventId, params.seasonSlug);
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
      eventId: params.eventId,
      season: params.seasonSlug,
      color: colors[i % colors.length],
      slug: divisionData['slug'],
    );
    divisions.add(division);
  }

  // Apply filtering
  final events = await ref.read(eventsProvider.future);
  final eventObj = events.firstWhere((e) => e.id == params.eventId);
  return CompetitionFilterService.filterDivisions(
      eventObj, params.seasonSlug, divisions);
});

// Teams provider for specific division
final teamsProvider = FutureProvider.family<
    List<Team>,
    ({
      String eventId,
      String seasonSlug,
      String divisionId
    })>((ref, params) async {
  final divisionDetails = await ApiService.fetchDivisionDetails(
      params.eventId, params.seasonSlug, params.divisionId);

  final teams = <Team>[];
  for (final teamData in divisionDetails['teams']) {
    final team = Team(
      id: teamData['id'].toString(),
      name: teamData['title'],
      divisionId: params.divisionId,
      slug: teamData['slug'],
      abbreviation: teamData['club']?['abbreviation'],
    );
    teams.add(team);
  }

  return teams;
});

// Fixtures provider for specific division with offline support
final fixturesProvider = FutureProvider.family<
    List<Fixture>,
    ({
      String eventId,
      String seasonSlug,
      String divisionId
    })>((ref, params) async {
  // Keep provider alive for offline caching
  ref.keepAlive();
  final divisionDetails = await ApiService.fetchDivisionDetails(
      params.eventId, params.seasonSlug, params.divisionId);

  final fixtures = <Fixture>[];
  final teams = await ref.read(teamsProvider((
    eventId: params.eventId,
    seasonSlug: params.seasonSlug,
    divisionId: params.divisionId,
  )).future);

  final teamMap = {for (final team in teams) team.id: team};

  // Create pools lookup map from API response - pools are nested in stages
  final poolsMap = <int, String>{};
  for (final stage in divisionDetails['stages']) {
    if (stage['pools'] != null) {
      for (final pool in stage['pools'] as List<dynamic>) {
        poolsMap[pool['id'] as int] = pool['title'] as String;
      }
    }
  }

  // Process all stages and their matches
  for (final stage in divisionDetails['stages']) {
    for (final match in stage['matches']) {
      if (match['is_bye'] == true) continue; // Skip bye matches

      final homeTeam = teamMap[match['home_team']?.toString()];
      final awayTeam = teamMap[match['away_team']?.toString()];

      final stageGroupId = match['stage_group'] as int?;
      final poolName = stageGroupId != null ? poolsMap[stageGroupId] : null;
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
        divisionId: params.divisionId,
        homeScore: match['home_team_score'],
        awayScore: match['away_team_score'],
        isCompleted: match['home_team_score'] != null &&
            match['away_team_score'] != null,
        round: match['round'],
        isBye: match['is_bye'],
        videos: (match['videos'] as List<dynamic>?)?.cast<String>() ?? [],
        poolId: stageGroupId,
        poolName: poolName,
      );

      fixtures.add(fixture);
    }
  }

  return fixtures;
});

// Ladder provider for specific division with offline support
final ladderProvider = FutureProvider.family<
    List<LadderEntry>,
    ({
      String eventId,
      String seasonSlug,
      String divisionId
    })>((ref, params) async {
  // Keep provider alive for offline caching
  ref.keepAlive();
  final divisionDetails = await ApiService.fetchDivisionDetails(
      params.eventId, params.seasonSlug, params.divisionId);

  final teams = divisionDetails['teams'] as List<dynamic>? ?? [];

  // Create pools lookup map from API response - pools are nested in stages
  final poolsMap = <int, String>{};
  for (final stage in divisionDetails['stages']) {
    if (stage['pools'] != null) {
      for (final pool in stage['pools'] as List<dynamic>) {
        poolsMap[pool['id'] as int] = pool['title'] as String;
      }
    }
  }

  final allLadderEntries = <LadderEntry>[];

  // Process each stage and extract ladder data
  for (final stage in divisionDetails['stages']) {
    if (stage['ladder_summary'] != null &&
        (stage['ladder_summary'] as List).isNotEmpty) {
      final ladderData = stage['ladder_summary'] as List;

      for (final entryData in ladderData) {
        final teamData = teams.firstWhere(
          (team) => team['id'] == entryData['team'],
          orElse: () => null,
        );

        if (teamData != null) {
          final stageGroupId = entryData['stage_group'] as int?;
          final poolName = stageGroupId != null ? poolsMap[stageGroupId] : null;

          // Prepare the JSON data for the model's fromJson method
          final jsonData = {
            ...entryData,
            'team_name': teamData['title'] ?? 'Unknown Team',
            'score_for': entryData['points_for'],
            'score_against': entryData['points_against'],
            'pool_name': poolName, // Add pool name for grouping
          };

          final entry =
              LadderEntry.fromJson(Map<String, dynamic>.from(jsonData));
          allLadderEntries.add(entry);
        }
      }
    }
  }

  return allLadderEntries;
});

// Clubs provider with configuration-based filtering and offline support
final clubsProvider = FutureProvider<List<Club>>((ref) async {
  // Keep provider alive for offline caching
  ref.keepAlive();

  final clubsData = await ApiService.fetchClubs();
  var clubs = clubsData.map((json) => Club.fromJson(json)).toList();

  // Apply configuration-based filters
  final clubConfig = ConfigService.config.features.clubs;

  // Filter by status
  if (clubConfig.allowedStatuses.isNotEmpty) {
    clubs = clubs.where((club) {
      final status = club.status?.toLowerCase() ?? 'active';
      return clubConfig.allowedStatuses.contains(status);
    }).toList();
  }

  // Filter by slug exclusions
  if (clubConfig.excludedSlugs.isNotEmpty) {
    clubs = clubs.where((club) {
      return !clubConfig.excludedSlugs.contains(club.slug);
    }).toList();
  }

  // Sort alphabetically
  clubs.sort((a, b) => a.title.compareTo(b.title));

  return clubs;
});

// Favorites providers (local storage, works offline)
final favoritesProvider = FutureProvider<List<Favorite>>((ref) async {
  // Keep provider alive - favorites are local and should persist
  ref.keepAlive();

  return await FavoritesService.getFavorites();
});

final favoritesByTypeProvider =
    FutureProvider.family<List<Favorite>, FavoriteType>((ref, type) async {
  return await FavoritesService.getFavoritesByType(type);
});

final isFavoritedProvider =
    FutureProvider.family<bool, String>((ref, favoriteId) async {
  return await FavoritesService.isFavorited(favoriteId);
});

// Favorites mutations (for adding/removing favorites)
final favoritesNotifierProvider =
    NotifierProvider<FavoritesNotifier, AsyncValue<List<Favorite>>>(
  () => FavoritesNotifier(),
);

class FavoritesNotifier extends Notifier<AsyncValue<List<Favorite>>> {
  @override
  AsyncValue<List<Favorite>> build() {
    // Initialize with loading state and load favorites
    _loadFavorites();
    return const AsyncValue.loading();
  }

  Future<void> _loadFavorites() async {
    state = const AsyncValue.loading();
    try {
      final favorites = await FavoritesService.getFavorites();
      state = AsyncValue.data(favorites);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addFavorite(Favorite favorite) async {
    try {
      await FavoritesService.addFavorite(favorite);
      await _loadFavorites();
      // Invalidate related providers
      ref.invalidate(favoritesProvider);
      ref.invalidate(favoritesByTypeProvider);
      ref.invalidate(isFavoritedProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeFavorite(String favoriteId) async {
    try {
      await FavoritesService.removeFavorite(favoriteId);
      await _loadFavorites();
      // Invalidate related providers
      ref.invalidate(favoritesProvider);
      ref.invalidate(favoritesByTypeProvider);
      ref.invalidate(isFavoritedProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> toggleFavorite(Favorite favorite) async {
    try {
      final isNowFavorited = await FavoritesService.toggleFavorite(favorite);
      await _loadFavorites();
      // Invalidate related providers
      ref.invalidate(favoritesProvider);
      ref.invalidate(favoritesByTypeProvider);
      ref.invalidate(isFavoritedProvider);
      return isNowFavorited;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<void> clearFavorites() async {
    try {
      await FavoritesService.clearFavorites();
      await _loadFavorites();
      // Invalidate related providers
      ref.invalidate(favoritesProvider);
      ref.invalidate(favoritesByTypeProvider);
      ref.invalidate(isFavoritedProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
