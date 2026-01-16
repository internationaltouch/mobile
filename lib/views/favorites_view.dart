import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pure_riverpod_providers.dart';
import '../models/favorite.dart';
import '../models/event.dart';
import '../models/division.dart';
import '../views/event_detail_view_riverpod.dart';
import '../views/divisions_view_riverpod.dart';
import '../views/fixtures_results_view_riverpod.dart';
import '../config/config_service.dart';

class FavoritesView extends ConsumerWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'clear') {
                _showClearConfirmationDialog(context, ref);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Failed to load favorites',
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
                  ref.invalidate(favoritesProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (favorites) {
          if (favorites.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(favoritesProvider);
              await ref.read(favoritesProvider.future);
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: _buildFavoriteIcon(favorite),
                    title: Text(
                      favorite.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: favorite.subtitle != null
                        ? Text(favorite.subtitle!)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await ref
                                .read(favoritesNotifierProvider.notifier)
                                .removeFavorite(favorite.id);
                          },
                        ),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                    onTap: () => _navigateToFavorite(context, favorite),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Favorites Yet',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add competitions, seasons, or divisions to your favorites for quick access.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Find the events tab index dynamically
                final enabledTabs = ConfigService.config.navigation.enabledTabs;
                final eventsTabIndex = enabledTabs.indexWhere(
                  (tab) => tab.id == 'events',
                );
                if (eventsTabIndex != -1) {
                  context.switchToTab(eventsTabIndex);
                }
              },
              child: const Text('Browse Competitions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteIcon(Favorite favorite) {
    IconData iconData;
    Color color;

    switch (favorite.type) {
      case FavoriteType.event:
        iconData = Icons.emoji_events;
        color = Colors.blue;
        break;
      case FavoriteType.season:
        iconData = Icons.emoji_events;
        color = Colors.green;
        break;
      case FavoriteType.division:
        iconData = Icons.category;
        if (favorite.color != null) {
          try {
            color = Color(int.parse(favorite.color!.replaceFirst('#', '0xFF')));
          } catch (e) {
            color = Colors.orange;
          }
        } else {
          color = Colors.orange;
        }
        break;
      case FavoriteType.team:
        iconData = Icons.group;
        color = Colors.purple;
        break;
    }

    return CircleAvatar(
      backgroundColor: color,
      child: Icon(iconData, color: Colors.white, size: 20),
    );
  }

  int _getEventsTabIndex() {
    final enabledTabs = ConfigService.config.navigation.enabledTabs;
    return enabledTabs.indexWhere((tab) => tab.id == 'events');
  }

  void _navigateToFavorite(BuildContext context, Favorite favorite) {
    // This is where the stack clearing magic happens
    // We'll navigate to the appropriate tab and screen based on favorite type

    final eventsTabIndex = _getEventsTabIndex();
    if (eventsTabIndex == -1) return; // No events tab configured

    switch (favorite.type) {
      case FavoriteType.event:
        // Navigate to event detail
        final event = Event(
          id: favorite.eventId,
          name: favorite.title,
          logoUrl: favorite.logoUrl ?? '',
          seasons: [], // Will be loaded by the view
          description: '',
          slug: favorite.eventSlug,
          seasonsLoaded: false,
        );
        context.switchToTabAndNavigate(
          eventsTabIndex,
          EventDetailViewRiverpod(event: event),
        );
        break;

      case FavoriteType.season:
        // Navigate to divisions view
        final event = Event(
          id: favorite.eventId,
          name: favorite.title,
          logoUrl: favorite.logoUrl ?? '',
          seasons: [], // Will be loaded by the view
          description: '',
          slug: favorite.eventSlug,
          seasonsLoaded: false,
        );
        context.switchToTabAndNavigate(
          eventsTabIndex,
          DivisionsViewRiverpod(event: event, season: favorite.season!),
        );
        break;

      case FavoriteType.division:
        // Navigate to fixtures/results view
        final event = Event(
          id: favorite.eventId,
          name: favorite.eventName ?? 'Unknown Event',
          logoUrl: favorite.logoUrl ?? '',
          seasons: [],
          description: '',
          slug: favorite.eventSlug,
          seasonsLoaded: false,
        );
        final division = Division(
          id: favorite.divisionId!,
          name: favorite.title,
          eventId: favorite.eventId,
          season: favorite.season!,
          color: favorite.color ?? '#2196F3',
          slug: favorite.divisionSlug,
        );
        context.switchToTabAndNavigate(
          eventsTabIndex,
          FixturesResultsViewRiverpod(
            event: event,
            season: favorite.season!,
            division: division,
          ),
        );
        break;

      case FavoriteType.team:
        // Navigate to fixtures/results view with team pre-selected
        final event = Event(
          id: favorite.eventId,
          name: favorite.eventName ?? 'Unknown Event',
          logoUrl: favorite.logoUrl ?? '',
          seasons: [],
          description: '',
          slug: favorite.eventSlug,
          seasonsLoaded: false,
        );
        final division = Division(
          id: favorite.divisionId!,
          name: favorite.divisionName ?? 'Unknown Division',
          eventId: favorite.eventId,
          season: favorite.season!,
          color: favorite.color ?? '#2196F3',
          slug: favorite.divisionSlug,
        );
        context.switchToTabAndNavigate(
          eventsTabIndex,
          FixturesResultsViewRiverpod(
            event: event,
            season: favorite.season!,
            division: division,
            initialTeamId: favorite.teamId, // Pre-select the team
          ),
        );
        break;
    }
  }

  void _showClearConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Favorites'),
          content: const Text(
            'Are you sure you want to remove all favorites? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await ref
                    .read(favoritesNotifierProvider.notifier)
                    .clearFavorites();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All favorites cleared')),
                  );
                }
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}
