import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppConfigData {
  final String name;
  final String displayName;
  final String description;
  final Map<String, String> identifier;
  final String version;
  final ApiConfig api;
  final BrandingConfig branding;
  final NavigationConfig navigation;
  final FeaturesConfig features;
  final AssetsConfig assets;

  AppConfigData({
    required this.name,
    required this.displayName,
    required this.description,
    required this.identifier,
    required this.version,
    required this.api,
    required this.branding,
    required this.navigation,
    required this.features,
    required this.assets,
  });

  factory AppConfigData.fromJson(Map<String, dynamic> json) {
    return AppConfigData(
      name: json['app']['name'] as String,
      displayName: json['app']['displayName'] as String,
      description: json['app']['description'] as String,
      identifier: Map<String, String>.from(json['app']['identifier']),
      version: json['app']['version'] as String,
      api: ApiConfig.fromJson(json['api']),
      branding: BrandingConfig.fromJson(json['branding']),
      navigation: NavigationConfig.fromJson(json['navigation']),
      features: FeaturesConfig.fromJson(json['features']),
      assets: AssetsConfig.fromJson(json['assets']),
    );
  }
}

class ApiConfig {
  final String baseUrl;
  final String imageBaseUrl;
  final String? competition;
  final String? season;

  ApiConfig({
    required this.baseUrl,
    required this.imageBaseUrl,
    this.competition,
    this.season,
  });

  factory ApiConfig.fromJson(Map<String, dynamic> json) {
    return ApiConfig(
      baseUrl: json['baseUrl'] as String,
      imageBaseUrl: json['imageBaseUrl'] as String,
      competition: json['competition'] as String?,
      season: json['season'] as String?,
    );
  }
}

class BrandingConfig {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color errorColor;
  final Color backgroundColor;
  final Color textColor;
  final String logoVertical;
  final String logoHorizontal;
  final String appIcon;
  final SplashScreenConfig splashScreen;

  BrandingConfig({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.errorColor,
    required this.backgroundColor,
    required this.textColor,
    required this.logoVertical,
    required this.logoHorizontal,
    required this.appIcon,
    required this.splashScreen,
  });

  factory BrandingConfig.fromJson(Map<String, dynamic> json) {
    return BrandingConfig(
      primaryColor: _parseColor(json['primaryColor'] as String),
      secondaryColor: _parseColor(json['secondaryColor'] as String),
      accentColor: _parseColor(json['accentColor'] as String),
      errorColor: _parseColor(json['errorColor'] as String),
      backgroundColor: _parseColor(json['backgroundColor'] as String),
      textColor: _parseColor(json['textColor'] as String),
      logoVertical: json['logoVertical'] as String,
      logoHorizontal: json['logoHorizontal'] as String,
      appIcon: json['appIcon'] as String,
      splashScreen: SplashScreenConfig.fromJson(json['splashScreen']),
    );
  }

  static Color _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      colorString = colorString.substring(1);
    }
    return Color(int.parse('FF$colorString', radix: 16));
  }
}

class SplashScreenConfig {
  final Color backgroundColor;
  final String image;
  final Color imageBackgroundColor;

  SplashScreenConfig({
    required this.backgroundColor,
    required this.image,
    required this.imageBackgroundColor,
  });

  factory SplashScreenConfig.fromJson(Map<String, dynamic> json) {
    return SplashScreenConfig(
      backgroundColor:
          BrandingConfig._parseColor(json['backgroundColor'] as String),
      image: json['image'] as String,
      imageBackgroundColor:
          BrandingConfig._parseColor(json['imageBackgroundColor'] as String),
    );
  }
}

class NavigationConfig {
  final List<TabConfig> tabs;

  NavigationConfig({required this.tabs});

  factory NavigationConfig.fromJson(Map<String, dynamic> json) {
    final tabsList = json['tabs'] as List;
    final tabs = tabsList.map((tab) => TabConfig.fromJson(tab)).toList();
    return NavigationConfig(tabs: tabs);
  }

  List<TabConfig> get enabledTabs => tabs.where((tab) => tab.enabled).toList();
}

class TabConfig {
  final String id;
  final String label;
  final String icon;
  final bool enabled;
  final Color backgroundColor;
  final String? variant;

  TabConfig({
    required this.id,
    required this.label,
    required this.icon,
    required this.enabled,
    required this.backgroundColor,
    this.variant,
  });

