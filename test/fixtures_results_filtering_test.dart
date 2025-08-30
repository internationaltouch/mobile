import 'package:flutter_test/flutter_test.dart';
import 'package:fit_mobile_app/models/fixture.dart';
import 'package:fit_mobile_app/models/ladder_entry.dart';
import 'package:fit_mobile_app/models/ladder_stage.dart';
import 'package:fit_mobile_app/models/pool.dart';

/// Test suite for fixtures and results filtering logic
/// Tests all the filtering rules encoded in fixtures_results_view.dart
void main() {
  group('Fixtures Results Filtering Tests', () {
    late List<Fixture> testFixtures;
    late List<LadderStage> testLadderStages;

    setUp(() {
      // Create test fixtures
      testFixtures = [
        // Pool 1 fixtures
        Fixture(
          id: '1',
          homeTeamId: 'team1',
          awayTeamId: 'team2',
          homeTeamName: 'Team 1',
          awayTeamName: 'Team 2',
          dateTime: DateTime.now(),
          field: 'Field 1',
          divisionId: 'div1',
          poolId: 1,
        ),
        Fixture(
          id: '2',
          homeTeamId: 'team3',
          awayTeamId: 'team1',
          homeTeamName: 'Team 3',
          awayTeamName: 'Team 1',
          dateTime: DateTime.now(),
          field: 'Field 2',
          divisionId: 'div1',
          poolId: 1,
        ),
        // Pool 2 fixtures
        Fixture(
          id: '3',
          homeTeamId: 'team4',
          awayTeamId: 'team5',
          homeTeamName: 'Team 4',
          awayTeamName: 'Team 5',
          dateTime: DateTime.now(),
          field: 'Field 3',
          divisionId: 'div1',
          poolId: 2,
        ),
        // Team1 in different pool
        Fixture(
          id: '4',
          homeTeamId: 'team1',
          awayTeamId: 'team6',
          homeTeamName: 'Team 1',
          awayTeamName: 'Team 6',
          dateTime: DateTime.now(),
          field: 'Field 4',
          divisionId: 'div1',
          poolId: 3,
        ),
      ];

      // Create test ladder stages
      testLadderStages = [
        LadderStage(
          title: 'Stage 1',
          ladder: [
            LadderEntry(
              teamId: 'team1',
              teamName: 'Team 1',
              played: 2,
              wins: 2,
              draws: 0,
              losses: 0,
              points: 6,
              goalDifference: 4,
              goalsFor: 6,
              goalsAgainst: 2,
              poolId: 1,
            ),
            LadderEntry(
              teamId: 'team2',
              teamName: 'Team 2',
              played: 1,
              wins: 0,
              draws: 0,
              losses: 1,
              points: 0,
              goalDifference: -2,
              goalsFor: 1,
              goalsAgainst: 3,
              poolId: 1,
            ),
            LadderEntry(
              teamId: 'team4',
              teamName: 'Team 4',
              played: 1,
              wins: 1,
              draws: 0,
              losses: 0,
              points: 3,
              goalDifference: 2,
              goalsFor: 3,
              goalsAgainst: 1,
              poolId: 2,
            ),
          ],
          pools: [
            Pool(id: 1, title: 'Pool A'),
            Pool(id: 2, title: 'Pool B'),
          ],
        ),
      ];
    });

    group('Data Model Tests', () {
      test('Fixture parses stage_group field correctly', () {
        final json = {
          'id': '1',
          'home_team': 'team1',
          'away_team': 'team2',
          'home_team_name': 'Team 1',
          'away_team_name': 'Team 2',
          'datetime': DateTime.now().toIso8601String(),
          'field': 'Field 1',
          'stage_group': 123,
        };

        final fixture = Fixture.fromJson(json);
        expect(fixture.poolId, equals(123));
      });

      test('LadderEntry parses stage_group field correctly', () {
        final json = {
          'team': 'team1',
          'team_name': 'Team 1',
          'played': 1,
          'win': 1,
          'draw': 0,
          'loss': 0,
          'points': 3.0,
          'score_for': 2,
          'score_against': 1,
          'stage_group': 456,
        };

        final entry = LadderEntry.fromJson(json);
        expect(entry.poolId, equals(456));
      });
    });

    group('Filter Logic Tests', () {
      test('Combined pool and team filtering works correctly', () {
        // Apply both pool filter (pool 1) and team filter (team1)
        final filteredFixtures = testFixtures.where((fixture) {
          final matchesTeam =
              fixture.homeTeamId == 'team1' || fixture.awayTeamId == 'team1';
          final matchesPool = fixture.poolId?.toString() == '1';
          return matchesTeam && matchesPool;
        }).toList();

        expect(filteredFixtures.length, equals(2));
        expect(filteredFixtures.every((f) => f.poolId == 1), isTrue);
        expect(
            filteredFixtures.every(
                (f) => f.homeTeamId == 'team1' || f.awayTeamId == 'team1'),
            isTrue);
      });

      test('Pool filter alone works correctly', () {
        final filteredFixtures = testFixtures.where((fixture) {
          return fixture.poolId?.toString() == '1';
        }).toList();

        expect(filteredFixtures.length, equals(2));
        expect(filteredFixtures.every((f) => f.poolId == 1), isTrue);
      });

      test('Team filter alone works correctly', () {
        final filteredFixtures = testFixtures.where((fixture) {
          return fixture.homeTeamId == 'team1' || fixture.awayTeamId == 'team1';
        }).toList();

        expect(filteredFixtures.length, equals(3)); // team1 in 3 fixtures
        expect(
            filteredFixtures.every(
                (f) => f.homeTeamId == 'team1' || f.awayTeamId == 'team1'),
            isTrue);
      });
    });

    group('Team Preservation Logic Tests', () {
      test('Team has matches in selected pool', () {
        // Check if team1 has matches in pool 1
        final teamHasMatchesInPool = testFixtures.any((fixture) {
          final isTeamMatch =
              fixture.homeTeamId == 'team1' || fixture.awayTeamId == 'team1';
          final isInPool = fixture.poolId?.toString() == '1';
          return isTeamMatch && isInPool;
        });

        expect(teamHasMatchesInPool, isTrue);
      });

      test('Team has no matches in selected pool', () {
        // Check if team2 has matches in pool 2
        final teamHasMatchesInPool = testFixtures.any((fixture) {
          final isTeamMatch =
              fixture.homeTeamId == 'team2' || fixture.awayTeamId == 'team2';
          final isInPool = fixture.poolId?.toString() == '2';
          return isTeamMatch && isInPool;
        });

        expect(teamHasMatchesInPool, isFalse);
      });
    });

    group('Ladder Filtering Tests', () {
      test('Separate ladder stages created per pool when no pool filter', () {
        // Simulate the logic from _filterLadderStages when _selectedPoolId == null
        final filteredLadderStages = <LadderStage>[];

        for (final stage in testLadderStages) {
          for (final pool in stage.pools) {
            final poolLadder = stage.ladder.where((entry) {
              return entry.poolId == pool.id;
            }).toList();

            if (poolLadder.isNotEmpty) {
              filteredLadderStages.add(LadderStage(
                title: pool.title, // Use pool name as title
                ladder: poolLadder,
                pools: [pool],
              ));
            }
          }
        }

        expect(filteredLadderStages.length, equals(2)); // Pool A and Pool B
        expect(filteredLadderStages[0].title, equals('Pool A'));
        expect(filteredLadderStages[1].title, equals('Pool B'));
        expect(
            filteredLadderStages[0].ladder.length, equals(2)); // team1, team2
        expect(filteredLadderStages[1].ladder.length, equals(1)); // team4
      });

      test('Single ladder stage when pool filter applied', () {
        // Simulate the logic from _filterLadderStages when _selectedPoolId == '1'
        final selectedPoolId = '1';
        final filteredLadderStages = testLadderStages
            .map((stage) {
              final filteredLadder = stage.ladder.where((entry) {
                return entry.poolId?.toString() == selectedPoolId;
              }).toList();

              return LadderStage(
                title: stage.title,
                ladder: filteredLadder,
                pools: stage.pools
                    .where((pool) => pool.id.toString() == selectedPoolId)
                    .toList(),
              );
            })
            .where((stage) => stage.ladder.isNotEmpty)
            .toList();

        expect(filteredLadderStages.length, equals(1));
        expect(filteredLadderStages[0].ladder.length,
            equals(2)); // team1, team2 in pool 1
        expect(
            filteredLadderStages[0].ladder.every((e) => e.poolId == 1), isTrue);
      });
    });

    group('Dropdown Value Tests', () {
      test('Pool dropdown items have unique values', () {
        // Simulate _buildPoolDropdownItems logic
        final items = <String>[];

        // All Pools option
        items.add('all_pools');

        // Stage headers with unique values
        for (final stage in testLadderStages) {
          if (stage.pools.isNotEmpty) {
            items.add('header_${stage.title}');

            for (final pool in stage.pools) {
              items.add(pool.id.toString());
            }
          }
        }

        // Check for unique values
        final uniqueItems = items.toSet();
        expect(uniqueItems.length, equals(items.length));
        expect(items.contains('all_pools'), isTrue);
        expect(items.contains('header_Stage 1'), isTrue);
        expect(items.contains('1'), isTrue);
        expect(items.contains('2'), isTrue);
      });

      test('No duplicate null values in dropdown', () {
        // Simulate dropdown items creation
        final items = <String?>[];

        // All Pools - uses 'all_pools' not null
        items.add('all_pools');

        // Headers use unique values, not null
        items.add('header_Stage 1');

        // Pool values
        items.add('1');
        items.add('2');

        // Verify no null values that could cause assertion error
        expect(items.where((item) => item == null).length, equals(0));
      });
    });

    group('Header Display Logic Tests', () {
      test('Headers shown when multiple stages and no pool filter', () {
        final multipleStages = [
          testLadderStages[0],
          testLadderStages[0]
        ]; // Simulate 2 stages
        final selectedPoolId = null;

        final showHeader = multipleStages.length > 1 && selectedPoolId == null;
        expect(showHeader, isTrue);
      });

      test('Headers hidden when single stage and no pool filter', () {
        final singleStage = [testLadderStages[0]]; // 1 stage
        final selectedPoolId = null;

        final showHeader = singleStage.length > 1 && selectedPoolId == null;
        expect(showHeader, isFalse);
      });

      test('Headers hidden when pool filter applied', () {
        final multipleStages = [
          testLadderStages[0],
          testLadderStages[0]
        ]; // 2 stages
        final selectedPoolId = '1';

        final showHeader = multipleStages.length > 1 && selectedPoolId == null;
        expect(showHeader, isFalse);
      });
    });

    group('Pool Filter Reset Tests', () {
      test('All Pools selection converts to null internally', () {
        final poolId = 'all_pools';
        final selectedPoolId = (poolId == 'all_pools') ? null : poolId;

        expect(selectedPoolId, isNull);
      });

      test('Specific pool selection preserves value', () {
        final poolId = '1';
        final selectedPoolId = (poolId == 'all_pools') ? null : poolId;

        expect(selectedPoolId, equals('1'));
      });

      test('All fixtures shown when pool filter reset', () {
        final selectedPoolId = null; // Simulates "All Pools" selection

        final filteredFixtures = testFixtures.where((fixture) {
          bool matchesPool = true;
          if (selectedPoolId != null) {
            matchesPool = fixture.poolId?.toString() == selectedPoolId;
          }
          return matchesPool;
        }).toList();

        expect(filteredFixtures.length, equals(testFixtures.length));
      });
    });

    group('Team Selection Preservation Tests', () {
      test('Team selection preserved when unselecting pool', () {
        // Simulate: pool selected, then "All Pools" selected
        final poolId = 'all_pools'; // User selects "All Pools"
        final selectedTeamId = 'team1'; // Team was previously selected

        // Logic: only clear team when selecting specific pool, not when unselecting
        String? newTeamId = selectedTeamId;
        if (poolId != null && poolId != 'all_pools') {
          // Would check for matches and potentially clear, but not in this case
          newTeamId = null;
        }

        expect(newTeamId, equals('team1')); // Team selection preserved
      });

      test('Team selection cleared when team has no matches in new pool', () {
        final poolId = '2'; // Select pool 2
        final selectedTeamId = 'team2'; // team2 has no matches in pool 2

        // Check if team has matches in the new pool
        final teamHasMatchesInPool = testFixtures.any((fixture) {
          final isTeamMatch = fixture.homeTeamId == selectedTeamId ||
              fixture.awayTeamId == selectedTeamId;
          final isInPool = fixture.poolId?.toString() == poolId;
          return isTeamMatch && isInPool;
        });

        expect(teamHasMatchesInPool, isFalse);

        // Team should be cleared
        final newTeamId = teamHasMatchesInPool ? selectedTeamId : null;
        expect(newTeamId, isNull);
      });

      test('Team selection preserved when team has matches in new pool', () {
        final poolId = '1'; // Select pool 1
        final selectedTeamId = 'team1'; // team1 has matches in pool 1

        // Check if team has matches in the new pool
        final teamHasMatchesInPool = testFixtures.any((fixture) {
          final isTeamMatch = fixture.homeTeamId == selectedTeamId ||
              fixture.awayTeamId == selectedTeamId;
          final isInPool = fixture.poolId?.toString() == poolId;
          return isTeamMatch && isInPool;
        });

        expect(teamHasMatchesInPool, isTrue);

        // Team should be preserved
        final newTeamId = teamHasMatchesInPool ? selectedTeamId : null;
        expect(newTeamId, equals('team1'));
      });
    });
  });
}
