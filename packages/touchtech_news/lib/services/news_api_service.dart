import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:touchtech_core/config/config_service.dart';
import 'package:touchtech_news/models/news_item.dart';
import 'package:touchtech_core/services/device_service.dart';

class NewsApiService {
  final http.Client httpClient;

  NewsApiService({required this.httpClient});

  String get _baseUrl => ConfigService.config.api.baseUrl;
  String get _newsApiPath => ConfigService.config.features.news.newsApiPath;

  /// Fetch news list from REST API
  /// Returns a list of NewsItem objects from the list endpoint
  Future<List<NewsItem>> fetchNewsList() async {
    // Check connectivity first
    final isConnected = await DeviceService.instance.isConnected;
    if (!isConnected) {
      debugPrint('📰 [NewsAPI] ❌ No internet connection');
      throw NetworkUnavailableException(
          'Cannot fetch news - no internet connection');
    }

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
        throw ApiErrorException(
            response.statusCode, response.reasonPhrase ?? 'Unknown error');
      }
    } on NetworkUnavailableException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on ApiErrorException {
      rethrow;
    } catch (e) {
      debugPrint('📰 [NewsAPI] ❌ Network error fetching news list: $e');
      throw NetworkUnavailableException('Network error: $e');
    }
  }

  /// Fetch individual news article detail
  /// Returns a single NewsItem with full content and image from detail endpoint
  Future<NewsItem> fetchNewsDetail(String slug) async {
    // Check connectivity first
    final isConnected = await DeviceService.instance.isConnected;
    if (!isConnected) {
      debugPrint('📰 [NewsAPI] ❌ No internet connection');
      throw NetworkUnavailableException(
          'Cannot fetch news detail - no internet connection');
    }

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
        throw ApiErrorException(
            response.statusCode, response.reasonPhrase ?? 'Unknown error');
      }
    } on NetworkUnavailableException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on ApiErrorException {
      rethrow;
    } catch (e) {
      debugPrint('📰 [NewsAPI] ❌ Network error fetching news detail: $e');
      throw NetworkUnavailableException('Network error: $e');
    }
  }
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => message;
}

class NetworkUnavailableException implements Exception {
  final String message;

  NetworkUnavailableException(
      [this.message = 'No internet connection available']);

  @override
  String toString() => message;
}

class ApiErrorException implements Exception {
  final int statusCode;
  final String message;

  ApiErrorException(this.statusCode, [this.message = 'API request failed']);

  @override
  String toString() => 'API Error ($statusCode): $message';
}
