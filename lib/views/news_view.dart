import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/news_item.dart';
import '../theme/fit_colors.dart';
import '../utils/image_utils.dart';
import '../config/config_service.dart';
import '../providers/pure_riverpod_providers.dart';
import 'competitions_view_riverpod.dart';

class NewsView extends ConsumerStatefulWidget {
  final int initialSelectedIndex;
  final bool showOnlyNews;

  const NewsView({
    super.key,
    this.initialSelectedIndex = 0,
    this.showOnlyNews = false,
  });

  @override
  ConsumerState<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends ConsumerState<NewsView> {
  late int _selectedIndex;
  List<NewsItem> _allNewsItems = [];
  late int _visibleItemsCount;
  ScrollController? _scrollController;
  bool _showReturnToTop = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
    _visibleItemsCount = ConfigService.config.features.news.initialItemsCount;
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController != null && _scrollController!.offset > 200) {
      if (!_showReturnToTop) {
        setState(() {
          _showReturnToTop = true;
        });
      }
    } else {
      if (_showReturnToTop) {
        setState(() {
          _showReturnToTop = false;
        });
      }
    }
  }

  void _scrollToTop() {
    _scrollController?.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showOnlyNews) {
      // When used within MainNavigationView, only show news content
      return Scaffold(body: _buildNewsPage());
    }

    // Original behavior for backward compatibility
    return Scaffold(
      body: _selectedIndex == 0
          ? _buildNewsPage()
          : const CompetitionsViewRiverpod(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports),
            label: 'Competitions',
          ),
        ],
      ),
    );
  }

  Widget _buildNewsPage() {
    // Initialize scroll controller if not already initialized
    if (_scrollController == null) {
      _scrollController = ScrollController();
      _scrollController!.addListener(_scrollListener);
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () {
            // Invalidate the news provider to refresh from API
            ref.invalidate(newsListProvider);
            return ref.watch(newsListProvider.future);
          },
          child: ref
              .watch(newsListProvider)
              .when(
                data: (newsItems) {
                  _allNewsItems = newsItems;
                  _visibleItemsCount =
                      ConfigService.config.features.news.initialItemsCount;
                  return _buildNewsContent(newsItems);
                },
                loading: () {
                  return const Center(child: CircularProgressIndicator());
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
                        const Text('Failed to load news'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(newsListProvider);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
        if (_showReturnToTop)
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: _scrollToTop,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.keyboard_arrow_up),
            ),
          ),
      ],
    );
  }

  Widget _buildNewsContent(List<NewsItem> newsItems) {
    if (newsItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: FITColors.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load news',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection and try again.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(newsListProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final visibleNewsItems = newsItems.take(_visibleItemsCount).toList();
    final hasMoreItems = newsItems.length > _visibleItemsCount;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      itemCount:
          visibleNewsItems.length + (hasMoreItems ? 1 : 0) + 1, // +1 for logo
      itemBuilder: (context, index) {
        if (index == 0) {
          // Show logo before first news item
          return Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
            child: Center(
              child: SizedBox(
                width:
                    MediaQuery.of(context).size.width *
                    0.6, // 60% of screen width
                child: Image.asset(
                  ConfigService.config.branding.logoHorizontal,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        } else if (index <= visibleNewsItems.length) {
          final newsItem =
              visibleNewsItems[index - 1]; // -1 because logo takes index 0
          return GestureDetector(
            onTap: () => _openNewsDetail(newsItem),
            child: NewsCard(
              newsItem: newsItem,
              shouldLoadImageImmediately:
                  index <= 3, // Load images for first 3 items immediately
            ),
          );
        } else {
          // Show "Show more" button
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: _showMoreItems,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Show more (${newsItems.length - _visibleItemsCount} remaining)',
                ),
              ),
            ),
          );
        }
      },
    );
  }

  void _showMoreItems() {
    setState(() {
      _visibleItemsCount =
          (_visibleItemsCount +
                  ConfigService.config.features.news.infiniteScrollBatchSize)
              .clamp(0, _allNewsItems.length);
    });
  }

  void _openNewsDetail(NewsItem newsItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailView(newsItem: newsItem),
      ),
    );
  }
}

class NewsCard extends StatefulWidget {
  final NewsItem newsItem;
  final bool shouldLoadImageImmediately;

  const NewsCard({
    super.key,
    required this.newsItem,
    this.shouldLoadImageImmediately = false,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _imageLoading = false;
  bool _hasBeenVisible = false;
  String? _originalImageUrl;

  @override
  void initState() {
    super.initState();
    _originalImageUrl = widget.newsItem.imageUrl;

    // Load images immediately for the first few items to ensure they're visible on page load
    if (widget.shouldLoadImageImmediately) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadImageImmediately();
      });
    }
  }

  Future<void> _loadImageImmediately() async {
    // Force load for immediate items, bypassing visibility checks
    if (_imageLoading) {
      return;
    }

    setState(() {
      _imageLoading = true;
      _hasBeenVisible = true; // Mark as loaded to prevent future loads
    });

    // Image loading is now handled by the detail provider in the parent
    // The image URL will be fetched and cached automatically
    if (mounted) {
      setState(() {
        _imageLoading = false;
      });
    }
  }

  Future<void> _loadImage() async {
    // Don't load if already loading, already loaded
    if (_imageLoading ||
        _hasBeenVisible ||
        widget.newsItem.imageUrl != _originalImageUrl) {
      return;
    }

    setState(() {
      _imageLoading = true;
      _hasBeenVisible = true; // Mark as loaded to prevent future loads
    });

    // Image loading is now handled by the detail provider in the parent
    // The image URL will be fetched and cached automatically
    if (mounted) {
      setState(() {
        _imageLoading = false;
      });
    }
  }

  void _onVisible() {
    _loadImage();
  }

  bool get _showSpinner {
    return _imageLoading && widget.newsItem.imageUrl == _originalImageUrl;
  }

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
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('news_card_${widget.newsItem.id}'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0.1) {
          _onVisible();
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.newsItem.imageUrl != null &&
                widget.newsItem.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12.0),
                ),
                child: Stack(
                  children: [
                    ImageUtils.buildImage(
                      widget.newsItem.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: FITColors.lightGrey,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: FITColors.mediumGrey,
                            ),
                          ),
                        );
                      },
                    ),
                    if (_showSpinner)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: FITColors.primaryBlack.withValues(
                              alpha: 0.7,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FITColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.newsItem.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.newsItem.summary,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    _formatDate(widget.newsItem.publishedAt),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: FITColors.darkGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
