import 'package:flutter_test/flutter_test.dart';
import 'package:fit_mobile_app/models/club.dart';

void main() {
  group('Club Status Filtering', () {
    test('Club.fromJson should parse status field correctly', () {
      // Test club with active status
      final activeClubJson = {
        'title': 'Test Club Active',
        'short_title': 'TCA',
        'slug': 'test-club-active',
        'abbreviation': 'TCA',
        'url': 'https://example.com/active',
        'status': 'active',
      };
      
      final activeClub = Club.fromJson(activeClubJson);
      expect(activeClub.status, equals('active'));
      expect(activeClub.title, equals('Test Club Active'));

      // Test club with inactive status
      final inactiveClubJson = {
        'title': 'Test Club Inactive',
        'short_title': 'TCI',
        'slug': 'test-club-inactive',
        'abbreviation': 'TCI',
        'url': 'https://example.com/inactive',
        'status': 'inactive',
      };
      
      final inactiveClub = Club.fromJson(inactiveClubJson);
      expect(inactiveClub.status, equals('inactive'));

      // Test club with null status (backwards compatibility)
      final nullStatusClubJson = {
        'title': 'Test Club No Status',
        'short_title': 'TCNS',
        'slug': 'test-club-no-status',
        'abbreviation': 'TCNS',
        'url': 'https://example.com/no-status',
      };
      
      final nullStatusClub = Club.fromJson(nullStatusClubJson);
      expect(nullStatusClub.status, isNull);
    });

    test('Active clubs filtering should work correctly', () {
      final clubs = [
        Club(
          title: 'Active Club 1',
          shortTitle: 'AC1',
          slug: 'active-club-1',
          abbreviation: 'AC1',
          url: 'https://example.com/1',
          status: 'active',
        ),
        Club(
          title: 'Inactive Club',
          shortTitle: 'IC',
          slug: 'inactive-club',
          abbreviation: 'IC',
          url: 'https://example.com/inactive',
          status: 'inactive',
        ),
        Club(
          title: 'Active Club 2',
          shortTitle: 'AC2',
          slug: 'active-club-2',
          abbreviation: 'AC2',
          url: 'https://example.com/2',
          status: 'active',
        ),
        Club(
          title: 'No Status Club',
          shortTitle: 'NSC',
          slug: 'no-status-club',
          abbreviation: 'NSC',
          url: 'https://example.com/no-status',
          status: null,
        ),
      ];

      // Filter to only active clubs (same logic as MembersView)
      final activeClubs = clubs.where((club) => club.status == 'active').toList();

      expect(activeClubs.length, equals(2));
      expect(activeClubs[0].title, equals('Active Club 1'));
      expect(activeClubs[1].title, equals('Active Club 2'));
      
      // Verify inactive and null status clubs are excluded
      final inactiveClubs = clubs.where((club) => club.status != 'active').toList();
      expect(inactiveClubs.length, equals(2));
    });

    test('Club.toJson should include status field', () {
      final club = Club(
        title: 'Test Club',
        shortTitle: 'TC',
        slug: 'test-club',
        abbreviation: 'TC',
        url: 'https://example.com',
        status: 'active',
      );

      final json = club.toJson();
      expect(json['status'], equals('active'));
      expect(json.containsKey('status'), isTrue);
    });
  });
}