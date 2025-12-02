import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config_service.dart';
import '../models/news_item.dart';

class NewsApiService {
  final http.Client httpClient;

  NewsApiService({required this.httpClient});

  String get _baseUrl => ConfigService.config.api.baseUrl;
  String get _newsApiPath => ConfigService.config.features.news.newsApiPath;

  /// Fetch news list from REST API
  /// Returns a list of NewsItem objects from the list endpoint
  Future<List<NewsItem>> fetchNewsList() async {
    // newsApiPath is just 'news/articles/' without '/api/v1' prefix
    final path =
        _newsApiPath.startsWith('/') ? _newsApiPath.substring(1) : _newsApiPath;
    final url = Uri.parse('$_baseUrl/$path');
    debugPrint('📰 [NewsAPI] 🔄 Fetching news list from: $url');

    try {
      final response = await httpClient.get(
        url,
        headers: {
          'User-Agent': 'TouchMobileApp/1.0 (news articles list)',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('News API request timed out after 30 seconds');
        },
      );

      if (response.statusCode == 200) {
        debugPrint('📰 [NewsAPI] ✅ Got response, parsing JSON...');
        final jsonData = jsonDecode(response.body);

        // Handle both array and paginated responses
        final List<dynamic> articlesList =
            jsonData is List ? jsonData : (jsonData['results'] ?? []);

        final newsItems = (articlesList).map<NewsItem>((item) {
          return NewsItem.fromListJson(item as Map<String, dynamic>);
        }).toList();

        debugPrint(
            '📰 [NewsAPI] ✅ Successfully parsed ${newsItems.length} news items');
        return newsItems;
      } else {
        debugPrint(
            '📰 [NewsAPI] ❌ HTTP ${response.statusCode}: ${response.reasonPhrase}');
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('📰 [NewsAPI] ❌ Error fetching news list: $e');
      rethrow;
    }
  }

  /// Fetch individual news article detail
  /// Returns a single NewsItem with full content and image from detail endpoint
  Future<NewsItem> fetchNewsDetail(String slug) async {
    // newsApiPath is just 'news/articles/' without '/api/v1' prefix
    final path =
        _newsApiPath.startsWith('/') ? _newsApiPath.substring(1) : _newsApiPath;
    final url = Uri.parse('$_baseUrl/$path$slug/');
    debugPrint('📰 [NewsAPI] 🔄 Fetching news detail for: $slug');

    try {
      final response = await httpClient.get(
        url,
        headers: {
          'User-Agent': 'TouchMobileApp/1.0 (news article detail)',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
              'News detail API request timed out after 30 seconds');
        },
      );

      if (response.statusCode == 200) {
        debugPrint('📰 [NewsAPI] ✅ Got detail response, parsing JSON...');
        final jsonData = jsonDecode(response.body);
        final newsItem =
            NewsItem.fromDetailJson(jsonData as Map<String, dynamic>);

        debugPrint(
            '📰 [NewsAPI] ✅ Successfully parsed detail for: ${newsItem.title}');
        return newsItem;
      } else {
        debugPrint(
            '📰 [NewsAPI] ❌ HTTP ${response.statusCode}: ${response.reasonPhrase}');
        throw Exception('Failed to load news detail: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('📰 [NewsAPI] ❌ Error fetching news detail: $e');
      rethrow;
    }
  }
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => message;
}
