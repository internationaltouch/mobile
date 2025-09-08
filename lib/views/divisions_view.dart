import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/division.dart';
import '../services/data_service.dart';
import '../services/competition_filter_service.dart';
import 'fixtures_results_view.dart';

class DivisionsView extends StatefulWidget {
  final Event event;
  final String season;

  const DivisionsView({
    super.key,
    required this.event,
    required this.season,
  });

  @override
  State<DivisionsView> createState() => _DivisionsViewState();
}

class _DivisionsViewState extends State<DivisionsView> {
  late Future<List<Division>> _divisionsFuture;

  @override
  void initState() {
    super.initState();
    _divisionsFuture = _loadFilteredDivisions();
  }
  
  Future<List<Division>> _loadFilteredDivisions() async {
    final allDivisions = await DataService.getDivisions(
        widget.event.slug ?? widget.event.id, widget.season);
    // Apply division filtering
    return CompetitionFilterService.filterDivisions(widget.event, widget.season, allDivisions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.name,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${widget.season} Season',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<List<Division>>(
                future: _divisionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
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
                            'Failed to load divisions',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Using mock data',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _divisionsFuture = DataService.getDivisions(
                                    widget.event.slug ?? widget.event.id,
                                    widget.season);
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final divisions = snapshot.data ?? [];

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _divisionsFuture = DataService.getDivisions(
                            widget.event.slug ?? widget.event.id,
                            widget.season);
                      });
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      itemCount: divisions.length,
                      itemBuilder: (context, index) {
                        final division = divisions[index];
                        final color = _parseHexColor(division.color);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            leading: CircleAvatar(
                              backgroundColor: color,
                              child: const Icon(
                                Icons.category,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              division.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FixturesResultsView(
                                    event: widget.event,
                                    season: widget.season,
                                    division: division,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseHexColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.blue; // Fallback color
    }
  }
}
