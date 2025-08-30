import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/division.dart';
import '../models/fixture.dart';
import '../models/ladder_stage.dart';
import '../models/team.dart';
import '../services/data_service.dart';
import '../theme/fit_colors.dart';
import '../widgets/match_score_card.dart';

class FixturesResultsView extends StatefulWidget {
  final Event event;
  final String season;
  final Division division;
  final String? initialTeamId;

  const FixturesResultsView({
    super.key,
    required this.event,
    required this.season,
    required this.division,
    this.initialTeamId,
  });

  @override
  State<FixturesResultsView> createState() => _FixturesResultsViewState();
}

class _FixturesResultsViewState extends State<FixturesResultsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Fixture>> _fixturesFuture;
  late Future<List<LadderStage>> _ladderStagesFuture;
  late Future<List<Team>> _teamsFuture;
  String? _selectedTeamId;
  String? _selectedPoolId; // Selected pool for filtering
  List<Fixture> _allFixtures = [];
  List<Fixture> _filteredFixtures = [];
  List<LadderStage> _allLadderStages = [];
  List<LadderStage> _filteredLadderStages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedTeamId = widget.initialTeamId;
    _loadData();
  }

  void _loadData() {
    _fixturesFuture = DataService.getFixtures(
      widget.division.slug ?? widget.division.id,
      eventId: widget.event.slug ?? widget.event.id,
      season: widget.season,
    ).then((fixtures) {
      _allFixtures = fixtures;
      _filterFixtures();
      return fixtures;
    });
    _ladderStagesFuture = DataService.getLadderStages(
      widget.division.slug ?? widget.division.id,
      eventId: widget.event.slug ?? widget.event.id,
      season: widget.season,
    ).then((ladderStages) {
      _allLadderStages = ladderStages;
      _filterLadderStages();
      return ladderStages;
    });
    _teamsFuture = DataService.getTeams(
      widget.division.slug ?? widget.division.id,
      eventId: widget.event.slug ?? widget.event.id,
      season: widget.season,
    );
  }

  void _reloadData() async {
    // Clear cache only for this specific division's data
    await DataService.clearDivisionCache(
      widget.division.slug ?? widget.division.id,
      eventId: widget.event.slug ?? widget.event.id,
      season: widget.season,
    );

    // Show feedback to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refreshing data from server...'),
          duration: Duration(seconds: 3),
        ),
      );
    }

    // Reload all data
    setState(() {
      _loadData();
    });
  }

  void _filterFixtures() {
    _filteredFixtures = _allFixtures.where((fixture) {
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

      // Fixture must match both filters (if they are applied)
      return matchesTeam && matchesPool;
    }).toList();
  }

  void _filterLadderStages() {
    if (_selectedPoolId != null) {
      // When filtering by pool, create filtered ladder stages with only that pool's entries
      _filteredLadderStages = _allLadderStages
          .map((stage) {
            final filteredLadder = stage.ladder.where((entry) {
              return entry.poolId?.toString() == _selectedPoolId;
            }).toList();

            return LadderStage(
              title: stage.title,
              ladder: filteredLadder,
              pools: stage.pools
                  .where((pool) => pool.id.toString() == _selectedPoolId)
                  .toList(),
            );
          })
          .where((stage) => stage.ladder.isNotEmpty)
          .toList();
    } else {
      // No pool filter, create separate ladder stages for each pool
      _filteredLadderStages = [];

      for (final stage in _allLadderStages) {
        for (final pool in stage.pools) {
          final poolLadder = stage.ladder.where((entry) {
            return entry.poolId == pool.id;
          }).toList();

          if (poolLadder.isNotEmpty) {
            _filteredLadderStages.add(LadderStage(
              title: pool.title, // Use pool name as title
              ladder: poolLadder,
              pools: [pool],
            ));
          }
        }
      }
    }
  }

  void _onTeamSelected(String? teamId) {
    setState(() {
      _selectedTeamId = teamId;
      _filterFixtures();
      _filterLadderStages();
    });
  }

  void _onPoolSelected(String? poolId) {
    setState(() {
      _selectedPoolId = (poolId == 'all_pools') ? null : poolId;
      // Only clear team selection when selecting a specific pool, not when unselecting
      if (poolId != null && poolId != 'all_pools' && _selectedTeamId != null) {
        // Check if the selected team has matches in the new pool
        final teamHasMatchesInPool = _allFixtures.any((fixture) {
          final isTeamMatch = fixture.homeTeamId == _selectedTeamId ||
              fixture.awayTeamId == _selectedTeamId;
          final isInPool = fixture.poolId?.toString() == poolId;
          return isTeamMatch && isInPool;
        });

        // Only clear team selection if team has no matches in this pool
        if (!teamHasMatchesInPool) {
          _selectedTeamId = null;
        }
      }
      _filterFixtures();
      _filterLadderStages();
    });
  }

  /// Get teams available for the currently selected pool (or all teams if no pool selected)
  List<Team> _getAvailableTeams(List<Team> allTeams) {
    if (_selectedPoolId == null) return allTeams;

    // Get team IDs that are in the selected pool based on fixtures
    final teamIdsInPool = <String>{};
    for (final fixture in _allFixtures) {
      if (fixture.poolId?.toString() == _selectedPoolId) {
        teamIdsInPool.add(fixture.homeTeamId);
        teamIdsInPool.add(fixture.awayTeamId);
      }
    }

    return allTeams.where((team) => teamIdsInPool.contains(team.id)).toList();
  }

  /// Check if any pools exist in the ladder stages
  bool _hasAnyPools() {
    return _allLadderStages.any((stage) => stage.pools.isNotEmpty);
  }

  /// Build pool dropdown items grouped by stage
  List<DropdownMenuItem<String>> _buildPoolDropdownItems() {
    final items = <DropdownMenuItem<String>>[];

    for (final stage in _allLadderStages) {
      if (stage.pools.isNotEmpty) {
        // Add stage header (non-selectable) with unique value
        items.add(DropdownMenuItem<String>(
          value: 'header_${stage.title}',
          enabled: false,
          child: Text(
            stage.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: FITColors.darkGrey,
            ),
          ),
        ));

        // Add pools for this stage
        for (final pool in stage.pools) {
          items.add(DropdownMenuItem<String>(
            value: pool.id.toString(),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(pool.title),
            ),
          ));
        }
      }
    }

    return items;
  }

  /// Get pool title by pool ID
  String? _getPoolTitle(int? poolId) {
    if (poolId == null) return null;

    for (final stage in _allLadderStages) {
      for (final pool in stage.pools) {
        if (pool.id == poolId) {
          return pool.title;
        }
      }
    }
    return null;
  }

  /// Get all pool titles for color indexing
  List<String> _getAllPoolTitles() {
    final titles = <String>[];
    for (final stage in _allLadderStages) {
      for (final pool in stage.pools) {
        if (!titles.contains(pool.title)) {
          titles.add(pool.title);
        }
      }
    }
    return titles;
  }

  /// Get appropriate empty fixtures message based on current filter
  String _getEmptyFixturesMessage() {
    if (_selectedTeamId != null) {
      return 'No fixtures for selected team';
    } else if (_selectedPoolId != null) {
      return 'No fixtures for selected pool';
    } else {
      return 'No fixtures available';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.division.name,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${widget.event.name} ${widget.season}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: FITColors.successGreen,
        foregroundColor: FITColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload data',
            onPressed: () => _reloadData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: FITColors.white,
          unselectedLabelColor: FITColors.white.withValues(alpha: 0.7),
          indicatorColor: FITColors.white,
          tabs: const [
            Tab(text: 'Fixtures', icon: Icon(Icons.schedule)),
            Tab(text: 'Ladder', icon: Icon(Icons.leaderboard)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFixturesTab(),
          _buildLadderTab(),
        ],
      ),
    );
  }

  Widget _buildFixturesTab() {
    return FutureBuilder<List<Fixture>>(
      future: _fixturesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorView(
            'Failed to load fixtures',
            () => setState(() => _loadData()),
          );
        }

        return Column(
          children: [
            // Filter dropdowns
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Pool filter dropdown - only show if pools exist
                  if (_hasAnyPools()) ...[
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
                        ..._buildPoolDropdownItems(),
                      ],
                      onChanged: _onPoolSelected,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Team filter dropdown
                  FutureBuilder<List<Team>>(
                    future: _teamsFuture,
                    builder: (context, teamsSnapshot) {
                      if (teamsSnapshot.hasData) {
                        final allTeams = teamsSnapshot.data!;
                        final availableTeams = _getAvailableTeams(allTeams);

                        // Reset selected team if it doesn't exist in current team list
                        if (_selectedTeamId != null &&
                            !availableTeams
                                .any((team) => team.id == _selectedTeamId)) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _selectedTeamId = null;
                                _filterFixtures();
                                _filterLadderStages();
                              });
                            }
                          });
                        }

                        return DropdownButtonFormField<String>(
                          initialValue: availableTeams
                                  .any((team) => team.id == _selectedTeamId)
                              ? _selectedTeamId
                              : null,
                          decoration: InputDecoration(
                            labelText: _selectedPoolId != null
                                ? 'Filter by Team (in selected pool)'
                                : 'Filter by Team',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('All Teams'),
                            ),
                            ...(availableTeams
                                  ..sort((a, b) => a.name.compareTo(b.name)))
                                .map((team) => DropdownMenuItem<String>(
                                      value: team.id,
                                      child: Text(team.name),
                                    )),
                          ],
                          onChanged: _onTeamSelected,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            // Fixtures list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() => _loadData());
                },
                child: _filteredFixtures.isEmpty
                    ? Center(
                        child: Text(
                          _getEmptyFixturesMessage(),
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: _filteredFixtures.length,
                        itemBuilder: (context, index) {
                          final fixture = _filteredFixtures[index];
                          final poolTitle = _getPoolTitle(fixture.poolId);
                          final allPoolTitles = _getAllPoolTitles();

                          return MatchScoreCard(
                            fixture: fixture,
                            venue:
                                fixture.field.isNotEmpty ? fixture.field : null,
                            divisionName: widget.division.name,
                            poolTitle: poolTitle,
                            allPoolTitles: allPoolTitles,
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

  Widget _buildLadderTab() {
    return FutureBuilder<List<LadderStage>>(
      future: _ladderStagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorView(
            'Failed to load ladder',
            () => setState(() => _loadData()),
          );
        }

        return Column(
          children: [
            // Pool filter dropdown for ladder - only show if pools exist
            if (_hasAnyPools()) ...[
              Container(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
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
                    ..._buildPoolDropdownItems(),
                  ],
                  onChanged: _onPoolSelected,
                ),
              ),
            ],

            // Ladder content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() => _loadData());
                },
                child: _filteredLadderStages.isEmpty
                    ? const Center(
                        child: Text(
                          'No ladder data available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            // Build each stage's ladder table
                            ..._filteredLadderStages
                                .asMap()
                                .entries
                                .map((entry) {
                              final stageIndex = entry.key;
                              final stage = entry.value;
                              return _buildLadderStageSection(
                                stage,
                                showHeader: _filteredLadderStages.length > 1 &&
                                    _selectedPoolId == null,
                                isLast: stageIndex ==
                                    _filteredLadderStages.length - 1,
                              );
                            }),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLadderStageSection(LadderStage stage,
      {bool showHeader = true, bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stage header (only show if there are multiple stages)
        if (showHeader) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              stage.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: FITColors.primaryBlack,
              ),
            ),
          ),
        ],
        // Ladder table
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: 8.0,
              horizontalMargin: 8.0,
              columns: [
                const DataColumn(
                    label: Text('Team',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Container(
                        width: 24,
                        alignment: Alignment.center,
                        child: const Text('P',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    tooltip: 'Played'),
                DataColumn(
                    label: Container(
                        width: 24,
                        alignment: Alignment.center,
                        child: const Text('W',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    tooltip: 'Wins'),
                DataColumn(
                    label: Container(
                        width: 24,
                        alignment: Alignment.center,
                        child: const Text('L',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    tooltip: 'Losses'),
                DataColumn(
                    label: Container(
                        width: 24,
                        alignment: Alignment.center,
                        child: const Text('D',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    tooltip: 'Draws'),
                DataColumn(
                    label: Container(
                        width: 32,
                        alignment: Alignment.center,
                        child: const Text('+/-',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    tooltip: 'Goal Difference'),
                DataColumn(
                    label: Container(
                        width: 32,
                        alignment: Alignment.center,
                        child: const Text('%',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    tooltip: 'Percentage'),
                DataColumn(
                    label: Container(
                        width: 32,
                        alignment: Alignment.center,
                        child: const Text('Pts',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    tooltip: 'Points'),
              ],
              rows: stage.ladder.map((ladderEntry) {
                final isHighlighted = _selectedTeamId != null &&
                    ladderEntry.teamId == _selectedTeamId;

                return DataRow(
                  color: isHighlighted
                      ? WidgetStateProperty.all(
                          FITColors.accentYellow.withValues(alpha: 0.25))
                      : null,
                  cells: [
                    DataCell(
                      Text(
                        ladderEntry.teamName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(Center(child: Text('${ladderEntry.played}'))),
                    DataCell(Center(child: Text('${ladderEntry.wins}'))),
                    DataCell(Center(child: Text('${ladderEntry.losses}'))),
                    DataCell(Center(child: Text('${ladderEntry.draws}'))),
                    DataCell(
                      Center(
                        child: Text(
                          ladderEntry.goalDifferenceText,
                          style: TextStyle(
                            color: ladderEntry.goalDifference >= 0
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(
                          '${(ladderEntry.percentage ?? 0.0).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(
                          ladderEntry.points % 1 == 0
                              ? ladderEntry.points.toInt().toString()
                              : ladderEntry.points.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        // Add spacing between stages (except for the last one)
        if (!isLast && showHeader) const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildErrorView(String message, VoidCallback onRetry) {
    return Center(
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
            message,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Using mock data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
