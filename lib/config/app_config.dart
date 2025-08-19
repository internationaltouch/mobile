class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'https://www.internationaltouch.org/api/v1';

  // Image placeholder base URL (same domain as API)
  static const String imageBaseUrl = 'https://www.internationaltouch.org';

  // Fallback placeholder URL generator - now returns FIT logo asset
  static String getPlaceholderImageUrl({
    required int width,
    required int height,
    required String backgroundColor,
    required String textColor,
    required String text,
  }) {
    // Return FIT vertical logo instead of placeholder URL
    return 'assets/images/LOGO_FIT-VERT.png';
  }

  // Predefined placeholder URLs for common use cases - now return FIT logo
  static String getCompetitionImageUrl(String text) {
    // Return FIT vertical logo instead of generated placeholder
    return 'assets/images/LOGO_FIT-VERT.png';
  }

  static String getCompetitionLogoUrl(String text) {
    // Return FIT vertical logo instead of generated placeholder
    return 'assets/images/LOGO_FIT-VERT.png';
  }
}
