import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pure_riverpod_providers.dart';
import '../models/event.dart';
import '../models/division.dart';
import '../widgets/match_score_card.dart';

class FixturesResultsViewRiverpod extends ConsumerStatefulWidget {
  final Event event;
  final String season;
  final Division division;

  const FixturesResultsViewRiverpod({
    super.key,
    required this.event,
    required this.season,
    required this.division,
  });

  @override
  ConsumerState<FixturesResultsViewRiverpod> createState() => _FixturesResultsViewRiverpodState();
}

class _FixturesResultsViewRiverpodState extends ConsumerState<FixturesResultsViewRiverpod>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          children: [
            Text(
              widget.division.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.event.name} - ${widget.season}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Fixtures'),
            Tab(text: 'Ladder'),
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

  Widget _buildFixturesTab(({String eventId, String seasonSlug, String divisionId}) params) {
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

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(fixturesProvider(params));
            ref.invalidate(teamsProvider(params));
            await ref.read(fixturesProvider(params).future);
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            itemCount: fixtures.length,
            itemBuilder: (context, index) {
              final fixture = fixtures[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: MatchScoreCard(
                  fixture: fixture,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLadderTab(({String eventId, String seasonSlug, String divisionId}) params) {
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
                    DataColumn(label: Text('Pos', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Team', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('P', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('W', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('D', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('L', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('GF', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('GA', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('GD', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Pts', style: TextStyle(fontWeight: FontWeight.bold))),
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
                                child: Container(), // Placeholder for entity images
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