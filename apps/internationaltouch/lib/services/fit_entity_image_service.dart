import 'package:flutter/widgets.dart';
import 'package:internationaltouch/config/flags/flags_factory.dart';

/// FIT-specific entity image service that maps team names to country flags using configurable flag modules
class FITEntityImageService {
  /// Get flag widget for a team name or club abbreviation
  static Widget? getFlagWidget({
    required String teamName,
    String? clubAbbreviation,
    double size = 45.0,
  }) {
    return FlagsFactory.getFlagWidget(
      teamName: teamName,
      clubAbbreviation: clubAbbreviation,
      size: size,
    );
  }

  /// Check if a flag exists for the given team
  static bool hasFlagForTeam(String teamName, String? clubAbbreviation) {
    return FlagsFactory.hasFlagForTeam(teamName, clubAbbreviation);
  }
}
