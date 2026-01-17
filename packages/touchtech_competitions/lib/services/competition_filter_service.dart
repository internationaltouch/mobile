import 'package:touchtech_core/config/config_service.dart';
import 'package:touchtech_competitions/models/event.dart';
import 'package:touchtech_competitions/models/season.dart';
import 'package:touchtech_competitions/models/division.dart';

class CompetitionFilterService {
  /// Get competition configuration dynamically
  static CompetitionConfig get _config =>
      ConfigService.config.features.competitions;

  /// Filter events (competitions) based on configuration exclusions
  static List<Event> filterEvents(List<Event> events) {
    return events.where((event) => !_isEventExcluded(event)).toList();
  }

  /// Filter seasons for a specific event based on configuration exclusions
  static List<Season> filterSeasons(Event event, List<Season> seasons) {
    return seasons
        .where((season) => !_isSeasonExcluded(event, season))
        .toList();
  }

  /// Filter divisions for a specific event and season based on configuration exclusions
  static List<Division> filterDivisions(
      Event event, String season, List<Division> divisions) {
    return divisions
        .where((division) => !_isDivisionExcluded(event, season, division))
        .toList();
  }

  /// Get competition image from configuration mapping
  static String? getCompetitionImage(String competitionSlug) {
    return _config.slugImageMapping[competitionSlug];
  }

  /// Check if an event (competition) should be excluded
  static bool _isEventExcluded(Event event) {
    // Check if competition slug is in the excluded list
    return event.slug != null && _config.excludedSlugs.contains(event.slug!);
  }

  /// Check if a season for a specific event should be excluded
  static bool _isSeasonExcluded(Event event, Season season) {
    // First check if the entire competition is excluded
    if (_isEventExcluded(event)) return true;

    // Check if the competition+season combo is in the excluded list
    if (event.slug != null) {
      final combo = '${event.slug}:${season.slug}';
      return _config.excludedSeasonCombos.contains(combo);
    }

    return false;
  }

  /// Check if a division for a specific event and season should be excluded
  static bool _isDivisionExcluded(
      Event event, String season, Division division) {
    // First check if the event or season is excluded
    final seasonObj = Season(title: season, slug: season);
    if (_isEventExcluded(event) || _isSeasonExcluded(event, seasonObj)) {
      return true;
    }

    // Check if the competition+season+division combo is in the excluded list
    if (event.slug != null) {
      final combo = '${event.slug}:$season:${division.slug}';
      return _config.excludedDivisionCombos.contains(combo);
    }

    return false;
  }

  /// Get all excluded competition slugs for debugging/testing
  static List<String> get excludedSlugs => _config.excludedSlugs;

  /// Get all excluded season combinations for debugging/testing
  static List<String> get excludedSeasonCombos => _config.excludedSeasonCombos;

  /// Get all excluded division combinations for debugging/testing
  static List<String> get excludedDivisionCombos =>
      _config.excludedDivisionCombos;
}
