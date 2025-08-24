import 'package:flutter/material.dart';
import 'home_view.dart';
import 'competitions_view.dart';
import 'my_touch_view.dart';
import '../services/background_update_service.dart';

class MainNavigationView extends StatefulWidget {
  final int initialSelectedIndex;

  const MainNavigationView({super.key, this.initialSelectedIndex = 0});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView>
    with WidgetsBindingObserver {
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
      GlobalKey<NavigatorState>(), // My Touch navigator
    ];
    _pages = [
      _buildNewsNavigator(),
      _buildCompetitionsNavigator(),
      _buildMyTouchNavigator(),
    ];

    // Add app lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Start background updates when app initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBackgroundUpdates();
    });
  }

  @override
  void dispose() {
    // Remove app lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    
    // Stop background updates when app is disposed
    BackgroundUpdateService.stopPeriodicUpdates();
    
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Start/stop background updates based on app state
    switch (state) {
      case AppLifecycleState.resumed:
        _startBackgroundUpdates();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        BackgroundUpdateService.stopPeriodicUpdates();
        break;
    }
  }

  void _startBackgroundUpdates() {
    if (!BackgroundUpdateService.isRunning) {
      BackgroundUpdateService.startPeriodicUpdates();
      debugPrint('🚀 [MainNavigation] 📱 Started background updates');
    }
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

  Widget _buildMyTouchNavigator() {
    return Navigator(
      key: _navigatorKeys[2],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const MyTouchView(),
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
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'My Touch',
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

  // Method to navigate within a specific tab's navigator
  void navigateInTab(int tabIndex, Widget destination) {
    if (tabIndex >= 0 && tabIndex < _navigatorKeys.length) {
      _navigatorKeys[tabIndex].currentState?.push(
            MaterialPageRoute(builder: (context) => destination),
          );
    }
  }

  // Method to reset navigation stack and navigate to a destination
  // Keeps the base route (CompetitionsView) and removes only deep navigation
  void resetAndNavigateInTab(int tabIndex, Widget destination) {
    if (tabIndex >= 0 && tabIndex < _navigatorKeys.length) {
      final navigatorState = _navigatorKeys[tabIndex].currentState;
      if (navigatorState != null) {
        // Pop until we're back to the base route (CompetitionsView)
        navigatorState.popUntil((route) => route.isFirst);
        // Then push the destination
        navigatorState.push(
          MaterialPageRoute(builder: (context) => destination),
        );
      }
    }
  }
}

// Extension to access the main navigation from child pages
extension MainNavigationExtension on BuildContext {
  void switchToTab(int index) {
    // Find the MainNavigationView in the widget tree
    final mainNav = findAncestorStateOfType<_MainNavigationViewState>();
    mainNav?.switchTab(index);
  }

  void switchToTabAndNavigate(int tabIndex, Widget destination) {
    // Find the MainNavigationView in the widget tree
    final mainNav = findAncestorStateOfType<_MainNavigationViewState>();
    if (mainNav != null) {
      // Switch to the tab first
      mainNav.switchTab(tabIndex);

      // Wait a frame for the tab switch to complete, then reset stack and navigate
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Clear the navigation stack for the target tab to prevent build-up
        mainNav.resetAndNavigateInTab(tabIndex, destination);
      });
    }
  }
}
