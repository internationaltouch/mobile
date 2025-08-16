import '../models/event.dart';
import '../models/division.dart';
import '../models/team.dart';
import '../models/fixture.dart';
import '../models/ladder_entry.dart';
import '../models/news_item.dart';
import 'api_service.dart';

class DataService {
  // Cache for API data
  static List<Event>? _cachedEvents;
  static Map<String, List<Division>> _cachedDivisions = {};
  static Map<String, List<Team>> _cachedTeams = {};
  static Map<String, List<Fixture>> _cachedFixtures = {};
  
  // Static data for news (API doesn't expose news yet)
  static List<NewsItem> getNewsItems() {
    return [
      NewsItem(
        id: '1',
        title: 'Touch World Cup 2024 Announced',
        summary: 'The next Touch World Cup will be held in Australia, featuring teams from over 20 nations.',
        imageUrl: 'https://via.placeholder.com/300x200/1976D2/FFFFFF?text=Touch+World+Cup',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        content: 'Full details about the upcoming Touch World Cup...',
      ),
      NewsItem(
        id: '2',
        title: 'European Touch Championships Update',
        summary: 'Registration is now open for the European Touch Championships with exciting new divisions.',
        imageUrl: 'https://via.placeholder.com/300x200/388E3C/FFFFFF?text=European+Championships',
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      NewsItem(
        id: '3',
        title: 'Asian Touch Cup Results',
        summary: 'Congratulations to all participating teams in the recently concluded Asian Touch Cup.',
        imageUrl: 'https://via.placeholder.com/300x200/F57C00/FFFFFF?text=Asian+Cup',
        publishedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  // Fetch events from API
  static Future<List<Event>> getEvents() async {
    if (_cachedEvents != null) {
      return _cachedEvents!;
    }

    try {
      final apiCompetitions = await ApiService.fetchCompetitions();
      final events = <Event>[];

      for (final competition in apiCompetitions) {
        try {
          // Fetch competition details to get seasons
          final competitionDetails = await ApiService.fetchCompetitionDetails(competition['slug']);
          
          final event = Event(
            id: competition['slug'],
            name: competition['title'],
            logoUrl: 'https://via.placeholder.com/100x100/1976D2/FFFFFF?text=${Uri.encodeComponent(competition['title'].substring(0, 3).toUpperCase())}',
            seasons: (competitionDetails['seasons'] as List)
                .map((season) => season['title'] as String)
                .toList(),
            description: 'International touch tournament',
            slug: competition['slug'],
          );
          events.add(event);
        } catch (e) {
          // Skip competitions that fail to load details
          print('Failed to load details for ${competition['title']}: $e');
        }
      }

      _cachedEvents = events;
      return events;
    } catch (e) {
      print('Failed to fetch events from API: $e');
      // Return fallback mock data if API fails
      return _getMockEvents();
    }
  }

  // Fetch divisions from API
  static Future<List<Division>> getDivisions(String eventId, String season) async {
    final cacheKey = '${eventId}_$season';
    if (_cachedDivisions.containsKey(cacheKey)) {
      return _cachedDivisions[cacheKey]!;
    }

    try {
      final seasonDetails = await ApiService.fetchSeasonDetails(eventId, season);
      final divisions = <Division>[];

      final colors = [
        '#1976D2', '#388E3C', '#F57C00', '#7B1FA2', '#D32F2F', '#303F9F',
        '#00796B', '#FF6F00', '#C2185B', '#5D4037', '#455A64', '#F57F17'
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
      print('Failed to fetch divisions from API: $e');
      // Return fallback mock data if API fails
      return _getMockDivisions(eventId, season);
    }
  }

  // Fetch teams from API
  static Future<List<Team>> getTeams(String divisionId, {String? eventId, String? season}) async {
    if (_cachedTeams.containsKey(divisionId)) {
      return _cachedTeams[divisionId]!;
    }

    if (eventId == null || season == null) {
      // Fallback to mock data if we don't have the required parameters
      return _getMockTeams(divisionId);
    }

    try {
      final divisionDetails = await ApiService.fetchDivisionDetails(eventId, season, divisionId);
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
      print('Failed to fetch teams from API: $e');
      // Return fallback mock data if API fails
      return _getMockTeams(divisionId);
    }
  }

  // Fetch fixtures from API
  static Future<List<Fixture>> getFixtures(String divisionId, {String? eventId, String? season}) async {
    if (_cachedFixtures.containsKey(divisionId)) {
      return _cachedFixtures[divisionId]!;
    }

    if (eventId == null || season == null) {
      // Fallback to mock data if we don't have the required parameters
      return _getMockFixtures(divisionId);
    }

    try {
      final divisionDetails = await ApiService.fetchDivisionDetails(eventId, season, divisionId);
      final fixtures = <Fixture>[];
      final teams = await getTeams(divisionId, eventId: eventId, season: season);
      final teamMap = {for (final team in teams) team.id: team};

      // Process all stages and their matches
      for (final stage in divisionDetails['stages']) {
        for (final match in stage['matches']) {
          if (match['is_bye'] == true) continue; // Skip bye matches

          final homeTeam = teamMap[match['home_team']?.toString()];
          final awayTeam = teamMap[match['away_team']?.toString()];

          final fixture = Fixture(
            id: match['id'].toString(),
            homeTeamId: match['home_team']?.toString() ?? '',
            awayTeamId: match['away_team']?.toString() ?? '',
            homeTeamName: homeTeam?.name ?? 'TBD',
            awayTeamName: awayTeam?.name ?? 'TBD',
            dateTime: match['datetime'] != null 
                ? DateTime.parse(match['datetime'])
                : DateTime.now(),
            field: match['play_at']?['title'] ?? 'Field ${fixtures.length + 1}',
            divisionId: divisionId,
            homeScore: match['home_team_score'],
            awayScore: match['away_team_score'],
            isCompleted: match['home_team_score'] != null && match['away_team_score'] != null,
            round: match['round'],
            isBye: match['is_bye'],
          );
          fixtures.add(fixture);
        }
      }

      _cachedFixtures[divisionId] = fixtures;
      return fixtures;
    } catch (e) {
      print('Failed to fetch fixtures from API: $e');
      // Return fallback mock data if API fails
      return _getMockFixtures(divisionId);
    }
  }

  // Calculate ladder from fixtures (since API doesn't provide ladder directly)
  static Future<List<LadderEntry>> getLadder(String divisionId, {String? eventId, String? season}) async {
    try {
      final fixtures = await getFixtures(divisionId, eventId: eventId, season: season);
      final teams = await getTeams(divisionId, eventId: eventId, season: season);
      
      final ladder = <String, LadderEntry>{};
      
      // Initialize ladder entries
      for (final team in teams) {
        ladder[team.id] = LadderEntry(
          teamId: team.id,
          teamName: team.name,
          played: 0,
          wins: 0,
          draws: 0,
          losses: 0,
          points: 0,
          goalDifference: 0,
          goalsFor: 0,
          goalsAgainst: 0,
        );
      }

      // Calculate stats from completed fixtures
      for (final fixture in fixtures) {
        if (fixture.isCompleted && fixture.homeScore != null && fixture.awayScore != null) {
          final homeEntry = ladder[fixture.homeTeamId];
          final awayEntry = ladder[fixture.awayTeamId];
          
          if (homeEntry != null && awayEntry != null) {
            // Update played count
            ladder[fixture.homeTeamId] = LadderEntry(
              teamId: homeEntry.teamId,
              teamName: homeEntry.teamName,
              played: homeEntry.played + 1,
              wins: homeEntry.wins + (fixture.homeScore! > fixture.awayScore! ? 1 : 0),
              draws: homeEntry.draws + (fixture.homeScore! == fixture.awayScore! ? 1 : 0),
              losses: homeEntry.losses + (fixture.homeScore! < fixture.awayScore! ? 1 : 0),
              points: homeEntry.points + (fixture.homeScore! > fixture.awayScore! ? 3 : (fixture.homeScore! == fixture.awayScore! ? 1 : 0)),
              goalDifference: homeEntry.goalDifference + (fixture.homeScore! - fixture.awayScore!),
              goalsFor: homeEntry.goalsFor + fixture.homeScore!,
              goalsAgainst: homeEntry.goalsAgainst + fixture.awayScore!,
            );

            ladder[fixture.awayTeamId] = LadderEntry(
              teamId: awayEntry.teamId,
              teamName: awayEntry.teamName,
              played: awayEntry.played + 1,
              wins: awayEntry.wins + (fixture.awayScore! > fixture.homeScore! ? 1 : 0),
              draws: awayEntry.draws + (fixture.awayScore! == fixture.homeScore! ? 1 : 0),
              losses: awayEntry.losses + (fixture.awayScore! < fixture.homeScore! ? 1 : 0),
              points: awayEntry.points + (fixture.awayScore! > fixture.homeScore! ? 3 : (fixture.awayScore! == fixture.homeScore! ? 1 : 0)),
              goalDifference: awayEntry.goalDifference + (fixture.awayScore! - fixture.homeScore!),
              goalsFor: awayEntry.goalsFor + fixture.awayScore!,
              goalsAgainst: awayEntry.goalsAgainst + fixture.homeScore!,
            );
          }
        }
      }

      final sortedLadder = ladder.values.toList()
        ..sort((a, b) {
          // Sort by points first, then goal difference
          if (a.points != b.points) {
            return b.points.compareTo(a.points);
          }
          return b.goalDifference.compareTo(a.goalDifference);
        });

      return sortedLadder;
    } catch (e) {
      print('Failed to calculate ladder: $e');
      // Return fallback mock data if calculation fails
      return _getMockLadder(divisionId);
    }
  }

  // Clear cache to force refresh
  static void clearCache() {
    _cachedEvents = null;
    _cachedDivisions.clear();
    _cachedTeams.clear();
    _cachedFixtures.clear();
  }

  // Fallback mock data methods
  static List<Event> _getMockEvents() {
    return [
      Event(
        id: '1',
        name: 'Touch World Cup',
        logoUrl: 'https://via.placeholder.com/100x100/1976D2/FFFFFF?text=TWC',
        seasons: ['2024', '2022', '2020'],
        description: 'The premier international touch tournament',
      ),
      Event(
        id: '2',
        name: 'European Touch Championships',
        logoUrl: 'https://via.placeholder.com/100x100/388E3C/FFFFFF?text=ETC',
        seasons: ['2024', '2023'],
        description: 'European regional championship event',
      ),
    ];
  }

  static List<Division> _getMockDivisions(String eventId, String season) {
    return [
      Division(
        id: '1',
        name: "Men's Open",
        eventId: eventId,
        season: season,
        color: '#1976D2',
      ),
      Division(
        id: '2',
        name: "Women's Open",
        eventId: eventId,
        season: season,
        color: '#388E3C',
      ),
    ];
  }

  static List<Team> _getMockTeams(String divisionId) {
    return [
      Team(id: '1', name: 'ThunderCats', divisionId: divisionId),
      Team(id: '2', name: 'StormBreakers', divisionId: divisionId),
    ];
  }

  static List<Fixture> _getMockFixtures(String divisionId) {
    final baseDate = DateTime.now();
    return [
      Fixture(
        id: '1',
        homeTeamId: '1',
        awayTeamId: '2',
        homeTeamName: 'ThunderCats',
        awayTeamName: 'StormBreakers',
        dateTime: baseDate.add(const Duration(hours: 2)),
        field: 'Field 1',
        divisionId: divisionId,
        homeScore: 12,
        awayScore: 8,
        isCompleted: true,
      ),
    ];
  }

  static List<LadderEntry> _getMockLadder(String divisionId) {
    return [
      LadderEntry(
        teamId: '1',
        teamName: 'ThunderCats',
        played: 1,
        wins: 1,
        draws: 0,
        losses: 0,
        points: 3,
        goalDifference: 4,
        goalsFor: 12,
        goalsAgainst: 8,
      ),
    ];
  }
}