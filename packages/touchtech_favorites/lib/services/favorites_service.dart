import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchtech_favorites/models/favorite.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites';
  static SharedPreferences? _prefs;

  // Initialize shared preferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Get all favorites
  static Future<List<Favorite>> getFavorites() async {
    await init();
    final favoritesJson = _prefs!.getStringList(_favoritesKey) ?? [];
    return favoritesJson
        .map((json) => Favorite.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded)); // Most recent first
  }

  // Add a favorite
  static Future<void> addFavorite(Favorite favorite) async {
    await init();
    final favorites = await getFavorites();

    // Remove if already exists (to update dateAdded)
    favorites.removeWhere((f) => f.id == favorite.id);

    // Add to beginning
    favorites.insert(0, favorite);

    // Save
    await _saveFavorites(favorites);
  }

  // Remove a favorite
  static Future<void> removeFavorite(String favoriteId) async {
    await init();
    final favorites = await getFavorites();
    favorites.removeWhere((f) => f.id == favoriteId);
    await _saveFavorites(favorites);
  }

  // Check if item is favorited
  static Future<bool> isFavorited(String favoriteId) async {
    await init();
    final favorites = await getFavorites();
    return favorites.any((f) => f.id == favoriteId);
  }

  // Toggle favorite status
  static Future<bool> toggleFavorite(Favorite favorite) async {
    final isFav = await isFavorited(favorite.id);
    if (isFav) {
      await removeFavorite(favorite.id);
      return false;
    } else {
      await addFavorite(favorite);
      return true;
    }
  }

  // Get favorites by type
  static Future<List<Favorite>> getFavoritesByType(FavoriteType type) async {
    final favorites = await getFavorites();
    return favorites.where((f) => f.type == type).toList();
  }

  // Clear all favorites
  static Future<void> clearFavorites() async {
    await init();
    await _prefs!.remove(_favoritesKey);
  }

  // Private method to save favorites
  static Future<void> _saveFavorites(List<Favorite> favorites) async {
    final favoritesJson = favorites.map((f) => jsonEncode(f.toJson())).toList();
    await _prefs!.setStringList(_favoritesKey, favoritesJson);
  }
}
