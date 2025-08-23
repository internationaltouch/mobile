import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/division.dart';
import '../models/fixture.dart';
import '../models/ladder_entry.dart';
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
  late Future<List<LadderEntry>> _ladderFuture;
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
    _ladderFuture = DataService.getLadder(
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
    return FutureBuilder<List<LadderEntry>>(
      future: _ladderFuture,
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

        final ladder = snapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _loadData());
          },
          child: Column(
            children: [
              // Warning banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: FITColors.accentYellow,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      color: FITColors.primaryBlack,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            color: FITColors.primaryBlack,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Warning: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'this data is being calculated in the app and may have errors, see the FIT website for accurate ladder information.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Ladder content
              Expanded(
                child: ladder.isEmpty
                    ? const Center(
                        child: Text(
                          'No ladder data available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Position')),
                                DataColumn(label: Text('Team')),
                                DataColumn(label: Text('P')),
                                DataColumn(label: Text('W')),
                                DataColumn(label: Text('D')),
                                DataColumn(label: Text('L')),
                                DataColumn(label: Text('Pts')),
                                DataColumn(label: Text('GD')),
                              ],
                              rows: ladder.asMap().entries.map((entry) {
                                final index = entry.key;
                                final ladderEntry = entry.value;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: _getPositionColor(index),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        ladderEntry.teamName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    DataCell(Text('${ladderEntry.played}')),
                                    DataCell(Text('${ladderEntry.wins}')),
                                    DataCell(Text('${ladderEntry.draws}')),
                                    DataCell(Text('${ladderEntry.losses}')),
                                    DataCell(
                                      Text(
                                        '${ladderEntry.points}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        ladderEntry.goalDifferenceText,
                                        style: TextStyle(
                                          color: ladderEntry.goalDifference >= 0
                                              ? Colors.green[700]
                                              : Colors.red[700],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
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

  Color _getPositionColor(int position) {
    switch (position) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey[400]!; // Silver
      case 2:
        return Colors.orange[700]!; // Bronze
      default:
        return Colors.blue;
    }
  }
}
