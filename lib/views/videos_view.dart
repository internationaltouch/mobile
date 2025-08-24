import 'package:flutter/material.dart';
import '../models/fixture.dart';
import '../services/data_service.dart';
import '../theme/fit_colors.dart';
import '../widgets/video_player_dialog.dart';

class VideosView extends StatefulWidget {
  const VideosView({super.key});

  @override
  State<VideosView> createState() => _VideosViewState();
}

class _VideosViewState extends State<VideosView> {
  late Future<List<Fixture>> _videoFixturesFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVideoFixtures();
  }

  void _loadVideoFixtures() {
    setState(() {
      _isLoading = true;
    });

    _videoFixturesFuture = DataService.getFixturesWithVideos().then((fixtures) {
      setState(() {
        _isLoading = false;
      });
      return fixtures;
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      throw error;
    });
  }

  Future<void> _onRefresh() async {
    _loadVideoFixtures();
  }

  void _playVideo(String videoUrl, String matchTitle) {
    showDialog(
      context: context,
      builder: (context) => VideoPlayerDialog(videoUrl: videoUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Videos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: FITColors.primaryBlue,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<List<Fixture>>(
          future: _videoFixturesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                _isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorView(
                'Failed to load videos',
                () => _loadVideoFixtures(),
              );
            }

            final fixtures = snapshot.data ?? [];
            if (fixtures.isEmpty) {
              return _buildEmptyView();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: fixtures.length,
              itemBuilder: (context, index) {
                final fixture = fixtures[index];
                return _buildVideoCard(fixture);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoCard(Fixture fixture) {
    final hasMultipleVideos = fixture.videos.length > 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with match info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: FITColors.primaryBlue,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${fixture.homeTeamName} vs ${fixture.awayTeamName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(fixture.dateTime),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (fixture.field.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    fixture.field,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (fixture.isCompleted && fixture.resultText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Final: ${fixture.resultText}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Video buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasMultipleVideos) ...[
                  const Text(
                    'Available Videos:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                ...fixture.videos.asMap().entries.map((entry) {
                  final index = entry.key;
                  final videoUrl = entry.value;
                  final videoTitle = hasMultipleVideos
                      ? 'Video ${index + 1}'
                      : 'Watch Match Video';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _playVideo(videoUrl,
                            '${fixture.homeTeamName} vs ${fixture.awayTeamName}'),
                        icon: const Icon(Icons.play_circle_fill),
                        label: Text(videoTitle),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FITColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Videos Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for match videos',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: FITColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }
}
