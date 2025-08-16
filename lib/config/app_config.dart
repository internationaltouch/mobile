class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'https://www.internationaltouch.org/api/v1';
  
  // Image placeholder base URL (same domain as API)
  static const String imageBaseUrl = 'https://www.internationaltouch.org';
  
  // Fallback placeholder URL generator
  static String getPlaceholderImageUrl({
    required int width,
    required int height,
    required String backgroundColor,
    required String textColor,
    required String text,
  }) {
    return '$imageBaseUrl/placeholder/${width}x$height/$backgroundColor/$textColor?text=${Uri.encodeComponent(text)}';
  }
  
  // Predefined placeholder URLs for common use cases
  static String getCompetitionImageUrl(String text) {
    return getPlaceholderImageUrl(
      width: 300,
      height: 200,
      backgroundColor: '1976D2',
      textColor: 'FFFFFF',
      text: text,
    );
  }
  
  static String getCompetitionLogoUrl(String text) {
    return getPlaceholderImageUrl(
      width: 100,
      height: 100,
      backgroundColor: '1976D2',
      textColor: 'FFFFFF',
      text: text,
    );
  }
}