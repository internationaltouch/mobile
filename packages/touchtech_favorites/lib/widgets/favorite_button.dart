import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchtech_competitions/providers/pure_riverpod_providers.dart';
import 'package:touchtech_favorites/models/favorite.dart';

class FavoriteButton extends ConsumerWidget {
  final Favorite favorite;
  final bool showText;
  final IconData? iconData;
  final double? iconSize;
  final Color? favoriteColor;

  const FavoriteButton({
    super.key,
    required this.favorite,
    this.showText = false,
    this.iconData,
    this.iconSize,
    this.favoriteColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavoritedAsync = ref.watch(isFavoritedProvider(favorite.id));
    final favoritesNotifier = ref.read(favoritesNotifierProvider.notifier);

    return isFavoritedAsync.when(
      loading: () => IconButton(
        icon: Icon(
          iconData ?? Icons.favorite_border,
          size: iconSize,
        ),
        onPressed: null, // Disabled while loading
      ),
      error: (error, stackTrace) => IconButton(
        icon: Icon(
          Icons.error_outline,
          color: Colors.red,
          size: iconSize,
        ),
        onPressed: null, // Disabled on error
      ),
      data: (isFavorited) {
        if (showText) {
          return ElevatedButton.icon(
            icon: Icon(
              isFavorited
                  ? (iconData ?? Icons.favorite)
                  : (iconData ?? Icons.favorite_border),
              color: isFavorited ? (favoriteColor ?? Colors.red) : null,
              size: iconSize,
            ),
            label: Text(
                isFavorited ? 'Remove from Favorites' : 'Add to Favorites'),
            onPressed: () =>
                _toggleFavorite(context, ref, favoritesNotifier, isFavorited),
          );
        } else {
          return IconButton(
            icon: Icon(
              isFavorited
                  ? (iconData ?? Icons.favorite)
                  : (iconData ?? Icons.favorite_border),
              color: isFavorited ? (favoriteColor ?? Colors.red) : null,
              size: iconSize,
            ),
            onPressed: () =>
                _toggleFavorite(context, ref, favoritesNotifier, isFavorited),
          );
        }
      },
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    FavoritesNotifier favoritesNotifier,
    bool currentlyFavorited,
  ) async {
    try {
      final isNowFavorited = await favoritesNotifier.toggleFavorite(favorite);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNowFavorited ? 'Added to favorites' : 'Removed from favorites',
            ),
            duration: const Duration(seconds: 2),
            action: isNowFavorited
                ? null
                : SnackBarAction(
                    label: 'Undo',
                    onPressed: () async {
                      await favoritesNotifier.addFavorite(favorite);
                    },
                  ),
          ),
        );
      }

      // Invalidate the provider to refresh UI
      ref.invalidate(isFavoritedProvider(favorite.id));
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorites: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
