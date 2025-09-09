import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pure_riverpod_providers.dart';
import '../models/event.dart';
import '../models/division.dart';
import '../models/fixture.dart';
import '../models/favorite.dart';
import '../widgets/match_score_card.dart';
import '../widgets/favorite_button.dart';

class FixturesResultsViewRiverpod extends ConsumerStatefulWidget {
  final Event event;
  final String season;
  final Division division;
  final String? initialTeamId;

  const FixturesResultsViewRiverpod({
    super.key,
    required this.event,
    required this.season,
    required this.division,
    this.initialTeamId,
  });

  @override
  ConsumerState<FixturesResultsViewRiverpod> createState() =>
      _FixturesResultsViewRiverpodState();
}

class _FixturesResultsViewRiverpodState
    extends ConsumerState<FixturesResultsViewRiverpod>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedTeamId;
  String? _selectedPoolId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedTeamId = widget.initialTeamId;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTeamSelected(String? teamId) {
    setState(() {
      _selectedTeamId = teamId;
    });
  }

  Widget _buildContextualFavoriteButton(WidgetRef ref, String seasonSlug) {
    if (_selectedTeamId != null) {
      // User has filtered by team - favorite the team
      final teamsAsync = ref.watch(teamsProvider((
        eventId: widget.event.id,
        seasonSlug: seasonSlug,
        divisionId: widget.division.id,
      )));

      return teamsAsync.when(
        loading: () => FavoriteButton(
          favorite: Favorite.fromDivision(
            widget.event.id,
            widget.event.slug ?? widget.event.id,
            widget.event.name,
            widget.season,
            widget.division.id,
            widget.division.slug ?? widget.division.id,
            widget.division.name,
            widget.division.color,
          ),
          favoriteColor: Colors.white,
        ),
        error: (_, __) => FavoriteButton(
          favorite: Favorite.fromDivision(
            widget.event.id,
            widget.event.slug ?? widget.event.id,
            widget.event.name,
            widget.season,
            widget.division.id,
            widget.division.slug ?? widget.division.id,
            widget.division.name,
            widget.division.color,
          ),
          favoriteColor: Colors.white,
        ),
        data: (teams) {
          try {
            final selectedTeam = teams.firstWhere(
              (team) => team.id == _selectedTeamId,
            );

            return FavoriteButton(
              favorite: Favorite.fromTeam(
                widget.event.id,
                widget.event.slug ?? widget.event.id,
                widget.event.name,
                widget.season,
                widget.division.id,
                widget.division.slug ?? widget.division.id,
                widget.division.name,
                selectedTeam.id,
                selectedTeam.name,
                selectedTeam.slug,
                widget.division.color, // Use division color for team
              ),
              favoriteColor: Colors.white,
            );
          } catch (e) {
            // Fallback to division favorite if team not found
            return FavoriteButton(
              favorite: Favorite.fromDivision(
                widget.event.id,
                widget.event.slug ?? widget.event.id,
                widget.event.name,
                widget.season,
                widget.division.id,
                widget.division.slug ?? widget.division.id,
                widget.division.name,
                widget.division.color,
              ),
              favoriteColor: Colors.white,
            );
          }
        },
      );
    } else {
      // No team filter - favorite the division
      return FavoriteButton(
        favorite: Favorite.fromDivision(
          widget.event.id,
          widget.event.slug ?? widget.event.id,
          widget.event.name,
          widget.season,
          widget.division.id,
          widget.division.slug ?? widget.division.id,
          widget.division.name,
          widget.division.color,
        ),
        favoriteColor: Colors.white,
      );
    }
  }

  void _onPoolSelected(String? poolId) {
    setState(() {
      _selectedPoolId = (poolId == 'all_pools') ? null : poolId;
    });
  }

  List<DropdownMenuItem<String>> _buildPoolDropdownItems(
      List<Fixture> allFixtures) {
    final pools = <String, String>{}; // poolId -> poolTitle

    for (final fixture in allFixtures) {
      if (fixture.poolId != null) {
        final poolId = fixture.poolId.toString();
        final poolTitle = 'Pool ${fixture.poolId}'; // Simple naming
        pools[poolId] = poolTitle;
      }
    }

    return pools.entries
        .map((entry) => DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            ))
        .toList();
  }

  List<Fixture> _filterFixtures(List<Fixture> allFixtures) {
    return allFixtures.where((fixture) {
      bool matchesTeam = true;
      bool matchesPool = true;

      // Apply team filter if selected
      if (_selectedTeamId != null) {
        matchesTeam = fixture.homeTeamId == _selectedTeamId ||
            fixture.awayTeamId == _selectedTeamId;
      }

      // Apply pool filter if selected
      if (_selectedPoolId != null) {
        matchesPool = fixture.poolId?.toString() == _selectedPoolId;
      }

      return matchesTeam && matchesPool;
    }).toList();
  }

  bool _hasAnyPools(List<Fixture> fixtures) {
    return fixtures.any((fixture) => fixture.poolId != null);
  }

  @override
  Widget build(BuildContext context) {
    final seasonSlug = widget.season; // Convert to slug if needed
    final params = (
      eventId: widget.event.id,
      seasonSlug: seasonSlug,
      divisionId: widget.division.id,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.division.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              '${widget.event.name} - ${widget.season}',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        actions: [
          _buildContextualFavoriteButton(ref, seasonSlug),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          tabs: const [
            Tab(text: 'Fixtures', icon: Icon(Icons.schedule)),
            Tab(text: 'Ladder', icon: Icon(Icons.leaderboard)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFixturesTab(params),
          _buildLadderTab(params),
        ],
      ),
    );
  }

  Widget _buildFixturesTab(
      ({String eventId, String seasonSlug, String divisionId}) params) {
    final fixturesAsync = ref.watch(fixturesProvider(params));

    return fixturesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load fixtures',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(fixturesProvider(params));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (fixtures) {
        if (fixtures.isEmpty) {
          return const Center(
            child: Text('No fixtures available'),
          );
        }

        final filteredFixtures = _filterFixtures(fixtures);
        final teamsAsync = ref.watch(teamsProvider(params));

        return Column(
          children: [
            // Filter dropdowns
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Pool filter dropdown - only show if pools exist
                  if (_hasAnyPools(fixtures)) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPoolId ?? 'all_pools',
                      decoration: const InputDecoration(
                        labelText: 'Filter by Pool',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: 'all_pools',
                          child: Text('All Pools'),
                        ),
                        ..._buildPoolDropdownItems(fixtures),
                      ],
                      onChanged: _onPoolSelected,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Team filter dropdown
                  teamsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (error, stackTrace) => const SizedBox.shrink(),
                    data: (teams) {
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedTeamId,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Team',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Teams'),
                          ),
                          ...(teams..sort((a, b) => a.name.compareTo(b.name)))
                              .map((team) => DropdownMenuItem<String>(
                                    value: team.id,
                                    child: Text(team.name),
                                  )),
                        ],
                        onChanged: _onTeamSelected,
                      );
                    },
                  ),
                ],
              ),
            ),
            // Fixtures list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(fixturesProvider(params));
                  ref.invalidate(teamsProvider(params));
                  await ref.read(fixturesProvider(params).future);
                },
                child: filteredFixtures.isEmpty
                    ? const Center(
                        child: Text(
                          'No fixtures match your filters',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        itemCount: filteredFixtures.length,
                        itemBuilder: (context, index) {
                          final fixture = filteredFixtures[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: MatchScoreCard(
                              fixture: fixture,
                              highlightedTeamId: _selectedTeamId,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLadderTab(
      ({String eventId, String seasonSlug, String divisionId}) params) {
    final ladderAsync = ref.watch(ladderProvider(params));

    return ladderAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load ladder',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(ladderProvider(params));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (ladder) {
        if (ladder.isEmpty) {
          return const Center(
            child: Text('No ladder data available'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(ladderProvider(params));
            await ref.read(ladderProvider(params).future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DataTable(
                  columnSpacing: 12.0,
                  columns: const [
                    DataColumn(
                        label: Text('Pos',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Team',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('P',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('W',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('D',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('L',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('GF',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('GA',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('GD',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Pts',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: ladder.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ladderEntry = entry.value;
                    final position = index + 1;

                    return DataRow(
                      cells: [
                        DataCell(Text(position.toString())),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Entity images can be added here if needed
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(right: 8.0),
                                child:
                                    Container(), // Placeholder for entity images
                              ),
                              Flexible(
                                child: Text(
                                  ladderEntry.teamName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(ladderEntry.played.toString())),
                        DataCell(Text(ladderEntry.wins.toString())),
                        DataCell(Text(ladderEntry.draws.toString())),
                        DataCell(Text(ladderEntry.losses.toString())),
                        DataCell(Text(ladderEntry.goalsFor.toString())),
                        DataCell(Text(ladderEntry.goalsAgainst.toString())),
                        DataCell(Text(ladderEntry.goalDifferenceText)),
                        DataCell(Text(ladderEntry.points.toStringAsFixed(0))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
