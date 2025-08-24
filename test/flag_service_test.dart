import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flag/flag.dart';
import '../lib/services/flag_service.dart';

void main() {
  group('FlagService Tests', () {
    test('should return flag widget for known countries', () {
      // Test with common countries
      final franceFlagWidget = FlagService.getFlagWidget(
        teamName: 'France National Team',
        clubAbbreviation: 'FRA',
      );

      expect(franceFlagWidget, isNotNull);
      expect(franceFlagWidget, isA<Widget>());
    });

    test('should return flag widget for England (sub-country)', () {
      final englandFlagWidget = FlagService.getFlagWidget(
        teamName: 'England Touch Association',
        clubAbbreviation: 'ENG',
      );

      expect(englandFlagWidget, isNotNull);
      expect(englandFlagWidget, isA<Widget>());
    });

    test('should return flag widget for Hong Kong China mapping', () {
      final hkFlagWidget = FlagService.getFlagWidget(
        teamName: 'Hong Kong China',
        clubAbbreviation: null,
      );

      expect(hkFlagWidget, isNotNull);
      expect(hkFlagWidget, isA<Widget>());
    });

    test('should return flag widget for USA variations', () {
      final usaFlagWidget1 = FlagService.getFlagWidget(
        teamName: 'United States Touch Team',
        clubAbbreviation: 'USA',
      );

      final usaFlagWidget2 = FlagService.getFlagWidget(
        teamName: 'United States National Team',
        clubAbbreviation: null,
      );

      expect(usaFlagWidget1, isNotNull);
      expect(usaFlagWidget2, isNotNull);
    });

    test('should return null for unknown countries', () {
      final unknownFlagWidget = FlagService.getFlagWidget(
        teamName: 'Fictional Country Team',
        clubAbbreviation: 'XYZ',
      );

      expect(unknownFlagWidget, isNull);
    });

    test('should correctly identify teams with flags', () {
      expect(FlagService.hasFlagForTeam('France National Team', 'FRA'), isTrue);
      expect(FlagService.hasFlagForTeam('England Touch', 'ENG'), isTrue);
      expect(FlagService.hasFlagForTeam('Hong Kong China', null), isTrue);
      expect(FlagService.hasFlagForTeam('Unknown Team', 'XYZ'), isFalse);
    });

    test('should handle team names with country keywords', () {
      final australiaFlagWidget = FlagService.getFlagWidget(
        teamName: 'Australia Mixed Open',
        clubAbbreviation: null,
      );

      expect(australiaFlagWidget, isNotNull);
    });

    test('should handle 2-letter ISO codes correctly', () {
      final deFlagWidget = FlagService.getFlagWidget(
        teamName: 'German Team',
        clubAbbreviation: 'DE',
      );

      expect(deFlagWidget, isNotNull);
    });
  });
}