  factory TabConfig.fromJson(Map<String, dynamic> json) {
    return TabConfig(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String,
      enabled: json['enabled'] as bool,
      backgroundColor:
          BrandingConfig._parseColor(json['backgroundColor'] as String),
      variant: json['variant'] as String?,
    );
  }

  IconData get iconData {
    switch (icon) {
      case 'newspaper':
        return Icons.newspaper;
      case 'public':
        return Icons.public;
      case 'sports':
        return Icons.sports;
      case 'star':
        return Icons.star;
      default:
        return Icons.help;
    }
  }
}

class NewsConfig {
  final String newsApiPath;
  final int initialItemsCount;
  final int infiniteScrollBatchSize;

  NewsConfig({
    required this.newsApiPath,
    this.initialItemsCount = 10,
    this.infiniteScrollBatchSize = 5,
  });

  factory NewsConfig.fromJson(Map<String, dynamic> json) {
    return NewsConfig(
      newsApiPath: json['newsApiPath'] as String? ?? 'news/articles/',
      initialItemsCount: json['initialItemsCount'] as int? ?? 10,
      infiniteScrollBatchSize: json['infiniteScrollBatchSize'] as int? ?? 5,
    );
  }
}

class ClubConfig {
  final String navigationLabel;
  final String titleBarText;
  final List<String> allowedStatuses;
  final List<String> excludedSlugs;
  final Map<String, String> slugImageMapping;

  ClubConfig({
    this.navigationLabel = 'Clubs',
    this.titleBarText = 'Clubs',
    this.allowedStatuses = const ['active'],
    this.excludedSlugs = const [],
    this.slugImageMapping = const {},
  });

  factory ClubConfig.fromJson(Map<String, dynamic> json) {
    return ClubConfig(
      navigationLabel: json['navigationLabel'] as String? ?? 'Clubs',
      titleBarText: json['titleBarText'] as String? ?? 'Clubs',
      allowedStatuses: List<String>.from(json['allowedStatuses'] ?? ['active']),
      excludedSlugs: List<String>.from(json['excludedSlugs'] ?? []),
      slugImageMapping:
          Map<String, String>.from(json['slugImageMapping'] ?? {}),
    );
  }
}

class CompetitionConfig {
  final List<String> excludedSlugs;
  final List<String> excludedSeasonCombos; // Format: "slug:season"
  final List<String> excludedDivisionCombos; // Format: "slug:season:division"
  final Map<String, String> slugImageMapping;

  CompetitionConfig({
    this.excludedSlugs = const [],
    this.excludedSeasonCombos = const [],
    this.excludedDivisionCombos = const [],
    this.slugImageMapping = const {},
  });

  factory CompetitionConfig.fromJson(Map<String, dynamic> json) {
    return CompetitionConfig(
      excludedSlugs: List<String>.from(json['excludedSlugs'] ?? []),
      excludedSeasonCombos:
          List<String>.from(json['excludedSeasonCombos'] ?? []),
      excludedDivisionCombos:
          List<String>.from(json['excludedDivisionCombos'] ?? []),
      slugImageMapping:
          Map<String, String>.from(json['slugImageMapping'] ?? {}),
    );
  }
}

class FeaturesConfig {
  final String flagsModule;
  final String eventsVariant;
  final NewsConfig news;
  final ClubConfig clubs;
  final CompetitionConfig competitions;

  FeaturesConfig({
    required this.flagsModule,
    required this.eventsVariant,
    required this.news,
    required this.clubs,
    required this.competitions,
  });

  factory FeaturesConfig.fromJson(Map<String, dynamic> json) {
    return FeaturesConfig(
      flagsModule: json['flagsModule'] as String,
      eventsVariant: json['eventsVariant'] as String,
      news: NewsConfig.fromJson(json['news'] ?? {}),
      clubs: ClubConfig.fromJson(json['clubs'] ?? {}),
      competitions: CompetitionConfig.fromJson(json['competitions'] ?? {}),
    );
  }
}

class AssetsConfig {
  final String competitionImages;
  final String flagsPath;

  AssetsConfig({
    required this.competitionImages,
    required this.flagsPath,
  });

  factory AssetsConfig.fromJson(Map<String, dynamic> json) {
    return AssetsConfig(
      competitionImages: json['competitionImages'] as String,
      flagsPath: json['flagsPath'] as String,
    );
  }
}

class ConfigService {
  static AppConfigData? _config;
  static bool _initialized = false;

