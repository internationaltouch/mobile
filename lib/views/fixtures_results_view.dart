import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/division.dart';
import '../models/fixture.dart';
import '../models/ladder_entry.dart';
import '../services/data_service.dart';
import '../widgets/match_score_card.dart';

class FixturesResultsView extends StatefulWidget {
  final Event event;
  final String season;
  final Division division;

  const FixturesResultsView({
    super.key,
    required this.event,
    required this.season,
    required this.division,
  });

  @override
  State<FixturesResultsView> createState() => _FixturesResultsViewState();
}

class _FixturesResultsViewState extends State<FixturesResultsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Fixture>> _fixturesFuture;
  late Future<List<LadderEntry>> _ladderFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    _fixturesFuture = DataService.getFixtures(
      widget.division.slug ?? widget.division.id,
      eventId: widget.event.slug ?? widget.event.id,
      season: widget.season,
    );
    _ladderFuture = DataService.getLadder(
      widget.division.slug ?? widget.division.id,
      eventId: widget.event.slug ?? widget.event.id,
      season: widget.season,
    );
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
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

        final fixtures = snapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _loadData());
          },
          child: fixtures.isEmpty
              ? const Center(
                  child: Text(
                    'No fixtures available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: fixtures.length,
                  itemBuilder: (context, index) {
                    final fixture = fixtures[index];
                    return MatchScoreCard(
                      fixture: fixture,
                      // You can add location data here when available
                      // homeTeamLocation: 'Dharug',
                      // awayTeamLocation: 'Wurundjeri',
                      venue: fixture.field.isNotEmpty ? fixture.field : null,
                      // venueLocation: 'Sydney', // Add when available
                    );
                  },
                ),
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
          child: ladder.isEmpty
              ? const Center(
                  child: Text(
                    'No ladder data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
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
