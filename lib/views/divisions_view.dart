import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/division.dart';
import '../services/data_service.dart';
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
    _divisionsFuture = DataService.getDivisions(
        widget.event.slug ?? widget.event.id, widget.season);
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      itemCount: divisions.length,
                      itemBuilder: (context, index) {
                        final division = divisions[index];
                        final color = _parseHexColor(division.color);

                        return GestureDetector(
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
                          child: Card(
                            elevation: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: color,
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    division.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
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
