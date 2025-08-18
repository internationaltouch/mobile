import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/season.dart';
import '../services/data_service.dart';
import 'divisions_view.dart';

class EventDetailView extends StatefulWidget {
  final Event event;

  const EventDetailView({super.key, required this.event});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  Season? selectedSeason;
  late Future<Event> _eventFuture;

  @override
  void initState() {
    super.initState();
    // Load seasons if not already loaded
    _eventFuture = _loadEventSeasons();
  }

  Future<Event> _loadEventSeasons() async {
    if (widget.event.seasonsLoaded) {
      // Auto-select if only one season and already loaded
      if (widget.event.seasons.length == 1) {
        selectedSeason = widget.event.seasons.first;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToDivisions();
        });
      }
      return widget.event;
    }

    // Load seasons lazily
    final updatedEvent = await DataService.loadEventSeasons(widget.event);

    // Auto-select if only one season after loading
    if (updatedEvent.seasons.length == 1) {
      selectedSeason = updatedEvent.seasons.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToDivisions();
      });
    }

    return updatedEvent;
  }

  void _navigateToDivisions() {
    if (selectedSeason != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DivisionsView(
            event: widget.event,
            season: selectedSeason!.title,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                widget.event.logoUrl,
                height: 120,
                width: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: Text(
                        widget.event.name.substring(0, 3).toUpperCase(),
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select a season to view divisions and results',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<Event>(
                future: _eventFuture,
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
                            'Failed to load seasons',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please try again later.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _eventFuture = _loadEventSeasons();
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final event = snapshot.data!;

                  if (event.seasons.isEmpty) {
                    return const Center(
                      child: Text(
                        'No seasons available for this competition.',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: event.seasons.length,
                    itemBuilder: (context, index) {
                      final season = event.seasons[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: Text(
                              season.title.length > 4
                                  ? season.title.substring(0, 4)
                                  : season.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            season.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            selectedSeason = season;
                            _navigateToDivisions();
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
