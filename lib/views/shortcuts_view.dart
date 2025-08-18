import 'package:flutter/material.dart';
import '../models/shortcut_item.dart';

class ShortcutsView extends StatefulWidget {
  const ShortcutsView({super.key});

  @override
  State<ShortcutsView> createState() => _ShortcutsViewState();
}

class _ShortcutsViewState extends State<ShortcutsView> {
  List<ShortcutItem> _shortcuts = [];

  @override
  void initState() {
    super.initState();
    _loadShortcuts();
  }

  void _loadShortcuts() {
    // Load shortcuts from shared preferences or local storage
    // For now, using sample data
    setState(() {
      _shortcuts = [
        const ShortcutItem(
          id: '1',
          title: 'World Cup',
          subtitle: 'Latest fixtures and results',
          routePath: '/event_detail',
          arguments: {'event': 'world-cup'},
        ),
        const ShortcutItem(
          id: '2',
          title: 'Youth Touch Cup',
          subtitle: 'Atlantic Youth Touch Cup',
          routePath: '/event_detail',
          arguments: {'event': 'atlantic-youth-touch-cup'},
        ),
      ];
    });
  }

  void _navigateToShortcut(ShortcutItem shortcut) {
    // Handle navigation based on shortcut route
    Navigator.of(context).pop(); // Close the shortcuts dialog first

    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${shortcut.title}...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _addCurrentAsShortcut() {
    // This would add the current view as a shortcut
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Shortcut'),
        content: const Text('Add current view to shortcuts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Add logic to save current view as shortcut
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shortcut added!')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeShortcut(ShortcutItem shortcut) {
    setState(() {
      _shortcuts.removeWhere((item) => item.id == shortcut.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${shortcut.title} removed from shortcuts')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Shortcuts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Shortcuts list
            Expanded(
              child: _shortcuts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_border,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No shortcuts yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add shortcuts to your favorite views\nfor quick access',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _shortcuts.length,
                      itemBuilder: (context, index) {
                        final shortcut = _shortcuts[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.sports),
                          ),
                          title: Text(shortcut.title),
                          subtitle: Text(shortcut.subtitle),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeShortcut(shortcut),
                          ),
                          onTap: () => _navigateToShortcut(shortcut),
                        );
                      },
                    ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addCurrentAsShortcut,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Current'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
