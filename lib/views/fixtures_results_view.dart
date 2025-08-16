import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/division.dart';
import '../models/fixture.dart';
import '../models/ladder_entry.dart';
import '../services/data_service.dart';

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
  late List<Fixture> fixtures;
  late List<LadderEntry> ladder;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fixtures = DataService.getFixtures(widget.division.id);
    ladder = DataService.getLadder(widget.division.id);
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
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          fixtures = DataService.getFixtures(widget.division.id);
        });
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: fixtures.length,
        itemBuilder: (context, index) {
          final fixture = fixtures[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${fixture.homeTeamName} vs ${fixture.awayTeamName}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (fixture.isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Text(
                            'FINAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  if (fixture.isCompleted && fixture.resultText.isNotEmpty)
                    Text(
                      'Result: ${fixture.resultText}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      'Scheduled',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        _formatDateTime(fixture.dateTime),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        fixture.field,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLadderTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          ladder = DataService.getLadder(widget.division.id);
        });
      },
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
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(Text('${ladderEntry.played}')),
                  DataCell(Text('${ladderEntry.wins}')),
                  DataCell(Text('${ladderEntry.draws}')),
                  DataCell(Text('${ladderEntry.losses}')),
                  DataCell(
                    Text(
                      '${ladderEntry.points}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return 'Today ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow ${_formatTime(dateTime)}';
    } else if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month} ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}