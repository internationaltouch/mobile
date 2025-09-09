import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../models/season.dart';
import '../models/division.dart';
import '../models/fixture.dart';
import '../models/ladder_entry.dart';
import '../models/team.dart';
import '../models/club.dart';
import '../models/news_item.dart';
import '../models/favorite.dart';
import '../services/api_service.dart';
import '../services/competition_filter_service.dart';
import '../services/favorites_service.dart';
import '../config/config_service.dart';
import '../config/app_config.dart';

// HTTP Client provider
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

// Raw API providers (no custom caching, just Riverpod's built-in caching)
final rawEventsProvider = FutureProvider<List<Event>>((ref) async {
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
});

// Filtered events (applies competition filtering)
final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final events = await ref.read(rawEventsProvider.future);
  return CompetitionFilterService.filterEvents(events);
});

// Seasons provider for specific event
final seasonsProvider =
    FutureProvider.family<List<Season>, String>((ref, eventSlug) async {
  final competitionDetails =
      await ApiService.fetchCompetitionDetails(eventSlug);
  final seasons = (competitionDetails['seasons'] as List)
      .map((season) => Season.fromJson(season))
      .toList();

  // Apply season filtering would go here if needed
  // For now, return all seasons
  return seasons;
});

// Divisions provider for specific event/season
final divisionsProvider = FutureProvider.family<List<Division>,
    ({String eventId, String seasonSlug})>((ref, params) async {
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

// Fixtures provider for specific division
final fixturesProvider = FutureProvider.family<
    List<Fixture>,
    ({
      String eventId,
      String seasonSlug,
      String divisionId
    })>((ref, params) async {
  final divisionDetails = await ApiService.fetchDivisionDetails(
      params.eventId, params.seasonSlug, params.divisionId);

  final fixtures = <Fixture>[];
  final teams = await ref.read(teamsProvider((
    eventId: params.eventId,
    seasonSlug: params.seasonSlug,
    divisionId: params.divisionId,
  )).future);

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
        divisionId: params.divisionId,
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

  return fixtures;
});

// Ladder provider for specific division
final ladderProvider = FutureProvider.family<
    List<LadderEntry>,
    ({
      String eventId,
      String seasonSlug,
      String divisionId
    })>((ref, params) async {
  final divisionDetails = await ApiService.fetchDivisionDetails(
      params.eventId, params.seasonSlug, params.divisionId);

  final teams = divisionDetails['teams'] as List<dynamic>? ?? [];

  // Process each stage and extract ladder data
  for (final stage in divisionDetails['stages']) {
    if (stage['ladder_summary'] != null &&
        (stage['ladder_summary'] as List).isNotEmpty) {
      final ladder = <LadderEntry>[];
      final ladderData = stage['ladder_summary'] as List;

      for (final entryData in ladderData) {
        final teamData = teams.firstWhere(
          (team) => team['id'] == entryData['team'],
          orElse: () => null,
        );

        if (teamData != null) {
          // Prepare the JSON data for the model's fromJson method
          final jsonData = {
            ...entryData,
            'team_name': teamData['title'] ?? 'Unknown Team',
            'score_for': entryData['points_for'],
            'score_against': entryData['points_against'],
          };

          final entry =
              LadderEntry.fromJson(Map<String, dynamic>.from(jsonData));
          ladder.add(entry);
        }
      }

      // Return the first stage's ladder (most stages have only one)
      return ladder;
    }
  }

  return [];
});

// Clubs provider with configuration-based filtering
final clubsProvider = FutureProvider<List<Club>>((ref) async {
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

// News provider (RSS parsing)
final newsProvider = FutureProvider<List<NewsItem>>((ref) async {
  // This will use Riverpod's caching instead of custom SQLite caching
  // Implementation would move RSS parsing logic here directly
  // For now, we can still call DataService but Riverpod handles caching
  throw UnimplementedError('News provider needs RSS parsing implementation');
});

// Favorites providers
final favoritesProvider = FutureProvider<List<Favorite>>((ref) async {
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
