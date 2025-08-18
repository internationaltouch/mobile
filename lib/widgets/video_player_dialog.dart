import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerDialog({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  String? _videoId;
  String? _thumbnailUrl;

  @override
  void initState() {
    super.initState();
    _extractVideoId();
  }

  void _extractVideoId() {
    // Extract YouTube video ID from various URL formats
    final uri = Uri.parse(widget.videoUrl);
    
    if (uri.host.contains('youtube.com')) {
      _videoId = uri.queryParameters['v'];
    } else if (uri.host.contains('youtu.be')) {
      _videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    
    if (_videoId != null) {
      _thumbnailUrl = 'https://img.youtube.com/vi/$_videoId/maxresdefault.jpg';
    }
  }

  Future<void> _launchVideo() async {
    try {
      final uri = Uri.parse(widget.videoUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // Close dialog after launching
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // If launching fails, try with system default
      try {
        final uri = Uri.parse(widget.videoUrl);
        await launchUrl(uri);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Show error if both attempts fail
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open video: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null || _thumbnailUrl == null) {
      return AlertDialog(
        title: const Text('Video Error'),
        content: const Text('Unable to play this video. Invalid YouTube URL.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Match Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Video thumbnail with play overlay
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black87,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Video thumbnail
                  Image.network(
                    _thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.black87,
                        child: const Center(
                          child: Icon(
                            Icons.video_library,
                            size: 64,
                            color: Colors.white54,
                          ),
                        ),
                      );
                    },
                  ),
                  // Play overlay
                  Container(
                    color: Colors.black26,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _launchVideo,
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 48,
                          ),
                          iconSize: 48,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Description and action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Tap the play button above to watch the match highlights in your preferred video app.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
