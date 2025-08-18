import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/news_item.dart';
import '../services/data_service.dart';
import '../theme/fit_colors.dart';
import 'competitions_view.dart';
import 'news_detail_view.dart';
import 'shortcuts_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  late Future<List<NewsItem>> _newsFuture;
  List<NewsItem> _allNewsItems = [];
  int _visibleItemsCount = 10;

  @override
  void initState() {
    super.initState();
    _testConnectivityAndLoadNews();
  }

  Future<void> _testConnectivityAndLoadNews() async {
    _newsFuture = DataService.getNewsItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/LOGO_FIT-HZ.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            tooltip: 'Shortcuts',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const ShortcutsView(),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildNewsPage() : const CompetitionsView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports),
            label: 'Competitions',
          ),
        ],
      ),
    );
  }

  Widget _buildNewsPage() {
    return FutureBuilder<List<NewsItem>>(
      future: _newsFuture,
      builder: (context, snapshot) {
        return RefreshIndicator(
          onRefresh: () async {
            // Clear cache and refresh
            DataService.clearCache();
            setState(() {
              _newsFuture = DataService.getNewsItems();
            });
            await _newsFuture;
          },
          child: _buildNewsContent(snapshot),
        );
      },
    );
  }

  Widget _buildNewsContent(AsyncSnapshot<List<NewsItem>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
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
                setState(() {
                  _newsFuture = DataService.getNewsItems();
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(
        child: Text('No news items available'),
      );
    }

    _allNewsItems = snapshot.data!;
    final visibleNewsItems = _allNewsItems.take(_visibleItemsCount).toList();
    final hasMoreItems = _allNewsItems.length > _visibleItemsCount;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      itemCount: visibleNewsItems.length + (hasMoreItems ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < visibleNewsItems.length) {
          final newsItem = visibleNewsItems[index];
          return GestureDetector(
            onTap: () => _openNewsDetail(newsItem),
            child: NewsCard(
              newsItem: newsItem,
              shouldLoadImageImmediately:
                  index < 3, // Load images for first 3 items immediately
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                    'Show more (${_allNewsItems.length - _visibleItemsCount} remaining)'),
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
          (_visibleItemsCount + 5).clamp(0, _allNewsItems.length);
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
    if (_imageLoading || widget.newsItem.link == null) {
      return;
    }

    setState(() {
      _imageLoading = true;
      _hasBeenVisible = true; // Mark as loaded to prevent future loads
    });

    await DataService.updateNewsItemImage(widget.newsItem);

    if (mounted) {
      setState(() {
        _imageLoading = false;
      });
    }
  }

  Future<void> _loadImage() async {
    // Don't load if already loading, already loaded, or no link available
    if (_imageLoading ||
        _hasBeenVisible ||
        widget.newsItem.link == null ||
        widget.newsItem.imageUrl != _originalImageUrl) {
      return;
    }

    setState(() {
      _imageLoading = true;
      _hasBeenVisible = true; // Mark as loaded to prevent future loads
    });

    await DataService.updateNewsItemImage(widget.newsItem);

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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12.0),
              ),
              child: Stack(
                children: [
                  Image.network(
                    widget.newsItem.imageUrl,
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
                  if (_showSpinner && widget.newsItem.link != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: FITColors.primaryBlack.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(FITColors.white),
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: FITColors.darkGrey,
                        ),
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
