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
  List<Fixture> _allFixtures = [];
  List<Fixture> _filteredFixtures = [];

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
    );
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
    if (_selectedTeamId == null) {
      _filteredFixtures = _allFixtures;
    } else {
      _filteredFixtures = _allFixtures.where((fixture) {
        return fixture.homeTeamId == _selectedTeamId ||
            fixture.awayTeamId == _selectedTeamId;
      }).toList();
    }
  }

  void _onTeamSelected(String? teamId) {
    setState(() {
      _selectedTeamId = teamId;
      _filterFixtures();
    });
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
            // Team filter dropdown
            Container(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<Team>>(
                future: _teamsFuture,
                builder: (context, teamsSnapshot) {
                  if (teamsSnapshot.hasData) {
                    final teams = teamsSnapshot.data!;

                    // Reset selected team if it doesn't exist in current team list
                    if (_selectedTeamId != null &&
                        !teams.any((team) => team.id == _selectedTeamId)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _selectedTeamId = null;
                            _filterFixtures();
                          });
                        }
                      });
                    }

                    return DropdownButtonFormField<String>(
                      initialValue:
                          teams.any((team) => team.id == _selectedTeamId)
                              ? _selectedTeamId
                              : null,
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
                  }
                  return const SizedBox.shrink();
                },
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
                          _selectedTeamId == null
                              ? 'No fixtures available'
                              : 'No fixtures for selected team',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: _filteredFixtures.length,
                        itemBuilder: (context, index) {
                          final fixture = _filteredFixtures[index];
                          return MatchScoreCard(
                            fixture: fixture,
                            venue:
                                fixture.field.isNotEmpty ? fixture.field : null,
                            divisionName: widget.division.name,
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

        final ladderStages = snapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _loadData());
          },
          child: ladderStages.isEmpty
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
                      ...ladderStages.asMap().entries.map((entry) {
                        final stageIndex = entry.key;
                        final stage = entry.value;
                        return _buildLadderStageSection(
                          stage,
                          showHeader: ladderStages.length > 1,
                          isLast: stageIndex == ladderStages.length - 1,
                        );
                      }),
                    ],
                  ),
                ),
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
                      ? WidgetStateProperty.all(FITColors.accentYellow.withValues(alpha: 0.25))
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
