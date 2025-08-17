import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/news_item.dart';
import '../services/data_service.dart';

class NewsDetailView extends StatefulWidget {
  final NewsItem newsItem;

  const NewsDetailView({super.key, required this.newsItem});

  @override
  State<NewsDetailView> createState() => _NewsDetailViewState();
}

class _NewsDetailViewState extends State<NewsDetailView> {
  bool _imageLoaded = false;
  String? _originalImageUrl;

  @override
  void initState() {
    super.initState();
    _originalImageUrl = widget.newsItem.imageUrl;
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (widget.newsItem.link != null) {
      await DataService.updateNewsItemImage(widget.newsItem);
      if (mounted) {
        setState(() {
          _imageLoaded = true;
        });
      }
    }
  }

  bool get _showSpinner {
    return !_imageLoaded && widget.newsItem.imageUrl == _originalImageUrl;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Article'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            Stack(
              children: [
                Image.network(
                  widget.newsItem.imageUrl,
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
                if (_showSpinner && widget.newsItem.link != null)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Article content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.newsItem.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Date
                  Text(
                    _formatDate(widget.newsItem.publishedAt),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Content
                  if (widget.newsItem.content != null)
                    Html(
                      data: widget.newsItem.content!,
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
                      widget.newsItem.summary,
                      style: Theme.of(context).textTheme.bodyLarge,
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