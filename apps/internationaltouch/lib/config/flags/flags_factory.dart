import 'package:flutter/widgets.dart';
import 'package:touchtech_core/touchtech_core.dart';
import 'fit_flags.dart';

class FlagsFactory {
  static Widget? getFlagWidget({
    required String teamName,
    String? clubAbbreviation,
    double size = 45.0,
  }) {
    final flagsModule = ConfigService.config.features.flagsModule;

    switch (flagsModule) {
      case 'fit':
        return FITFlags.getFlagWidget(
          teamName: teamName,
          clubAbbreviation: clubAbbreviation,
          size: size,
        );
      default:
        return FITFlags.getFlagWidget(
          teamName: teamName,
          clubAbbreviation: clubAbbreviation,
          size: size,
        );
    }
  }

  static bool hasFlagForTeam(String teamName, String? clubAbbreviation) {
    final flagsModule = ConfigService.config.features.flagsModule;

    switch (flagsModule) {
      case 'fit':
        return FITFlags.hasFlagForTeam(teamName, clubAbbreviation);
      default:
        return FITFlags.hasFlagForTeam(teamName, clubAbbreviation);
    }
  }
}
