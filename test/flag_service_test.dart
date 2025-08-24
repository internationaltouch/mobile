import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flag/flag.dart';
import '../lib/services/flag_service.dart';

void main() {
  group('FlagService Tests', () {
    test('should return flag widget for direct country names', () {
      // Test with direct country name
      final franceFlagWidget = FlagService.getFlagWidget(
        teamName: 'France',
        clubAbbreviation: 'FRA',
      );

      expect(franceFlagWidget, isNotNull);
      expect(franceFlagWidget, isA<Widget>());
    });

    test('should return flag widget for England (sub-country)', () {
      final englandFlagWidget = FlagService.getFlagWidget(
        teamName: 'England',
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

    test('should return flag widget for USA through abbreviation', () {
      final usaFlagWidget = FlagService.getFlagWidget(
        teamName: 'United States',
        clubAbbreviation: 'USA',
      );

      expect(usaFlagWidget, isNotNull);
    });

    test('should return null for unknown countries', () {
      final unknownFlagWidget = FlagService.getFlagWidget(
        teamName: 'Fictional Country',
        clubAbbreviation: 'XYZ',
      );

      expect(unknownFlagWidget, isNull);
    });

    test('should correctly identify teams with flags', () {
      expect(FlagService.hasFlagForTeam('France', 'FRA'), isTrue);
      expect(FlagService.hasFlagForTeam('England', 'ENG'), isTrue);
      expect(FlagService.hasFlagForTeam('Hong Kong China', null), isTrue);
      expect(FlagService.hasFlagForTeam('Unknown Country', 'XYZ'), isFalse);
    });

    test('should handle direct country name matches', () {
      final australiaFlagWidget = FlagService.getFlagWidget(
        teamName: 'Australia',
        clubAbbreviation: null,
      );

      expect(australiaFlagWidget, isNotNull);
    });

    test('should handle 2-letter ISO codes correctly', () {
      final deFlagWidget = FlagService.getFlagWidget(
        teamName: 'Germany',
        clubAbbreviation: 'DE',
      );

      expect(deFlagWidget, isNotNull);
    });
  });
}
