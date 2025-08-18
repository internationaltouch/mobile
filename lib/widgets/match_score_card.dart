import 'package:flutter/material.dart';
import '../models/fixture.dart';
import '../theme/fit_colors.dart';
import 'video_player_dialog.dart';

class MatchScoreCard extends StatelessWidget {
  final Fixture fixture;
  final String? homeTeamLocation;
  final String? awayTeamLocation;
  final String? venue;
  final String? venueLocation;

  const MatchScoreCard({
    super.key,
    required this.fixture,
    this.homeTeamLocation,
    this.awayTeamLocation,
    this.venue,
    this.venueLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Date section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _formatMatchDate(fixture.dateTime),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: FITColors.darkGrey,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
            const SizedBox(height: 12),

            // Main match section
            Row(
              children: [
                // Home team
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Team logo/flag
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: _buildTeamLogo(
                          fixture.homeTeamName,
                          fixture.homeTeamAbbreviation,
                          fixture.homeTeamFlagUrl,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Team name with fixed height to maintain alignment
                      SizedBox(
                        height: 28, // Fixed height for up to 2 lines of text
                        child: Text(
                          fixture.homeTeamName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      // Team location
                      if (homeTeamLocation != null)
                        Text(
                          homeTeamLocation!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: FITColors.darkGrey,
                                    fontSize: 11,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),

                // Score section
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (fixture.isCompleted &&
                          fixture.homeScore != null &&
                          fixture.awayScore != null) ...[
                        // Completed match scores with winner emphasis
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Home score
                            Text(
                              '${fixture.homeScore}',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    fontWeight:
                                        fixture.homeScore! > fixture.awayScore!
                                            ? FontWeight.bold
                                            : fixture.homeScore! ==
                                                    fixture.awayScore!
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                    color: FITColors.primaryBlack,
                                    fontSize: 36,
                                  ),
                            ),
                            const SizedBox(width: 16),
                            // Full time text between scores
                            Text(
                              'FULL\nTIME',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: FITColors.darkGrey,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.8,
                                    fontSize: 10,
                                    height: 1.1,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(width: 16),
                            // Away score
                            Text(
                              '${fixture.awayScore}',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    fontWeight:
                                        fixture.awayScore! > fixture.homeScore!
                                            ? FontWeight.bold
                                            : fixture.homeScore! ==
                                                    fixture.awayScore!
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                    color: FITColors.primaryBlack,
                                    fontSize: 36,
                                  ),
                            ),
                          ],
                        ),
                      ] else if (fixture.isBye == true) ...[
                        // Bye match
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: FITColors.lightGrey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'BYE',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: FITColors.darkGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ] else ...[
                        // Scheduled match
                        Column(
                          children: [
                            Text(
                              _formatMatchTime(fixture.dateTime),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: FITColors.accentYellow.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'SCHEDULED',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: FITColors.primaryBlack,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Away team
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Team logo/flag
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: _buildTeamLogo(
                          fixture.awayTeamName,
                          fixture.awayTeamAbbreviation,
                          fixture.awayTeamFlagUrl,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Team name with fixed height to maintain alignment
                      SizedBox(
                        height: 28, // Fixed height for up to 2 lines of text
                        child: Text(
                          fixture.awayTeamName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      // Team location
                      if (awayTeamLocation != null)
                        Text(
                          awayTeamLocation!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: FITColors.darkGrey,
                                    fontSize: 11,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Venue section
            if (venue != null || fixture.field.isNotEmpty) ...[
              Text(
                venue ?? fixture.field,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              if (venueLocation != null) ...[
                const SizedBox(height: 2),
                Text(
                  venueLocation!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: FITColors.darkGrey,
                        fontSize: 11,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],

            // Round information
            if (fixture.round != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: FITColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: FITColors.primaryBlue.withValues(alpha: 0.3)),
                ),
                child: Text(
                  fixture.round!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: FITColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                ),
              ),
            ],

            // Video player section
            if (fixture.videos.isNotEmpty) ...[
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showVideoDialog(context, fixture.videos.first),
                  icon: const Icon(Icons.play_arrow, color: FITColors.white),
                  label: const Text(
                    'Watch',
                    style: TextStyle(color: FITColors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FITColors.errorRed,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo(
      String teamName, String? abbreviation, String? flagUrl) {
    // Use actual abbreviation from API data if available, otherwise generate fallback
    final displayAbbreviation =
        abbreviation ?? _generateFallbackAbbreviation(teamName);

    // Try to load flag image if URL is available
    if (flagUrl != null && flagUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          flagUrl,
          width: 45,
          height: 45,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to abbreviation text if image fails to load
            return Center(
              child: Text(
                displayAbbreviation,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: Text(
                displayAbbreviation,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            );
          },
        ),
      );
    }

    // Fallback to abbreviation text when no flag URL available
    return Center(
      child: Text(
        displayAbbreviation,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  String _generateFallbackAbbreviation(String teamName) {
    // Generate abbreviation as fallback for teams without club abbreviation
    if (teamName.toLowerCase().contains('france')) {
      return 'FRA';
    } else if (teamName.toLowerCase().contains('scotland')) {
      return 'SCO';
    } else if (teamName.toLowerCase().contains('england')) {
      return 'ENG';
    } else if (teamName.toLowerCase().contains('united states')) {
      return 'USA';
    } else if (teamName.toLowerCase().contains('new zealand')) {
      return 'NZL';
    } else {
      // Default: use first letters of up to 3 words, max 3 characters
      final words =
          teamName.split(' ').where((word) => word.isNotEmpty).toList();
      if (words.length >= 3) {
        return words.take(3).map((word) => word[0].toUpperCase()).join();
      } else if (words.length >= 2) {
        return words.take(2).map((word) => word[0].toUpperCase()).join();
      } else if (words.isNotEmpty) {
        return words.first.length >= 3
            ? words.first.substring(0, 3).toUpperCase()
            : words.first.toUpperCase();
      } else {
        return 'TEM';
      }
    }
  }

  String _formatMatchDate(DateTime dateTime) {
    // Convert UTC datetime to local timezone
    final localDateTime = dateTime.toLocal();

    final weekdays = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY'
    ];
    final months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER'
    ];

    final weekday = weekdays[localDateTime.weekday - 1];
    final day = localDateTime.day;
    final month = months[localDateTime.month - 1];

    return '$weekday ${day}TH $month';
  }

  String _formatMatchTime(DateTime dateTime) {
    // Convert UTC datetime to local timezone
    final localDateTime = dateTime.toLocal();

    final hour = localDateTime.hour.toString().padLeft(2, '0');
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showVideoDialog(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      builder: (context) => VideoPlayerDialog(videoUrl: videoUrl),
    );
  }
}
