/// Configuration for competition images and filtering
class CompetitionConfig {
  // Static image resources by slug
  static const Map<String, String> competitionImages = {
    'asia-pacific-youth-touch-cup': 'assets/images/competitions/APYTC.png',
    'atlantic-youth-touch-cup': 'assets/images/competitions/AYTC.png',
    'european-junior-touch-championships':
        'assets/images/competitions/EJTC.png',
    'euros': 'assets/images/competitions/ETC.png',
    // Add more competition images here as needed
    // Format: 'slug': 'assets/images/competitions/filename.png'
  };

  // Competition filtering configuration

  // MODE 1: INCLUDE - Only show competitions with these slugs (leave empty [] to show ALL)
  static const List<String> includeCompetitionSlugs = [
    // 'world-cup',
    // 'atlantic-youth-touch-cup',
    // 'other-events',
  ];

  // MODE 2: EXCLUDE - Hide competitions with these slugs (leave empty [] to exclude nothing)
  static const List<String> excludeCompetitionSlugs = [
    'home-nations',
    'mainland-cup',
    'asian-cup',
    'test-matches',
    'pacific-games',
    // Add specific slugs here to HIDE these competitions
  ];
}
