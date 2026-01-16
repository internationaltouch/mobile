// News providers for Touch Technology Framework
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:touchtech_news/models/news_item.dart';
import 'package:touchtech_news/services/news_api_service.dart';

// HTTP Client provider (shared with other packages)
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

// News API Service provider
final newsApiServiceProvider = Provider<NewsApiService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return NewsApiService(httpClient: httpClient);
});

// News list provider - fetches from REST API with SQLite fallback
final newsListProvider = FutureProvider<List<NewsItem>>((ref) async {
  // Keep provider alive for offline caching
  ref.keepAlive();

  final newsApiService = ref.watch(newsApiServiceProvider);

  try {
    final newsList = await newsApiService.fetchNewsList();

    // TODO: Re-implement caching with new database service
    // Cache the news list
    // await DatabaseService.cacheNewsList(newsList);

    return newsList;
  } catch (error) {
    // TODO: Re-implement fallback to cached data
    // Try to load from cache if network fails
    // final cachedNews = await DatabaseService.loadCachedNewsList();
    // if (cachedNews.isNotEmpty) {
    //   return cachedNews;
    // }

    // Re-throw if no cached data or cache fails
    rethrow;
  }
});

// News detail provider - fetches full article with image and content
final newsDetailProvider =
    FutureProvider.family<NewsItem, String>((ref, slug) async {
  // Keep provider alive for offline caching
  ref.keepAlive();

  final newsApiService = ref.watch(newsApiServiceProvider);

  try {
    final detail = await newsApiService.fetchNewsDetail(slug);

    // TODO: Re-implement caching with new database service
    // Enrich cache with image URL
    // if (detail.imageUrl != null) {
    //   await DatabaseService.enrichNewsItemWithImage(slug, detail.imageUrl!);
    // }

    return detail;
  } catch (error) {
    // TODO: Re-implement fallback to cached data
    // Try to load from cache if network fails
    // final cachedDetail = await DatabaseService.loadCachedNewsDetail(slug);
    // if (cachedDetail != null) {
    //   return cachedDetail;
    // }

    // Re-throw if no cached data or cache fails
    rethrow;
  }
});
