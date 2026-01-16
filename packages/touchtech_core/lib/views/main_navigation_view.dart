import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchtech_clubs/touchtech_clubs.dart';
import 'package:touchtech_competitions/touchtech_competitions.dart';
import 'package:touchtech_core/touchtech_core.dart';

class MainNavigationView extends ConsumerStatefulWidget {
  final int initialSelectedIndex;

  const MainNavigationView({super.key, this.initialSelectedIndex = 0});

  @override
  ConsumerState<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends ConsumerState<MainNavigationView> {
  late int _selectedIndex;
  late List<GlobalKey<NavigatorState>> _navigatorKeys;
  late List<Widget> _pages;
  late List<TabConfig> _enabledTabs;

  @override
  void initState() {
    super.initState();
    _enabledTabs = ConfigService.config.navigation.enabledTabs;
    _selectedIndex =
        widget.initialSelectedIndex.clamp(0, _enabledTabs.length - 1);

    _navigatorKeys = List.generate(
      _enabledTabs.length,
      (index) => GlobalKey<NavigatorState>(),
    );

    _pages = _enabledTabs.map((tab) => _buildNavigatorForTab(tab)).toList();

    // Load last selected tab from preferences
    _loadLastSelectedTab();
  }

  Future<void> _loadLastSelectedTab() async {
    // Priority order:
    // 1. Explicit initialSelectedIndex parameter (if not 0)
    // 2. Config initialNavigation.initialTab (if specified)
    // 3. Saved user preference (if exists)
    // 4. Default to 0

    if (widget.initialSelectedIndex != 0) {
      // Already set by parameter, don't override
      return;
    }

    // Check config for initial tab preference
    final initialNav = ConfigService.config.navigation.initialNavigation;
    if (initialNav?.initialTab != null) {
      final tabIndex = _enabledTabs.indexWhere(
        (tab) => tab.id == initialNav!.initialTab,
      );
      if (tabIndex != -1 && mounted) {
        setState(() {
          _selectedIndex = tabIndex;
        });
        return;
      }
    }

    // Fall back to saved user preference
    final lastTab = await UserPreferencesService.getLastMainNavigationTab();
    if (mounted && lastTab < _enabledTabs.length) {
      setState(() {
        _selectedIndex = lastTab;
      });
    }
  }

  Widget _buildNavigatorForTab(TabConfig tab) {
    final tabIndex = _enabledTabs.indexOf(tab);
    return Navigator(
      key: _navigatorKeys[tabIndex],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => _getViewForTab(tab),
          settings: settings,
        );
      },
    );
  }

  Widget _getViewForTab(TabConfig tab) {
    switch (tab.id) {
      case 'news':
        return const NewsView(showOnlyNews: true);
      case 'clubs':
        return const ClubView();
      case 'events':
        return _getEventsView(tab);
      case 'my_sport':
        return const FavoritesView();
      default:
        return const Placeholder();
    }
  }

  Widget _getEventsView(TabConfig tab) {
    final variant = tab.variant ?? 'standard';
    switch (variant) {
      case 'favorites':
        return const FavoritesView(); // Use dedicated favorites view
      case 'standard':
      default:
        return const CompetitionsViewRiverpod(); // Use Riverpod version with real caching
    }
  }

  @override
  Widget build(BuildContext context) {
    // If only one tab, show it directly without bottom navigation bar
    if (_enabledTabs.length == 1) {
      return Scaffold(
        body: ConnectionStatusWidget(
          showOfflineMessage: true,
          child: _pages[0],
        ),
      );
    }

    // Multiple tabs - show with bottom navigation bar
    return Scaffold(
      body: ConnectionStatusWidget(
        showOfflineMessage: true,
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        backgroundColor: ConfigService.config.branding.backgroundColor,
        selectedItemColor: ConfigService.config.branding.primaryColor,
        unselectedItemColor:
            ConfigService.config.branding.textColor.withValues(alpha: 0.6),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Persist the selected tab
          UserPreferencesService.setLastMainNavigationTab(index);
        },
        items: _enabledTabs
            .map((tab) => BottomNavigationBarItem(
                  icon: Icon(tab.iconData),
                  label: tab.label,
                ))
            .toList(),
      ),
    );
  }

  // Method to switch tabs from child navigators
  void switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Persist the selected tab
    UserPreferencesService.setLastMainNavigationTab(index);
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
