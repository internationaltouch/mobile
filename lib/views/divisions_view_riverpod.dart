import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pure_riverpod_providers.dart';
import '../models/event.dart';
import 'fixtures_results_view_riverpod.dart';

class DivisionsViewRiverpod extends ConsumerWidget {
  final Event event;
  final String season;

  const DivisionsViewRiverpod({
    super.key,
    required this.event,
    required this.season,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find the season slug - for now using season title as slug
    final seasonSlug = season; // This should be converted to slug format if needed
    
    // Use Riverpod provider for divisions - no DataService!
    final divisionsAsync = ref.watch(divisionsProvider((
      eventId: event.id,
      seasonSlug: seasonSlug,
    )));

    return Scaffold(
      appBar: AppBar(
        title: Text('${event.name} - $season'),
      ),
      body: divisionsAsync.when(
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
                'Failed to load divisions',
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
                  ref.invalidate(divisionsProvider((
                    eventId: event.id,
                    seasonSlug: seasonSlug,
                  )));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (divisions) {
          if (divisions.isEmpty) {
            return const Center(
              child: Text('No divisions available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(divisionsProvider((
                eventId: event.id,
                seasonSlug: seasonSlug,
              )));
              await ref.read(divisionsProvider((
                eventId: event.id,
                seasonSlug: seasonSlug,
              )).future);
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: divisions.length,
              itemBuilder: (context, index) {
                final division = divisions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(int.parse(division.color.replaceFirst('#', '0xFF'))),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          division.name.length >= 2 
                              ? division.name.substring(0, 2).toUpperCase()
                              : division.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
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
                          builder: (context) => FixturesResultsViewRiverpod(
                            event: event,
                            season: season,
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
    );
  }
}