  static Future<void> initialize(
      {String configPath = 'assets/config/app_config.json'}) async {
    if (_initialized) return;

    try {
      final String configString = await rootBundle.loadString(configPath);
      final Map<String, dynamic> configJson = json.decode(configString);
      _config = AppConfigData.fromJson(configJson);
      _initialized = true;
    } catch (e) {
      throw Exception('Failed to load app configuration: $e');
    }
  }

  static AppConfigData get config {
    if (!_initialized || _config == null) {
      throw Exception(
          'ConfigService not initialized. Call ConfigService.initialize() first.');
    }
    return _config!;
  }

  static bool get isInitialized => _initialized;

  static Future<void> loadConfig(String configPath) async {
    _initialized = false;
    await initialize(configPath: configPath);
  }

  // Method for setting up test configuration
  static void setTestConfig() {
    _config = AppConfigData(
      name: 'Test App',
      displayName: 'Test App',
      description: 'Test App Description',
      identifier: {'android': 'com.test.app', 'ios': 'com.test.app'},
      version: '1.0.0',
      api: ApiConfig(
        baseUrl: 'https://test.example.com/api/v1',
        imageBaseUrl: 'https://test.example.com',
      ),
      branding: BrandingConfig(
        primaryColor: BrandingConfig._parseColor('#1976D2'),
        secondaryColor: BrandingConfig._parseColor('#FFC107'),
        accentColor: BrandingConfig._parseColor('#4CAF50'),
        errorColor: BrandingConfig._parseColor('#F44336'),
        backgroundColor: BrandingConfig._parseColor('#FFFFFF'),
        textColor: BrandingConfig._parseColor('#212121'),
        logoVertical: 'assets/images/test-logo.png',
        logoHorizontal: 'assets/images/test-logo.png',
        appIcon: 'assets/images/test-icon.png',
        splashScreen: SplashScreenConfig(
          backgroundColor: BrandingConfig._parseColor('#1976D2'),
          image: 'assets/images/test-logo.png',
          imageBackgroundColor: BrandingConfig._parseColor('#1976D2'),
        ),
      ),
      navigation: NavigationConfig(tabs: [
        TabConfig(
          id: 'news',
          label: 'News',
          icon: 'newspaper',
          enabled: true,
          backgroundColor: BrandingConfig._parseColor('#1976D2'),
        ),
        TabConfig(
          id: 'clubs',
          label: 'Members',
          icon: 'public',
          enabled: true,
          backgroundColor: BrandingConfig._parseColor('#1976D2'),
        ),
        TabConfig(
          id: 'events',
          label: 'Events',
          icon: 'sports',
          enabled: true,
          backgroundColor: BrandingConfig._parseColor('#1976D2'),
        ),
        TabConfig(
          id: 'my_sport',
          label: 'My Sport',
          icon: 'star',
          enabled: true,
          backgroundColor: BrandingConfig._parseColor('#1976D2'),
        ),
      ]),
      features: FeaturesConfig(
        flagsModule: 'test',
        eventsVariant: 'standard',
        news: NewsConfig(
          newsApiPath: 'news/articles/',
          initialItemsCount: 10,
          infiniteScrollBatchSize: 5,
        ),
        clubs: ClubConfig(
          navigationLabel: 'Clubs',
          titleBarText: 'Test Clubs',
          allowedStatuses: ['active'],
          excludedSlugs: [],
          slugImageMapping: {},
        ),
        competitions: CompetitionConfig(
          excludedSlugs: [
            'home-nations',
            'mainland-cup',
            'asian-cup',
            'test-matches',
            'pacific-games',
            'cardiff-touch-superleague',
            'jersey-touch-superleague',
          ],
          excludedSeasonCombos: [
            'world-cup:2018',
            'euros:2016',
          ],
          excludedDivisionCombos: [
            'world-cup:2022:womens-30',
            'euros:2023:mens-40',
          ],
          slugImageMapping: {
            'asia-pacific-youth-touch-cup':
                'assets/images/competitions/APYTC.png',
            'atlantic-youth-touch-cup': 'assets/images/competitions/AYTC.png',
            'european-junior-touch-championships':
                'assets/images/competitions/EJTC.png',
            'euros': 'assets/images/competitions/ETC.png',
          },
        ),
      ),
      assets: AssetsConfig(
        competitionImages: 'assets/images/competitions/',
        flagsPath: 'lib/config/flags/test_flags.dart',
      ),
    );
    _initialized = true;
  }
}
