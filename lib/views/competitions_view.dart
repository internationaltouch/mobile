import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/data_service.dart';
import '../utils/image_utils.dart';
import '../theme/fit_colors.dart';
import 'event_detail_view.dart';

/*
 * COMPETITION CONFIGURATION GUIDE
 * 
 * To add static images for competitions:
 * 
 * 1. Add image files to: assets/images/competitions/
 *    - Use PNG format for best quality
 *    - Square aspect ratio recommended (e.g., 512x512px)
 *    - File naming: use descriptive names (e.g., world_cup.png)
 * 
 * 2. Update pubspec.yaml to include the assets:
 *    flutter:
 *      assets:
 *        - assets/images/competitions/
 * 
 * 3. Add the competition slug and image path to _competitionImages map below
 *    Example: 'my-competition-slug': 'assets/images/competitions/my_image.png'
 * 
 * 4. Add the competition slug to the appropriate filtering list (see below)
 *    Example: 'my-competition-slug'
 * 
 * Competition filtering (choose ONE mode):
 * - INCLUDE MODE: Add slugs to _includeCompetitionSlugs to show ONLY those competitions
 * - EXCLUDE MODE: Add slugs to _excludeCompetitionSlugs to HIDE those competitions
 * - NO FILTERING: Leave both arrays empty to show ALL competitions from API
 * 
 * IMPORTANT: Do not use both include and exclude modes simultaneously!
 */

class CompetitionsView extends StatefulWidget {
  const CompetitionsView({super.key});

  @override
  State<CompetitionsView> createState() => _CompetitionsViewState();
}

class _CompetitionsViewState extends State<CompetitionsView> {
  late Future<List<Event>> _eventsFuture;

  // Configuration: Competition filtering (choose ONE mode)

  // MODE 1: INCLUDE - Only show competitions with these slugs (leave empty [] to show ALL)
  static const List<String> _includeCompetitionSlugs = [
    // 'world-cup',
    // 'atlantic-youth-touch-cup',
    // 'other-events',
  ];

  // MODE 2: EXCLUDE - Hide competitions with these slugs (leave empty [] to exclude nothing)
  static const List<String> _excludeCompetitionSlugs = [
    'home-nations',
    'mainland-cup',
    'asian-cup',
    'test-matches',
    'pacific-games',
    // Add specific slugs here to HIDE these competitions
  ];

  // Configuration: Static image resources by slug
  static const Map<String, String> _competitionImages = {
    'fit-world-cup-2023': 'assets/images/competitions/world_cup.png',
    'european-championships': 'assets/images/competitions/european_champs.png',
    'asia-pacific-championships': 'assets/images/competitions/asia_pacific.png',
    // Add more competition images here as needed
    // Format: 'slug': 'assets/images/competitions/filename.png'
  };

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadFilteredEvents();
  }

  Future<List<Event>> _loadFilteredEvents() async {
    final allEvents = await DataService.getEvents();

    // Validate configuration: only one filtering mode should be used
    if (_includeCompetitionSlugs.isNotEmpty &&
        _excludeCompetitionSlugs.isNotEmpty) {
      throw Exception(
          'Configuration Error: Cannot use both include and exclude filtering simultaneously. '
          'Use either _includeCompetitionSlugs OR _excludeCompetitionSlugs, not both.');
    }

    // Apply filtering based on the active mode
    if (_includeCompetitionSlugs.isNotEmpty) {
      // INCLUDE mode: Only show competitions with specified slugs
      return allEvents.where((event) {
        return event.slug != null &&
            _includeCompetitionSlugs.contains(event.slug);
      }).toList();
    } else if (_excludeCompetitionSlugs.isNotEmpty) {
      // EXCLUDE mode: Hide competitions with specified slugs
      return allEvents.where((event) {
        return event.slug == null ||
            !_excludeCompetitionSlugs.contains(event.slug);
      }).toList();
    } else {
      // No filtering: show all competitions
      return allEvents;
    }
  }

  Widget _getCompetitionIcon(Event event) {
    final slug = event.slug;
    if (slug != null && _competitionImages.containsKey(slug)) {
      // Use static asset image
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
            _competitionImages[slug]!,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: FITColors.successGreen,
        foregroundColor: FITColors.white,
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
