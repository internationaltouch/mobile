import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/season.dart';
import '../services/data_service.dart';
import '../services/competition_filter_service.dart';
import '../utils/image_utils.dart';
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
    Event eventToFilter;

    if (widget.event.seasonsLoaded) {
      eventToFilter = widget.event;
    } else {
      // Load seasons lazily
      eventToFilter = await DataService.loadEventSeasons(widget.event);
    }

    // Apply season filtering
    final filteredSeasons = CompetitionFilterService.filterSeasons(
        eventToFilter, eventToFilter.seasons);
    final filteredEvent = Event(
      id: eventToFilter.id,
      name: eventToFilter.name,
      logoUrl: eventToFilter.logoUrl,
      seasons: filteredSeasons,
      description: eventToFilter.description,
      slug: eventToFilter.slug,
      seasonsLoaded: true,
    );

    // Auto-select if only one season after filtering
    if (filteredEvent.seasons.length == 1) {
      selectedSeason = filteredEvent.seasons.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToDivisions();
      });
    }

    return filteredEvent;
  }

  void _navigateToDivisions() {
    if (selectedSeason != null) {
      Navigator.push(
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

  Widget _getCompetitionIcon(Event event) {
    final slug = event.slug;
    final competitionImage = slug != null
        ? CompetitionFilterService.getCompetitionImage(slug)
        : null;
    if (competitionImage != null) {
      // Use configured asset image
      return Image.asset(
        competitionImage,
        height: 120,
        width: 120,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackIcon(event);
        },
      );
    }

    // Try network image as fallback
    if (event.logoUrl.isNotEmpty) {
      return ImageUtils.buildImage(
        event.logoUrl,
        height: 120,
        width: 120,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackIcon(event);
        },
      );
    }

    return _buildFallbackIcon(event);
  }

  Widget _buildFallbackIcon(Event event) {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Center(
        child: Text(
          event.name.length >= 3
              ? event.name.substring(0, 3).toUpperCase()
              : event.name.toUpperCase(),
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: _getCompetitionIcon(widget.event),
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
                            child: const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
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
