import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/fixture.dart';
import 'data_service.dart';
import 'database_service.dart';
import 'notification_service.dart';

class BackgroundUpdateService {
  static Timer? _updateTimer;
  static bool _isRunning = false;
  static bool _initialized = false;

  // Update interval - 2 minutes for high frequency when app is active
  static const Duration _updateInterval = Duration(minutes: 2);
  
  // Time window for checking matches (+/- 12 hours)
  static const Duration _matchTimeWindow = Duration(hours: 12);

  /// Initialize the background update service
  static Future<void> initialize() async {
    if (_initialized) return;

    await NotificationService.initialize();
    await NotificationService.requestPermissions();
    
    _initialized = true;
    debugPrint('📱 [BackgroundUpdate] ✅ Initialized successfully');
  }

  /// Start periodic background updates
  static void startPeriodicUpdates() {
    if (_updateTimer != null) {
      debugPrint('📱 [BackgroundUpdate] ⚠️ Updates already running');
      return;
    }

    _updateTimer = Timer.periodic(_updateInterval, (timer) {
      _performBackgroundUpdate();
    });

    debugPrint(
        '📱 [BackgroundUpdate] 🚀 Started periodic updates every ${_updateInterval.inMinutes} minutes');
  }

  /// Stop periodic background updates
  static void stopPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
    _isRunning = false;
    debugPrint('📱 [BackgroundUpdate] 🛑 Stopped periodic updates');
  }

  /// Perform a single background update check
  static Future<void> _performBackgroundUpdate() async {
    if (_isRunning) {
      debugPrint('📱 [BackgroundUpdate] ⏳ Update already in progress, skipping');
      return;
    }

    _isRunning = true;
    
    try {
      debugPrint('📱 [BackgroundUpdate] 🔄 Starting background update check...');
      
      // Get all favourites to determine what to monitor
      final favourites = await DatabaseService.getFavourites();
      
      if (favourites.isEmpty) {
        debugPrint('📱 [BackgroundUpdate] 📭 No favourites found, skipping update');
        return;
      }

      // Group favourites by division for efficient API calls
      final divisionsToCheck = <String, Map<String, String>>{};
      
      for (final favourite in favourites) {
        if (favourite['type'] == 'team' || favourite['type'] == 'division') {
          final competitionSlug = favourite['competition_slug'] as String?;
          final seasonSlug = favourite['season_slug'] as String?;
          final divisionSlug = favourite['division_slug'] as String?;
          
          if (competitionSlug != null && seasonSlug != null && divisionSlug != null) {
            final key = '${competitionSlug}_${seasonSlug}_$divisionSlug';
            divisionsToCheck[key] = {
              'competition': competitionSlug,
              'season': seasonSlug,
              'division': divisionSlug,
              'competition_name': favourite['competition_name'] ?? '',
              'division_name': favourite['division_name'] ?? '',
            };
          }
        }
      }

      debugPrint(
          '📱 [BackgroundUpdate] 🎯 Checking ${divisionsToCheck.length} divisions for updates');

      // Check each division for updates
      for (final entry in divisionsToCheck.entries) {
        await _checkDivisionForUpdates(
          entry.value['competition']!,
          entry.value['season']!,
          entry.value['division']!,
          competitionName: entry.value['competition_name'],
          divisionName: entry.value['division_name'],
          favourites: favourites,
        );
      }

      debugPrint('📱 [BackgroundUpdate] ✅ Background update check completed');
    } catch (e) {
      debugPrint('📱 [BackgroundUpdate] ❌ Error during background update: $e');
    } finally {
      _isRunning = false;
    }
  }

  /// Check a specific division for updates
  static Future<void> _checkDivisionForUpdates(
    String competitionSlug,
    String seasonSlug,
    String divisionSlug, {
    String? competitionName,
    String? divisionName,
    required List<Map<String, dynamic>> favourites,
  }) async {
    try {
      debugPrint(
          '📱 [BackgroundUpdate] 🔍 Checking division: $competitionSlug/$seasonSlug/$divisionSlug');

      // Get current cached fixtures
      final cachedFixtures = await DatabaseService.getCachedFixtures(
          competitionSlug, seasonSlug, divisionSlug);

      // Fetch fresh fixtures from API
      final freshFixtures = await DataService.getFixtures(
        divisionSlug,
        eventId: competitionSlug,
        season: seasonSlug,
        forceRefresh: true, // Force fresh data
      );

      // Filter fixtures to only those within the time window
      final now = DateTime.now();
      final windowStart = now.subtract(_matchTimeWindow);
      final windowEnd = now.add(_matchTimeWindow);

      final relevantFreshFixtures = freshFixtures.where((fixture) {
        return fixture.dateTime.isAfter(windowStart) &&
            fixture.dateTime.isBefore(windowEnd);
      }).toList();

      final relevantCachedFixtures = cachedFixtures.where((fixture) {
        return fixture.dateTime.isAfter(windowStart) &&
            fixture.dateTime.isBefore(windowEnd);
      }).toList();

      debugPrint(
          '📱 [BackgroundUpdate] ⏰ Found ${relevantFreshFixtures.length} fixtures in time window (+/- 12h)');

      // Check for changes in relevant fixtures
      await _compareFixtures(
        relevantCachedFixtures,
        relevantFreshFixtures,
        competitionSlug,
        seasonSlug,
        divisionSlug,
        competitionName: competitionName,
        divisionName: divisionName,
        favourites: favourites,
      );

      // Also check ladder changes for favourited teams
      await _checkLadderChanges(
        competitionSlug,
        seasonSlug,
        divisionSlug,
        competitionName: competitionName,
        divisionName: divisionName,
        favourites: favourites,
      );

    } catch (e) {
      debugPrint(
          '📱 [BackgroundUpdate] ❌ Error checking division $divisionSlug: $e');
    }
  }

  /// Compare cached vs fresh fixtures and detect changes
  static Future<void> _compareFixtures(
    List<Fixture> cachedFixtures,
    List<Fixture> freshFixtures,
    String competitionSlug,
    String seasonSlug,
    String divisionSlug, {
    String? competitionName,
    String? divisionName,
    required List<Map<String, dynamic>> favourites,
  }) async {
    // Create map for easy lookup
    final cachedMap = {for (final f in cachedFixtures) f.id: f};

    // Get favourited team IDs for this division
    final favouritedTeams = favourites
        .where((fav) =>
            fav['type'] == 'team' &&
            fav['competition_slug'] == competitionSlug &&
            fav['season_slug'] == seasonSlug &&
            fav['division_slug'] == divisionSlug)
        .map((fav) => fav['team_id'] as String?)
        .where((id) => id != null)
        .cast<String>()
        .toSet();

    debugPrint(
        '📱 [BackgroundUpdate] 💫 Monitoring ${favouritedTeams.length} favourited teams in division');

    // Check each fresh fixture for changes
    for (final freshFixture in freshFixtures) {
      final cachedFixture = cachedMap[freshFixture.id];
      
      // Check if this fixture involves any favourited teams
      final involvesFavourite = favouritedTeams.contains(freshFixture.homeTeamId) ||
          favouritedTeams.contains(freshFixture.awayTeamId);

      if (!involvesFavourite) continue; // Skip non-favourited team matches

      if (cachedFixture == null) {
        // New fixture detected
        debugPrint(
            '📱 [BackgroundUpdate] 🆕 New fixture: ${freshFixture.homeTeamName} vs ${freshFixture.awayTeamName}');
        
        await NotificationService.showFixtureUpdate(
          homeTeam: freshFixture.homeTeamName,
          awayTeam: freshFixture.awayTeamName,
          changeType: 'New match scheduled',
          competitionName: competitionName,
          divisionName: divisionName,
          matchTime: freshFixture.dateTime,
        );
      } else {
        // Check for score changes
        final scoreChanged = (cachedFixture.homeScore != freshFixture.homeScore) ||
            (cachedFixture.awayScore != freshFixture.awayScore);

        final completionChanged = cachedFixture.isCompleted != freshFixture.isCompleted;

        if (scoreChanged || completionChanged) {
          String changeType = '';
          String? newScore;

          if (completionChanged && freshFixture.isCompleted) {
            changeType = 'Match completed';
            if (freshFixture.homeScore != null && freshFixture.awayScore != null) {
              newScore = '${freshFixture.homeScore}-${freshFixture.awayScore}';
            }
          } else if (scoreChanged) {
            changeType = 'Score updated';
            if (freshFixture.homeScore != null && freshFixture.awayScore != null) {
              newScore = '${freshFixture.homeScore}-${freshFixture.awayScore}';
            }
          }

          if (changeType.isNotEmpty) {
            debugPrint(
                '📱 [BackgroundUpdate] 🏆 $changeType: ${freshFixture.homeTeamName} vs ${freshFixture.awayTeamName}');

            await NotificationService.showFixtureUpdate(
              homeTeam: freshFixture.homeTeamName,
              awayTeam: freshFixture.awayTeamName,
              changeType: changeType,
              competitionName: competitionName,
              divisionName: divisionName,
              newScore: newScore,
              matchTime: freshFixture.dateTime,
            );
          }
        }
      }
    }
  }

  /// Check for ladder position changes for favourited teams
  static Future<void> _checkLadderChanges(
    String competitionSlug,
    String seasonSlug,
    String divisionSlug, {
    String? competitionName,
    String? divisionName,
    required List<Map<String, dynamic>> favourites,
  }) async {
    try {
      // Get favourited team names for this division
      final favouritedTeamNames = favourites
          .where((fav) =>
              fav['type'] == 'team' &&
              fav['competition_slug'] == competitionSlug &&
              fav['season_slug'] == seasonSlug &&
              fav['division_slug'] == divisionSlug)
          .map((fav) => fav['team_name'] as String?)
          .where((name) => name != null)
          .cast<String>()
          .toSet();

      if (favouritedTeamNames.isEmpty) return;

      // Get current cached ladder
      final cachedLadder = await DatabaseService.getCachedLadderEntries(
          competitionSlug, seasonSlug, divisionSlug);

      // Get fresh ladder data
      final freshLadder = await DataService.getLadderEntries(
        divisionSlug,
        eventId: competitionSlug,
        season: seasonSlug,
        forceRefresh: true,
      );

      // Create maps for position lookup (position = index + 1)
      final cachedPositions = <String, int>{};
      for (int i = 0; i < cachedLadder.length; i++) {
        cachedPositions[cachedLadder[i].teamName] = i + 1;
      }
      
      final freshPositions = <String, int>{};
      for (int i = 0; i < freshLadder.length; i++) {
        freshPositions[freshLadder[i].teamName] = i + 1;
      }

      // Check for position changes in favourited teams
      for (final teamName in favouritedTeamNames) {
        final oldPosition = cachedPositions[teamName];
        final newPosition = freshPositions[teamName];

        if (oldPosition != null &&
            newPosition != null &&
            oldPosition != newPosition) {
          final String positionChange = newPosition < oldPosition
              ? 'moved up to position $newPosition'
              : 'dropped to position $newPosition';

          debugPrint(
              '📱 [BackgroundUpdate] 📊 Ladder change: $teamName $positionChange');

          await NotificationService.showFavouriteTeamUpdate(
            teamName: teamName,
            changeType: 'Ladder position change',
            details: 'Team $positionChange (was $oldPosition)',
            competitionName: competitionName,
            divisionName: divisionName,
          );
        }
      }
    } catch (e) {
      debugPrint(
          '📱 [BackgroundUpdate] ❌ Error checking ladder changes: $e');
    }
  }

  /// Check if the service is currently running
  static bool get isRunning => _updateTimer != null;

  /// Get the current update interval
  static Duration get updateInterval => _updateInterval;
}