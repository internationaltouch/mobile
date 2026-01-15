import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user preferences and settings that persist across app sessions
class UserPreferencesService {
  static const String _selectedTeamPrefix = 'selected_team_';
  static const String _selectedPoolPrefix = 'selected_pool_';
  static const String _lastTabPrefix = 'last_tab_';
  static const String _lastMainNavigationTab = 'last_main_navigation_tab';
  static const String _themeMode = 'theme_mode';
  static const String _cacheExpiryHours = 'cache_expiry_hours';

  static SharedPreferences? _prefs;

  /// Initialize shared preferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure preferences are initialized
  static Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // Team Filter Preferences
  /// Save selected team ID for a specific division
  static Future<void> setSelectedTeam(String divisionId, String? teamId) async {
    final prefs = await _preferences;
    final key = '$_selectedTeamPrefix$divisionId';

    if (teamId != null) {
      await prefs.setString(key, teamId);
    } else {
      await prefs.remove(key);
    }
  }

  /// Get selected team ID for a specific division
  static Future<String?> getSelectedTeam(String divisionId) async {
    final prefs = await _preferences;
    return prefs.getString('$_selectedTeamPrefix$divisionId');
  }

  // Pool Filter Preferences
  /// Save selected pool ID for a specific division
  static Future<void> setSelectedPool(String divisionId, String? poolId) async {
    final prefs = await _preferences;
    final key = '$_selectedPoolPrefix$divisionId';

    if (poolId != null) {
      await prefs.setString(key, poolId);
    } else {
      await prefs.remove(key);
    }
  }

  /// Get selected pool ID for a specific division
  static Future<String?> getSelectedPool(String divisionId) async {
    final prefs = await _preferences;
    return prefs.getString('$_selectedPoolPrefix$divisionId');
  }

  // Tab Preferences
  /// Save last selected tab index for a specific division
  static Future<void> setLastSelectedTab(
      String divisionId, int tabIndex) async {
    final prefs = await _preferences;
    await prefs.setInt('$_lastTabPrefix$divisionId', tabIndex);
  }

  /// Get last selected tab index for a specific division (defaults to 0 - Fixtures tab)
  static Future<int> getLastSelectedTab(String divisionId) async {
    final prefs = await _preferences;
    return prefs.getInt('$_lastTabPrefix$divisionId') ?? 0;
  }

  // Main Navigation Tab Preferences
  /// Save last selected main navigation tab index
  static Future<void> setLastMainNavigationTab(int tabIndex) async {
    final prefs = await _preferences;
    await prefs.setInt(_lastMainNavigationTab, tabIndex);
  }

  /// Get last selected main navigation tab index (defaults to 0)
  static Future<int> getLastMainNavigationTab() async {
    final prefs = await _preferences;
    return prefs.getInt(_lastMainNavigationTab) ?? 0;
  }

  // Theme Preferences
  /// Save user's preferred theme mode
  static Future<void> setThemeMode(String themeMode) async {
    final prefs = await _preferences;
    await prefs.setString(_themeMode, themeMode);
  }

  /// Get user's preferred theme mode (system, light, dark)
  static Future<String> getThemeMode() async {
    final prefs = await _preferences;
    return prefs.getString(_themeMode) ?? 'system';
  }

  // Cache Settings
  /// Save cache expiry preference in hours
  static Future<void> setCacheExpiryHours(int hours) async {
    final prefs = await _preferences;
    await prefs.setInt(_cacheExpiryHours, hours);
  }

  /// Get cache expiry preference in hours (defaults to 24 hours)
  static Future<int> getCacheExpiryHours() async {
    final prefs = await _preferences;
    return prefs.getInt(_cacheExpiryHours) ?? 24;
  }

  /// Save adaptive cache expiry based on device capabilities (in milliseconds)
  static Future<void> setAdaptiveCacheExpiry(int milliseconds) async {
    final prefs = await _preferences;
    await prefs.setInt('adaptive_cache_expiry', milliseconds);
  }

  /// Get adaptive cache expiry in milliseconds (defaults to 30 minutes)
  static Future<int> getAdaptiveCacheExpiry() async {
    final prefs = await _preferences;
    return prefs.getInt('adaptive_cache_expiry') ?? (30 * 60 * 1000);
  }

  // Utility Methods
  /// Clear all user preferences (useful for reset/logout)
  static Future<void> clearAllPreferences() async {
    final prefs = await _preferences;
    await prefs.clear();
  }

  /// Clear preferences for a specific division
  static Future<void> clearDivisionPreferences(String divisionId) async {
    final prefs = await _preferences;
    await prefs.remove('$_selectedTeamPrefix$divisionId');
    await prefs.remove('$_selectedPoolPrefix$divisionId');
    await prefs.remove('$_lastTabPrefix$divisionId');
  }

  /// Get all stored keys (useful for debugging)
  static Future<Set<String>> getAllKeys() async {
    final prefs = await _preferences;
    return prefs.getKeys();
  }

  /// Check if preferences have been initialized
  static bool get isInitialized => _prefs != null;
}
