import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:fit_mobile_app/services/flag_service.dart';

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

    group('Missing Countries Issue #22', () {
      test('should return flag widget for Chile (CHL)', () {
        final chileFlagWidget = FlagService.getFlagWidget(
          teamName: 'Chile National Team',
          clubAbbreviation: 'CHL',
        );

        expect(chileFlagWidget, isNotNull);
        expect(chileFlagWidget, isA<Widget>());
        expect(
            FlagService.hasFlagForTeam('Chile National Team', 'CHL'), isTrue);
      });

      test('should return flag widget for Chile by country name', () {
        final chileFlagWidget = FlagService.getFlagWidget(
          teamName: 'Chile',
          clubAbbreviation: null,
        );

        expect(chileFlagWidget, isNotNull);
        expect(FlagService.hasFlagForTeam('Chile', null), isTrue);
      });

      test('should return flag widget for Cayman Islands (CYM)', () {
        final caymanFlagWidget = FlagService.getFlagWidget(
          teamName: 'Cayman Islands Touch Association',
          clubAbbreviation: 'CYM',
        );

        expect(caymanFlagWidget, isNotNull);
        expect(caymanFlagWidget, isA<Widget>());
        expect(
            FlagService.hasFlagForTeam(
                'Cayman Islands Touch Association', 'CYM'),
            isTrue);
      });

      test('should return flag widget for Cayman Islands by country name', () {
        final caymanFlagWidget = FlagService.getFlagWidget(
          teamName: 'Cayman Islands',
          clubAbbreviation: null,
        );

        expect(caymanFlagWidget, isNotNull);
        expect(FlagService.hasFlagForTeam('Cayman Islands', null), isTrue);
      });

      test('should return flag widget for Lebanon (LBN)', () {
        final lebanonFlagWidget = FlagService.getFlagWidget(
          teamName: 'Lebanon National Team',
          clubAbbreviation: 'LBN',
        );

        expect(lebanonFlagWidget, isNotNull);
        expect(lebanonFlagWidget, isA<Widget>());
        expect(
            FlagService.hasFlagForTeam('Lebanon National Team', 'LBN'), isTrue);
      });

      test('should return flag widget for Lebanon by country name', () {
        final lebanonFlagWidget = FlagService.getFlagWidget(
          teamName: 'Lebanon',
          clubAbbreviation: null,
        );

        expect(lebanonFlagWidget, isNotNull);
        expect(FlagService.hasFlagForTeam('Lebanon', null), isTrue);
      });

      test('should return flag widget for Guernsey (GGY)', () {
        final guernseyFlagWidget = FlagService.getFlagWidget(
          teamName: 'Guernsey Touch Club',
          clubAbbreviation: 'GGY',
        );

        expect(guernseyFlagWidget, isNotNull);
        expect(guernseyFlagWidget, isA<Widget>());
        expect(
            FlagService.hasFlagForTeam('Guernsey Touch Club', 'GGY'), isTrue);
      });

      test('should return flag widget for Guernsey by country name', () {
        final guernseyFlagWidget = FlagService.getFlagWidget(
          teamName: 'Guernsey',
          clubAbbreviation: null,
        );

        expect(guernseyFlagWidget, isNotNull);
        expect(FlagService.hasFlagForTeam('Guernsey', null), isTrue);
      });

      test('should return flag widget for Jersey (JEY)', () {
        final jerseyFlagWidget = FlagService.getFlagWidget(
          teamName: 'Jersey Touch Association',
          clubAbbreviation: 'JEY',
        );

        expect(jerseyFlagWidget, isNotNull);
        expect(jerseyFlagWidget, isA<Widget>());
        expect(FlagService.hasFlagForTeam('Jersey Touch Association', 'JEY'),
            isTrue);
      });

      test('should return flag widget for Jersey by country name', () {
        final jerseyFlagWidget = FlagService.getFlagWidget(
          teamName: 'Jersey',
          clubAbbreviation: null,
        );

        expect(jerseyFlagWidget, isNotNull);
        expect(FlagService.hasFlagForTeam('Jersey', null), isTrue);
      });

      test('should return flag widget for Oman (OMN)', () {
        final omanFlagWidget = FlagService.getFlagWidget(
          teamName: 'Oman National Team',
          clubAbbreviation: 'OMN',
        );

        expect(omanFlagWidget, isNotNull);
        expect(omanFlagWidget, isA<Widget>());
        expect(FlagService.hasFlagForTeam('Oman National Team', 'OMN'), isTrue);
      });

      test('should return flag widget for Oman by country name', () {
        final omanFlagWidget = FlagService.getFlagWidget(
          teamName: 'Oman',
          clubAbbreviation: null,
        );

        expect(omanFlagWidget, isNotNull);
        expect(FlagService.hasFlagForTeam('Oman', null), isTrue);
      });

      test('should handle Chinese Taipei special case', () {
        final chineseTaipeiFlagWidget = FlagService.getFlagWidget(
          teamName: 'Chinese Taipei',
          clubAbbreviation: null,
        );

        expect(chineseTaipeiFlagWidget, isNotNull);
        expect(chineseTaipeiFlagWidget, isA<Widget>());
        expect(FlagService.hasFlagForTeam('Chinese Taipei', null), isTrue);
      });

      test('should handle TPE abbreviation for Chinese Taipei', () {
        final tpeFlagWidget = FlagService.getFlagWidget(
          teamName: 'Chinese Taipei National Team',
          clubAbbreviation: 'TPE',
        );

        expect(tpeFlagWidget, isNotNull);
        expect(
            FlagService.hasFlagForTeam('Chinese Taipei National Team', 'TPE'),
            isTrue);
      });
    });
  });
}
