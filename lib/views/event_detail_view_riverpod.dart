import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pure_riverpod_providers.dart';
import '../models/event.dart';
import '../models/season.dart';
import '../services/competition_filter_service.dart';
import 'divisions_view_riverpod.dart';

class EventDetailViewRiverpod extends ConsumerStatefulWidget {
  final Event event;

  const EventDetailViewRiverpod({super.key, required this.event});

  @override
  ConsumerState<EventDetailViewRiverpod> createState() => _EventDetailViewRiverpodState();
}

class _EventDetailViewRiverpodState extends ConsumerState<EventDetailViewRiverpod> {
  Season? selectedSeason;

  @override
  Widget build(BuildContext context) {
    // Use Riverpod provider for seasons - no DataService needed!
    final seasonsAsync = ref.watch(seasonsProvider(widget.event.slug ?? widget.event.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
      ),
      body: seasonsAsync.when(
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
                  ref.invalidate(seasonsProvider(widget.event.slug ?? widget.event.id));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (seasons) {
          // Apply season filtering
          final filteredSeasons = CompetitionFilterService.filterSeasons(widget.event, seasons);

          if (filteredSeasons.isEmpty) {
            return const Center(
              child: Text('No seasons available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(seasonsProvider(widget.event.slug ?? widget.event.id));
              await ref.read(seasonsProvider(widget.event.slug ?? widget.event.id).future);
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
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          season.title.length >= 2 
                              ? season.title.substring(0, 2).toUpperCase()
                              : season.title.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}