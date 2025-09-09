import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/data_service.dart';
import '../services/competition_filter_service.dart';
import '../utils/image_utils.dart';
import '../config/config_service.dart';
import 'event_detail_view.dart';
import 'divisions_view.dart';

class CompetitionsView extends StatefulWidget {
  const CompetitionsView({super.key});

  @override
  State<CompetitionsView> createState() => _CompetitionsViewState();
}

class _CompetitionsViewState extends State<CompetitionsView> {
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _checkConfiguredCompetition();
  }

  void _checkConfiguredCompetition() {
    final config = ConfigService.config;
    if (config.api.competition != null && config.api.season != null) {
      // Navigate directly to configured competition and season
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToConfiguredCompetition(
            config.api.competition!, config.api.season!);
      });
    } else {
      // Show normal competition selection
      _eventsFuture = _loadFilteredEvents();
    }
  }

  Future<void> _navigateToConfiguredCompetition(
      String competitionSlug, String season) async {
    try {
      // Load the specific competition
      final allEvents = await DataService.getEvents();
      final targetEvent =
          allEvents.where((event) => event.slug == competitionSlug).firstOrNull;

      if (targetEvent == null) {
        throw Exception('Competition "$competitionSlug" not found');
      }

      // Load seasons for the event
      final eventWithSeasons = await DataService.loadEventSeasons(targetEvent);
      final targetSeason =
          eventWithSeasons.seasons.where((s) => s.title == season).firstOrNull;

      if (targetSeason == null) {
        throw Exception(
            'Season "$season" not found for competition "$competitionSlug"');
      }

      // Navigate directly to divisions
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DivisionsView(
              event: eventWithSeasons,
              season: season,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load configured competition: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Fallback to normal competition selection
        setState(() {
          _eventsFuture = _loadFilteredEvents();
        });
      }
    }
  }

  Future<List<Event>> _loadFilteredEvents() async {
    final allEvents = await DataService.getEvents();
    // Apply competition filtering using the new service
    return CompetitionFilterService.filterEvents(allEvents);
  }

  Widget _getCompetitionIcon(Event event) {
    final slug = event.slug;
    final competitionImage = slug != null
        ? CompetitionFilterService.getCompetitionImage(slug)
        : null;
    if (competitionImage != null) {
      // Use configured asset image
      return Container(
        width: 64,
        height: 64,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            competitionImage,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackIcon(event),
          ),
        ),
      );
    }

    // Try network image as fallback
    if (event.logoUrl.isNotEmpty) {
      return Container(
        width: 64,
        height: 64,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: ImageUtils.buildImage(
            event.logoUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackIcon(event),
          ),
        ),
      );
    }

    return _buildFallbackIcon(event);
  }

  Widget _buildFallbackIcon(Event event) {
    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          event.name.length >= 3
              ? event.name.substring(0, 3).toUpperCase()
              : event.name.toUpperCase(),
          style: TextStyle(
            color: Colors.blue[800],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ConfigService.config;

    // If we have a configured competition, show loading while navigating
    if (config.api.competition != null && config.api.season != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Events'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder<List<Event>>(
          future: _eventsFuture,
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
                      'Failed to load competitions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your internet connection and try again.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _eventsFuture = _loadFilteredEvents();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final events = snapshot.data ?? [];

            return RefreshIndicator(
              onRefresh: () async {
                DataService.clearCache();
                setState(() {
                  _eventsFuture = _loadFilteredEvents();
                });
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      leading: _getCompetitionIcon(event),
                      title: Text(
                        event.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailView(event: event),
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
    );
  }
}
