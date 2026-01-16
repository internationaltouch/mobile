import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pure_riverpod_providers.dart';
import '../models/event.dart';
import '../services/competition_filter_service.dart';
import 'package:touchtech_news/services/news_api_service.dart';
import 'package:touchtech_core/utils/image_utils.dart';
import 'package:touchtech_core/config/config_service.dart';
import 'event_detail_view_riverpod.dart';
import 'divisions_view_riverpod.dart';
import 'fixtures_results_view_riverpod.dart';

class CompetitionsViewRiverpod extends ConsumerStatefulWidget {
  const CompetitionsViewRiverpod({super.key});

  @override
  ConsumerState<CompetitionsViewRiverpod> createState() =>
      _CompetitionsViewRiverpodState();
}

class _CompetitionsViewRiverpodState
    extends ConsumerState<CompetitionsViewRiverpod> {
  @override
  void initState() {
    super.initState();
    // Riverpod providers load automatically - no manual initialization needed!
  }

  String _getErrorMessage(Object error) {
    if (error is NetworkUnavailableException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    } else if (error is ApiErrorException) {
      return 'Unable to load competitions. Error: ${error.message}';
    }
    return 'Failed to load competitions. Please try again.';
  }

  Future<void> _navigateToConfiguredCompetition(
      List<Event> events, String competitionSlug, String season,
      {String? divisionSlug}) async {
    try {
      final targetEvent =
          events.where((event) => event.slug == competitionSlug).firstOrNull;

      if (targetEvent == null) {
        throw Exception('Competition "$competitionSlug" not found');
      }

      if (!mounted) return;

      // Navigate to division level if specified - requires fetching division data
      if (divisionSlug != null) {
        // Fetch divisions to get the Division object
        final divisions = await ref.read(divisionsProvider(
          (eventId: targetEvent.id, seasonSlug: season),
        ).future);

        final targetDivision = divisions
            .where((div) => div.slug == divisionSlug)
            .firstOrNull;

        if (targetDivision == null) {
          throw Exception('Division "$divisionSlug" not found');
        }

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => FixturesResultsViewRiverpod(
              event: targetEvent,
              season: season,
              division: targetDivision,
            ),
          ),
        );
      } else {
        // Navigate to season/divisions level
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DivisionsViewRiverpod(
              event: targetEvent,
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
      }
    }
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

    // Check for initial navigation configuration
    // Priority: navigation.initialNavigation > api.competition/season (legacy)
    final initialNav = config.navigation.initialNavigation;
    String? competitionSlug;
    String? seasonSlug;
    String? divisionSlug;

    if (initialNav != null && initialNav.shouldNavigateToSeason) {
      competitionSlug = initialNav.competition;
      seasonSlug = initialNav.season;
      divisionSlug = initialNav.division;
    } else if (config.api.competition != null && config.api.season != null) {
      // Legacy configuration support
      competitionSlug = config.api.competition;
      seasonSlug = config.api.season;
    }

    final hasDeepLink = competitionSlug != null && seasonSlug != null;

    // Use pure Riverpod provider - no custom state management needed!
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: eventsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  error is NetworkUnavailableException
                      ? Icons.cloud_off
                      : Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  error is NetworkUnavailableException
                      ? 'No Internet Connection'
                      : 'Unable to Load Competitions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    _getErrorMessage(error),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Riverpod refresh - invalidates cache and refetches
                    ref.invalidate(eventsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (events) {
            // Handle deep link navigation (initial navigation to specific competition/season/division)
            if (hasDeepLink) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _navigateToConfiguredCompetition(
                  events,
                  competitionSlug!,
                  seasonSlug!,
                  divisionSlug: divisionSlug,
                );
              });
              return const Center(child: CircularProgressIndicator());
            }

            // Normal events list - pure Riverpod data with automatic caching!
            return RefreshIndicator(
              onRefresh: () async {
                // Riverpod refresh pattern - much cleaner than custom cache clearing
                ref.invalidate(eventsProvider);
                await ref.read(eventsProvider.future);
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
                            builder: (context) =>
                                EventDetailViewRiverpod(event: event),
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
