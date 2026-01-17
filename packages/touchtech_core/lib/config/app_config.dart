import 'package:touchtech_core/config/config_service.dart';

class AppConfig {
  // API Configuration - now uses ConfigService
  static String get apiBaseUrl => ConfigService.config.api.baseUrl;
  static String get imageBaseUrl => ConfigService.config.api.imageBaseUrl;

  // Fallback placeholder URL generator - now returns configured logo
  static String getPlaceholderImageUrl({
    required int width,
    required int height,
    required String backgroundColor,
    required String textColor,
    required String text,
  }) {
    return ConfigService.config.branding.logoVertical;
  }

  // Predefined placeholder URLs for common use cases - now return configured logo
  static String getCompetitionImageUrl(String text) {
    return ConfigService.config.branding.logoVertical;
  }

  static String getCompetitionLogoUrl(String text) {
    return ConfigService.config.branding.logoVertical;
  }
}
