import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/club.dart';
import '../services/flag_service.dart';
import '../theme/fit_colors.dart';

class MemberDetailView extends StatelessWidget {
  final Club club;

  const MemberDetailView({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          club.title,
          style: const TextStyle(
            color: FITColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: FITColors.accentYellow,
        elevation: 0,
        iconTheme: const IconThemeData(color: FITColors.primaryBlack),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flag and basic info
            _buildHeaderSection(),
            const SizedBox(height: 24),

            // Social media and website links
            _buildLinksSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Large flag
            Container(
              height: 120,
              width: 160, // 4:3 aspect ratio
              child: FlagService.getFlagWidget(
                    teamName: club.title,
                    clubAbbreviation: club.abbreviation,
                    size: 120.0,
                  ) ??
                  Container(
                    decoration: BoxDecoration(
                      color: FITColors.lightGrey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: FITColors.outline,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.flag,
                        color: FITColors.mediumGrey,
                        size: 48,
                      ),
                    ),
                  ),
            ),
            const SizedBox(height: 16),

            // Country name
            Text(
              club.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: FITColors.primaryBlack,
              ),
              textAlign: TextAlign.center,
            ),

            if (club.shortTitle != club.title) ...[
              const SizedBox(height: 8),
              Text(
                club.shortTitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: FITColors.darkGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: FITColors.primaryBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                club.abbreviation,
                style: const TextStyle(
                  color: FITColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinksSection() {
    final links = <Map<String, dynamic>>[];

    if (club.website != null && club.website!.isNotEmpty) {
      links.add({
        'title': 'Official Website',
        'url': club.website!,
        'icon': Icons.language,
        'color': FITColors.primaryBlue,
      });
    }

    if (club.facebook != null && club.facebook!.isNotEmpty) {
      links.add({
        'title': 'Facebook',
        'url': club.facebook!,
        'icon': Icons.facebook,
        'color': const Color(0xFF1877F2), // Facebook blue
      });
    }

    if (club.twitter != null && club.twitter!.isNotEmpty) {
      // Handle Twitter handle format
      String twitterUrl = club.twitter!;
      if (twitterUrl.startsWith('@')) {
        twitterUrl = 'https://twitter.com/${twitterUrl.substring(1)}';
      } else if (!twitterUrl.startsWith('http')) {
        twitterUrl = 'https://twitter.com/$twitterUrl';
      }

      links.add({
        'title': 'Twitter',
        'url': twitterUrl,
        'icon': Icons.alternate_email,
        'color': const Color(0xFF1DA1F2), // Twitter blue
      });
    }

    if (club.youtube != null && club.youtube!.isNotEmpty) {
      links.add({
        'title': 'YouTube',
        'url': club.youtube!,
        'icon': Icons.play_circle_fill,
        'color': const Color(0xFFFF0000), // YouTube red
      });
    }

    if (links.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                Icons.link_off,
                size: 48,
                color: FITColors.mediumGrey,
              ),
              SizedBox(height: 12),
              Text(
                'No links available',
                style: TextStyle(
                  fontSize: 16,
                  color: FITColors.darkGrey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Links & Social Media',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: FITColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 16),
            ...links.map((link) => _buildLinkButton(link)),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkButton(Map<String, dynamic> link) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _launchUrl(link['url'] as String),
        style: ElevatedButton.styleFrom(
          backgroundColor: link['color'] as Color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              link['icon'] as IconData,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              link['title'] as String,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}
