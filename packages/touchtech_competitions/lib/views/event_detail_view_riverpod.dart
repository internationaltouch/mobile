import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pure_riverpod_providers.dart';
import '../models/event.dart';
import '../models/season.dart';
import 'package:touchtech_favorites/models/favorite.dart';
import '../services/competition_filter_service.dart';
import 'package:touchtech_core/utils/image_utils.dart';
import 'package:touchtech_favorites/widgets/favorite_button.dart';
import 'divisions_view_riverpod.dart';

class EventDetailViewRiverpod extends ConsumerStatefulWidget {
  final Event event;

  const EventDetailViewRiverpod({super.key, required this.event});

  @override
  ConsumerState<EventDetailViewRiverpod> createState() =>
      _EventDetailViewRiverpodState();
}

class _EventDetailViewRiverpodState
    extends ConsumerState<EventDetailViewRiverpod> {
  Season? selectedSeason;

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
    // Use Riverpod provider for seasons - no DataService needed!
    final seasonsAsync =
        ref.watch(seasonsProvider(widget.event.slug ?? widget.event.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
        actions: [
          FavoriteButton(
            favorite: Favorite.fromEvent(
              widget.event.id,
              widget.event.slug ?? widget.event.id,
              widget.event.name,
            ),
            favoriteColor: Colors.white,
          ),
        ],
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
              child: seasonsAsync.when(
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
                        'Failed to load seasons',
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
                          // Riverpod refresh - no cache clearing needed
                          ref.invalidate(seasonsProvider(
                              widget.event.slug ?? widget.event.id));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (seasons) {
                  // Apply season filtering
                  final filteredSeasons =
                      CompetitionFilterService.filterSeasons(
                          widget.event, seasons);

                  if (filteredSeasons.isEmpty) {
                    return const Center(
                      child: Text('No seasons available'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(seasonsProvider(
                          widget.event.slug ?? widget.event.id));
                      await ref.read(
                          seasonsProvider(widget.event.slug ?? widget.event.id)
                              .future);
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filteredSeasons.length,
                      itemBuilder: (context, index) {
                        final season = filteredSeasons[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DivisionsViewRiverpod(
                                    event: widget.event,
                                    season: season.title,
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
}
