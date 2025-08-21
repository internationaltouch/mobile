import 'package:flutter/material.dart';

class ImageUtils {
  /// Creates an Image widget that automatically detects if the URL is an asset path
  /// or a network URL and uses the appropriate widget
  static Widget buildImage(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit? fit,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder,
  }) {
    // Check if the imageUrl is an asset path
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        errorBuilder: errorBuilder,
      );
    } else {
      // Use network image for URLs
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder,
      );
    }
  }
}
