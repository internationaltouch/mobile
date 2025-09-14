import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:fit_mobile_app/services/fit_entity_image_service.dart';
import 'package:fit_mobile_app/config/config_service.dart';

void main() {
  group('FITEntityImageService Tests', () {
    setUp(() {
      // Initialize ConfigService for all flag service tests
      ConfigService.setTestConfig();
    });
    test('should return flag widget for direct country names', () {
      // Test with direct country name
      final franceFlagWidget = FITEntityImageService.getFlagWidget(
        teamName: 'France',
        clubAbbreviation: 'FRA',
      );

      expect(franceFlagWidget, isNotNull);
      expect(franceFlagWidget, isA<Widget>());
    });

    test('should return flag widget for England (sub-country)', () {
      final englandFlagWidget = FITEntityImageService.getFlagWidget(
        teamName: 'England',
        clubAbbreviation: 'ENG',
      );

      expect(englandFlagWidget, isNotNull);
      expect(englandFlagWidget, isA<Widget>());
    });

    test('should return flag widget for Hong Kong China mapping', () {
      final hkFlagWidget = FITEntityImageService.getFlagWidget(
        teamName: 'Hong Kong China',
        clubAbbreviation: null,
      );

      expect(hkFlagWidget, isNotNull);
      expect(hkFlagWidget, isA<Widget>());
    });

    test('should return flag widget for USA through abbreviation', () {
      final usaFlagWidget = FITEntityImageService.getFlagWidget(
        teamName: 'United States',
        clubAbbreviation: 'USA',
      );

      expect(usaFlagWidget, isNotNull);
    });

    test('should return null for unknown countries', () {
      final unknownFlagWidget = FITEntityImageService.getFlagWidget(
        teamName: 'Fictional Country',
        clubAbbreviation: 'XYZ',
      );

      expect(unknownFlagWidget, isNull);
    });

    test('should correctly identify teams with flags', () {
      expect(FITEntityImageService.hasFlagForTeam('France', 'FRA'), isTrue);
      expect(FITEntityImageService.hasFlagForTeam('England', 'ENG'), isTrue);
      expect(FITEntityImageService.hasFlagForTeam('Hong Kong China', null), isTrue);
      expect(FITEntityImageService.hasFlagForTeam('Unknown Country', 'XYZ'), isFalse);
    });

    test('should handle direct country name matches', () {
      final australiaFlagWidget = FITEntityImageService.getFlagWidget(
        teamName: 'Australia',
        clubAbbreviation: null,
      );

      expect(australiaFlagWidget, isNotNull);
    });

    test('should handle 2-letter ISO codes correctly', () {
      final deFlagWidget = FITEntityImageService.getFlagWidget(
        teamName: 'Germany',
        clubAbbreviation: 'DE',
      );

      expect(deFlagWidget, isNotNull);
    });

    group('Missing Countries Issue #22', () {
      test('should return flag widget for Chile (CHL)', () {
        final chileFlagWidget = FITEntityImageService.getFlagWidget(
          teamName: 'Chile National Team',
          clubAbbreviation: 'CHL',
        );

        expect(chileFlagWidget, isNotNull);
        expect(chileFlagWidget, isA<Widget>());
        expect(
            FITEntityImageService.hasFlagForTeam('Chile National Team', 'CHL'), isTrue);
      });

      test('should return flag widget for Chile by country name', () {
        final chileFlagWidget = FITEntityImageService.getFlagWidget(
          teamName: 'Chile',
          clubAbbreviation: null,
        );

        expect(chileFlagWidget, isNotNull);
        expect(FITEntityImageService.hasFlagForTeam('Chile', null), isTrue);
      });

      test('should return flag widget for Cayman Islands (CYM)', () {
        final caymanFlagWidget = FITEntityImageService.getFlagWidget(
          teamName: 'Cayman Islands Touch Association',
          clubAbbreviation: 'CYM',
        );

        expect(caymanFlagWidget, isNotNull);
        expect(caymanFlagWidget, isA<Widget>());
        expect(
            FITEntityImageService.hasFlagForTeam(
                'Cayman Islands Touch Association', 'CYM'),
            isTrue);
      });

      test('should return flag widget for Cayman Islands by country name', () {
        final caymanFlagWidget = FITEntityImageService.getFlagWidget(
          teamName: 'Cayman Islands',
          clubAbbreviation: null,
        );

        expect(caymanFlagWidget, isNotNull);
        expect(FITEntityImageService.hasFlagForTeam('Cayman Islands', null), isTrue);
      });

      test('should return flag widget for Lebanon (LBN)', () {
        final lebanonFlagWidget = FITEntityImageService.getFlagWidget(
          teamName: 'Lebanon National Team',
          clubAbbreviation: 'LBN',
        );

        expect(lebanonFlagWidget, isNotNull);
        expect(lebanonFlagWidget, isA<Widget>());
        expect(
            FITEntityImageService.hasFlagForTeam('Lebanon National Team', 'LBN'), isTrue);
      });

      test('should return flag widget for Lebanon by country name', () {
        final lebanonFlagWidget = FITEntityImageService.getFlagWidget(
          teamName: 'Lebanon',
          clubAbbreviation: null,
        );

        expect(lebanonFlagWidget, isNotNull);
        expect(FITEntityImageService.hasFlagForTeam('Lebanon', null), isTrue);
      });

      test('should return flag widget for Guernsey (GGY)', () {
        final guernseyFlagWidget = FITEntityImageService.getFlagWidget(
          teamName: 'Guernsey Touch Club',
          clubAbbreviation: 'GGY',
        );

        expect(guernseyFlagWidget, isNotNull);
        expect(guernseyFlagWidget, isA<Widget>());
        expect(
            FITEntityImageService.hasFlagForTeam('Guernsey Touch Club', 'GGY'), isTrue);
      });

      test('should return flag widget for Guernsey by country name', () {
        final guernseyFlagWidget = FITEntityImageService.getFlagWidget(
          teamName: 'Guernsey',
          clubAbbreviation: null,
        );

        expect(guernseyFlagWidget, isNotNull);
        expect(FITEntityImageService.hasFlagForTeam('Guernsey', null), isTrue);
      });

      test('should return flag widget for Jersey (JEY)', () {
        final jerseyFlagWidget = FITEntityImageService.getFlagWidget(
          teamName: 'Jersey Touch Association',
          clubAbbreviation: 'JEY',
        );

        expect(jerseyFlagWidget, isNotNull);
        expect(jerseyFlagWidget, isA<Widget>());
        expect(FITEntityImageService.hasFlagForTeam('Jersey Touch Association', 'JEY'),
            isTrue);
      });

      test('should return flag widget for Jersey by country name', () {
        final jerseyFlagWidget = FITEntityImageService.getFlagWidget(
          teamName: 'Jersey',
          clubAbbreviation: null,
        );

        expect(jerseyFlagWidget, isNotNull);
        expect(FITEntityImageService.hasFlagForTeam('Jersey', null), isTrue);
      });

      test('should return flag widget for Oman (OMN)', () {
        final omanFlagWidget = FITEntityImageService.getFlagWidget(
          teamName: 'Oman National Team',
          clubAbbreviation: 'OMN',
        );

        expect(omanFlagWidget, isNotNull);
        expect(omanFlagWidget, isA<Widget>());
        expect(FITEntityImageService.hasFlagForTeam('Oman National Team', 'OMN'), isTrue);
      });

      test('should return flag widget for Oman by country name', () {
        final omanFlagWidget = FITEntityImageService.getFlagWidget(
          teamName: 'Oman',
          clubAbbreviation: null,
        );

        expect(omanFlagWidget, isNotNull);
        expect(FITEntityImageService.hasFlagForTeam('Oman', null), isTrue);
      });

      test('should handle Chinese Taipei special case', () {
        final chineseTaipeiFlagWidget = FITEntityImageService.getFlagWidget(
          teamName: 'Chinese Taipei',
          clubAbbreviation: null,
        );

        expect(chineseTaipeiFlagWidget, isNotNull);
        expect(chineseTaipeiFlagWidget, isA<Widget>());
        expect(FITEntityImageService.hasFlagForTeam('Chinese Taipei', null), isTrue);
      });

      test('should handle TPE abbreviation for Chinese Taipei', () {
        final tpeFlagWidget = FITEntityImageService.getFlagWidget(
          teamName: 'Chinese Taipei National Team',
          clubAbbreviation: 'TPE',
        );

        expect(tpeFlagWidget, isNotNull);
        expect(
            FITEntityImageService.hasFlagForTeam('Chinese Taipei National Team', 'TPE'),
            isTrue);
      });
    });
  });
}
