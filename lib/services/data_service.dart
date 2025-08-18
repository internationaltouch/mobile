import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:html/parser.dart' as html_parser;
import 'dart:async';
import '../models/event.dart';
import '../models/season.dart';
import '../models/division.dart';
import '../models/team.dart';
import '../models/fixture.dart';
import '../models/ladder_entry.dart';
import '../models/news_item.dart';
import '../config/app_config.dart';
import 'api_service.dart';

class DataService {
  // Cache for API data
  static List<Event>? _cachedEvents;
  static List<NewsItem>? _cachedNews;
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

  // Helper method to extract Open Graph image from HTML page
  static Future<String?> _extractOpenGraphImage(String url) async {
    try {
      final response = await httpClient.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final html = response.body;

        // Look for og:image meta tag using regex
        final ogImageMatch = RegExp(
          r'<meta\s+property="og:image"\s+content="([^"]+)"',
          caseSensitive: false,
        ).firstMatch(html);

        if (ogImageMatch != null) {
          return ogImageMatch.group(1);
        }

        // Fallback: look for meta name="og:image"
        final ogImageNameMatch = RegExp(
          r'<meta\s+name="og:image"\s+content="([^"]+)"',
          caseSensitive: false,
        ).firstMatch(html);

        if (ogImageNameMatch != null) {
          return ogImageNameMatch.group(1);
        }

        // Additional fallback: try different attribute order
        final ogImageFlexMatch = RegExp(
          r'<meta\s+content="([^"]+)"\s+property="og:image"',
          caseSensitive: false,
        ).firstMatch(html);

        if (ogImageFlexMatch != null) {
          return ogImageFlexMatch.group(1);
        }
      }
    } catch (e) {
      debugPrint('Failed to extract Open Graph image from $url: $e');
    }

    return null;
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

  // Update a news item's image URL asynchronously
  static Future<void> updateNewsItemImage(NewsItem newsItem) async {
    if (newsItem.link == null) return;

    final imageUrl = await _extractOpenGraphImage(newsItem.link!);
    if (imageUrl != null) {
      newsItem.imageUrl = imageUrl;
    }
  }

  // Fetch news from RSS feed
  static Future<List<NewsItem>> getNewsItems() async {
    if (_cachedNews != null) {
      return _cachedNews!;
    }

    try {
      const rssUrl = 'https://www.internationaltouch.org/news/feeds/rss/';

      // Add timeout and headers for better Android compatibility
      final response = await httpClient.get(
        Uri.parse(rssUrl),
        headers: {
          'User-Agent': 'FIT-Mobile-App/1.0',
          'Accept': 'application/rss+xml, application/xml, text/xml',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        final newsItems = <NewsItem>[];

        for (final item in items) {
          final title = item.findElements('title').first.innerText;
          final link = item.findElements('link').first.innerText;
          final description = item.findElements('description').first.innerText;
          final pubDateText = item.findElements('pubDate').first.innerText;

          // Extract content:encoded if available
          String? fullContent;
          try {
            // Try to find content:encoded element
            final contentEncodedElements = item.findAllElements('*').where(
                (element) =>
                    element.name.local == 'encoded' &&
                    (element.name.namespaceUri?.contains('content') == true ||
                        element.name.prefix == 'content'));

            if (contentEncodedElements.isNotEmpty) {
              fullContent = contentEncodedElements.first.innerText;
            } else {
              // Fallback: try to find content element with type="html"
              final contentElement = item
                  .findElements('content')
                  .where((e) => e.getAttribute('type') == 'html')
                  .firstOrNull;
              if (contentElement != null) {
                fullContent = contentElement.innerText;
              }
            }
          } catch (e) {
            debugPrint('Failed to extract content:encoded: $e');
          }

          // Parse RSS date format (e.g., "Mon, 01 Jan 2024 12:00:00 +0000")
          DateTime publishedAt;
          try {
            publishedAt = DateTime.parse(pubDateText
                .replaceAll(RegExp(r'[A-Za-z]{3}, '), '')
                .replaceAll(RegExp(r' \+\d{4}'), ''));
          } catch (e) {
            publishedAt = DateTime.now();
          }

          // Clean HTML from description for summary
          final cleanDescription = description
              .replaceAll(RegExp(r'<[^>]*>'), '')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();

          // Decode HTML entities from full content if available
          String? decodedContent;
          if (fullContent != null) {
            try {
              final document = html_parser.parse(fullContent);
              decodedContent =
                  document.documentElement?.innerHtml ?? fullContent;
            } catch (e) {
              decodedContent = fullContent;
            }
          }

          // Create news item with placeholder image initially
          final newsItem = NewsItem(
            id: link.split('/').last.replaceAll('.html', ''),
            title: title,
            summary: cleanDescription.length > 150
                ? '${cleanDescription.substring(0, 150)}...'
                : cleanDescription,
            imageUrl: AppConfig.getPlaceholderImageUrl(
              width: 300,
              height: 200,
              backgroundColor: '1976D2',
              textColor: 'FFFFFF',
              text: 'News',
            ),
            publishedAt: publishedAt,
            content: decodedContent ?? cleanDescription,
            link: link,
          );

          newsItems.add(newsItem);
        }

        _cachedNews = newsItems;
        return newsItems;
      } else {
        throw Exception('Failed to load RSS feed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to fetch news from RSS: $e');
      rethrow;
    }
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
          // Create event without seasons for fast loading
          final event = Event(
            id: competition['slug'],
            name: competition['title'],
            logoUrl: AppConfig.getCompetitionLogoUrl(
                competition['title'].substring(0, 3).toUpperCase()),
            seasons: [], // Empty initially - will be loaded when needed
            description: 'International touch tournament',
            slug: competition['slug'],
            seasonsLoaded: false, // Mark as not loaded
          );
          events.add(event);
        } catch (e) {
          // Skip competitions that fail to load details
          debugPrint('Failed to add competition ${competition['title']}: $e');
        }
      }

      _cachedEvents = events;
      return events;
    } catch (e) {
      debugPrint('Failed to fetch events from API: $e');
      rethrow;
    }
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
    if (_cachedDivisions.containsKey(cacheKey)) {
      return _cachedDivisions[cacheKey]!;
    }

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
    if (_cachedFixtures.containsKey(divisionId)) {
      return _cachedFixtures[divisionId]!;
    }

