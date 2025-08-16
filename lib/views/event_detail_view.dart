import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/season.dart';
import 'divisions_view.dart';

class EventDetailView extends StatefulWidget {
  final Event event;

  const EventDetailView({super.key, required this.event});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  Season? selectedSeason;

  @override
  void initState() {
    super.initState();
    // Auto-select if only one season
    if (widget.event.seasons.length == 1) {
      selectedSeason = widget.event.seasons.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToDivisions();
      });
    }
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
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
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
              widget.event.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.event.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'Select Season',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.event.seasons.length,
                itemBuilder: (context, index) {
                  final season = widget.event.seasons[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          season.title.length > 4 ? season.title.substring(0, 4) : season.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        '${season.title} Season',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'View divisions and results for ${season.title}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        selectedSeason = season;
                        _navigateToDivisions();
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