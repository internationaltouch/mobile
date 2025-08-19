import 'package:flutter/material.dart';
import 'home_view.dart';
import 'competitions_view.dart';

class MainNavigationView extends StatefulWidget {
  final int initialSelectedIndex;

  const MainNavigationView({super.key, this.initialSelectedIndex = 0});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  late int _selectedIndex;
  late List<GlobalKey<NavigatorState>> _navigatorKeys;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
    _navigatorKeys = [
      GlobalKey<NavigatorState>(), // News navigator
      GlobalKey<NavigatorState>(), // Competitions navigator
    ];
    _pages = [
      _buildNewsNavigator(),
      _buildCompetitionsNavigator(),
    ];
  }

  Widget _buildNewsNavigator() {
    return Navigator(
      key: _navigatorKeys[0],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const HomeView(showOnlyNews: true),
          settings: settings,
        );
      },
    );
  }

  Widget _buildCompetitionsNavigator() {
    return Navigator(
      key: _navigatorKeys[1],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const CompetitionsView(),
          settings: settings,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports),
            label: 'Competitions',
          ),
        ],
      ),
    );
  }

  // Method to switch tabs from child navigators
  void switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

// Extension to access the main navigation from child pages
extension MainNavigationExtension on BuildContext {
  void switchToTab(int index) {
    // Find the MainNavigationView in the widget tree
    final mainNav = findAncestorStateOfType<_MainNavigationViewState>();
    mainNav?.switchTab(index);
  }
}