    if (eventId == null || season == null) {
      throw Exception(
          'eventId and season are required to fetch fixtures from API');
    }

    try {
      final seasonSlug = _findSeasonSlug(eventId, season);
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
            homeTeamId: match['home_team']?.toString() ?? '',
            awayTeamId: match['away_team']?.toString() ?? '',
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
          );
          
          // Debug: Print video information when videos are found
          if ((match['videos'] as List<dynamic>?)?.isNotEmpty == true) {
            debugPrint('Found videos for match ${match['id']}: ${match['videos']}');
          }
          fixtures.add(fixture);
        }
      }

      _cachedFixtures[divisionId] = fixtures;
      return fixtures;
    } catch (e) {
      debugPrint('Failed to fetch fixtures from API: $e');
      rethrow;
    }
  }

  // Calculate ladder from fixtures (since API doesn't provide ladder directly)
  static Future<List<LadderEntry>> getLadder(String divisionId,
      {String? eventId, String? season}) async {
    try {
      final fixtures =
          await getFixtures(divisionId, eventId: eventId, season: season);
      final teams =
          await getTeams(divisionId, eventId: eventId, season: season);

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
        if (fixture.isCompleted &&
            fixture.homeScore != null &&
            fixture.awayScore != null) {
          final homeEntry = ladder[fixture.homeTeamId];
          final awayEntry = ladder[fixture.awayTeamId];

          if (homeEntry != null && awayEntry != null) {
            // Update played count
            ladder[fixture.homeTeamId] = LadderEntry(
              teamId: homeEntry.teamId,
              teamName: homeEntry.teamName,
              played: homeEntry.played + 1,
              wins: homeEntry.wins +
                  (fixture.homeScore! > fixture.awayScore! ? 1 : 0),
              draws: homeEntry.draws +
                  (fixture.homeScore! == fixture.awayScore! ? 1 : 0),
              losses: homeEntry.losses +
                  (fixture.homeScore! < fixture.awayScore! ? 1 : 0),
              points: homeEntry.points +
                  (fixture.homeScore! > fixture.awayScore!
                      ? 3
                      : (fixture.homeScore! == fixture.awayScore! ? 1 : 0)),
              goalDifference: homeEntry.goalDifference +
                  (fixture.homeScore! - fixture.awayScore!),
              goalsFor: homeEntry.goalsFor + fixture.homeScore!,
              goalsAgainst: homeEntry.goalsAgainst + fixture.awayScore!,
            );

            ladder[fixture.awayTeamId] = LadderEntry(
              teamId: awayEntry.teamId,
              teamName: awayEntry.teamName,
              played: awayEntry.played + 1,
              wins: awayEntry.wins +
                  (fixture.awayScore! > fixture.homeScore! ? 1 : 0),
              draws: awayEntry.draws +
                  (fixture.awayScore! == fixture.homeScore! ? 1 : 0),
              losses: awayEntry.losses +
                  (fixture.awayScore! < fixture.homeScore! ? 1 : 0),
              points: awayEntry.points +
                  (fixture.awayScore! > fixture.homeScore!
                      ? 3
                      : (fixture.awayScore! == fixture.homeScore! ? 1 : 0)),
              goalDifference: awayEntry.goalDifference +
                  (fixture.awayScore! - fixture.homeScore!),
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
      debugPrint('Failed to calculate ladder: $e');
      rethrow;
    }
  }

  // Clear cache to force refresh
  static void clearCache() {
    _cachedEvents = null;
    _cachedNews = null;
    _cachedDivisions.clear();
    _cachedTeams.clear();
    _cachedFixtures.clear();
  }
}
