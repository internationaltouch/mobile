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
  late List<Division> divisions;

  @override
  void initState() {
    super.initState();
    divisions = DataService.getDivisions(widget.event.id, widget.season);
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
            Text(
              'Select Division',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      elevation: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color,
                              color.withOpacity(0.7),
                            ],
                          ),
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