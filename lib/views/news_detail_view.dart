import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/news_item.dart';
import '../utils/image_utils.dart';
import '../providers/pure_riverpod_providers.dart';

class NewsDetailView extends ConsumerWidget {
  final NewsItem newsItem;

  const NewsDetailView({super.key, required this.newsItem});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch detailed article with image and content
    final detailAsyncValue = ref.watch(newsDetailProvider(newsItem.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Article'),
      ),
      body: detailAsyncValue.when(
        data: (detailedItem) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image (only show if image URL is not null)
                if (detailedItem.imageUrl != null &&
                    detailedItem.imageUrl!.isNotEmpty)
                  ImageUtils.buildImage(
                    detailedItem.imageUrl!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),

                // Article content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        detailedItem.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),

                      // Date
                      Text(
                        _formatDate(detailedItem.publishedAt),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Content
                      if (detailedItem.content != null)
                        Html(
                          data: detailedItem.content!,
                          style: {
                            'body': Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                            ),
                            'p': Style(
                              margin: Margins.only(bottom: 16),
                            ),
                            'img': Style(
                              width: Width(double.infinity),
                              height: Height.auto(),
                            ),
                          },
                        )
                      else
                        Text(
                          detailedItem.summary,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                const Text('Failed to load article details'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(newsDetailProvider(newsItem.id));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
