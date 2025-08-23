import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/fit_colors.dart';

class VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;
  final String homeTeamName;
  final String awayTeamName;
  final String divisionName;

  const VideoPlayerDialog({
    super.key,
    required this.videoUrl,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.divisionName,
  });

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  String? _videoId;
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _extractVideoId();
    if (_videoId != null) {
      _initializePlayer();
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _extractVideoId() {
    // Extract YouTube video ID from various URL formats
    final uri = Uri.parse(widget.videoUrl);

    if (uri.host.contains('youtube.com')) {
      _videoId = uri.queryParameters['v'];
    } else if (uri.host.contains('youtu.be')) {
      _videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController.fromVideoId(
      videoId: _videoId!,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );

    _controller.setFullScreenListener(
      (isFullScreen) {
        // Handle fullscreen changes if needed
      },
    );
  }

  void _shareVideo() async {
    final shareText = 'Watch ${widget.homeTeamName} vs ${widget.awayTeamName} in the ${widget.divisionName} division! ${widget.videoUrl}';
    
    try {
      await Share.share(shareText);
    } catch (e) {
      if (mounted) {
        // Fallback: Show a dialog with the text to copy
        _showShareFallback(shareText);
      }
    }
  }

  void _showShareFallback(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Copy this text to share:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FITColors.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null) {
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
                color: FITColors.errorRed,
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

            // YouTube Player
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black87,
              ),
              child: YoutubePlayer(
                controller: _controller,
                aspectRatio: 16 / 9,
              ),
            ),

            // Share button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _shareVideo,
                  icon: const Icon(Icons.share, color: FITColors.white),
                  label: const Text(
                    'Share this video',
                    style: TextStyle(color: FITColors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FITColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
