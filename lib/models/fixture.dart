class Fixture {
  final String id;
  final String homeTeamId;
  final String awayTeamId;
  final String homeTeamName;
  final String awayTeamName;
  final String? homeTeamAbbreviation; // Club abbreviation for home team
  final String? awayTeamAbbreviation; // Club abbreviation for away team
  final DateTime dateTime;
  final String field;
  final String divisionId;
  final int? homeScore;
  final int? awayScore;
  final bool isCompleted;
  final String? round; // Add round information from API
  final bool? isBye; // Add bye information from API
  final List<String> videos; // Add video URLs from API

  Fixture({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeTeamName,
    required this.awayTeamName,
    this.homeTeamAbbreviation,
    this.awayTeamAbbreviation,
    required this.dateTime,
    required this.field,
    required this.divisionId,
    this.homeScore,
    this.awayScore,
    this.isCompleted = false,
    this.round,
    this.isBye,
    this.videos = const [],
  });

  factory Fixture.fromJson(Map<String, dynamic> json) {
    // Handle datetime parsing from API
    DateTime parsedDateTime;
    if (json['datetime'] != null) {
      parsedDateTime = DateTime.parse(json['datetime']);
    } else if (json['date'] != null && json['time'] != null) {
      parsedDateTime = DateTime.parse('${json['date']}T${json['time']}Z');
    } else if (json['dateTime'] != null) {
      parsedDateTime = DateTime.parse(json['dateTime']);
    } else {
      parsedDateTime = DateTime.now();
    }

    final homeAbbreviation = _extractTeamAbbreviation(json, 'home_team');
    final awayAbbreviation = _extractTeamAbbreviation(json, 'away_team');

    return Fixture(
      id: json['id']?.toString() ?? '',
      homeTeamId:
          json['homeTeamId']?.toString() ?? json['home_team']?.toString() ?? '',
      awayTeamId:
          json['awayTeamId']?.toString() ?? json['away_team']?.toString() ?? '',
      homeTeamName: json['homeTeamName'] ?? json['home_team']?['name'] ?? '',
      awayTeamName: json['awayTeamName'] ?? json['away_team']?['name'] ?? '',
      homeTeamAbbreviation: homeAbbreviation,
      awayTeamAbbreviation: awayAbbreviation,
      dateTime: parsedDateTime,
      field: json['field'] ?? json['play_at']?['title'] ?? '',
      divisionId: json['divisionId'] ?? '',
      homeScore: json['homeScore'] ?? json['home_team_score'],
      awayScore: json['awayScore'] ?? json['away_team_score'],
      isCompleted: json['isCompleted'] ??
          (json['home_team_score'] != null && json['away_team_score'] != null),
      round: json['round'],
      isBye: json['is_bye'],
      videos: (json['videos'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  static String? _extractTeamAbbreviation(
      Map<String, dynamic> json, String teamKey) {
    // Try multiple possible data structures for team abbreviation

    // 1. Try from nested team object with club data
    final teamData = json[teamKey];
    if (teamData is Map<String, dynamic>) {
      final club = teamData['club'];
      if (club is Map<String, dynamic>) {
        final abbreviation = club['abbreviation'] as String?;
        if (abbreviation != null && abbreviation.isNotEmpty) {
          return abbreviation;
        }
      }
    }

    // 2. Try from direct team data if it's a map
    if (teamData is Map<String, dynamic>) {
      final abbreviation = teamData['abbreviation'] as String?;
      if (abbreviation != null && abbreviation.isNotEmpty) {
        return abbreviation;
      }
    }

    // 3. Try alternative key patterns for different API responses
    final alternativeKeys = [
      '${teamKey}_abbreviation',
      '${teamKey}Abbreviation',
      teamKey.replaceAll('_team', 'TeamAbbreviation'),
    ];

    for (final key in alternativeKeys) {
      final abbreviation = json[key] as String?;
      if (abbreviation != null && abbreviation.isNotEmpty) {
        return abbreviation;
      }
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homeTeamId': homeTeamId,
      'awayTeamId': awayTeamId,
      'homeTeamName': homeTeamName,
      'awayTeamName': awayTeamName,
      'homeTeamAbbreviation': homeTeamAbbreviation,
      'awayTeamAbbreviation': awayTeamAbbreviation,
      'dateTime': dateTime.toIso8601String(),
      'field': field,
      'divisionId': divisionId,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'isCompleted': isCompleted,
      'round': round,
      'isBye': isBye,
      'videos': videos,
    };
  }

  String get resultText {
    if (isCompleted && homeScore != null && awayScore != null) {
      return '$homeScore - $awayScore';
    }
    return '';
  }

  String? get homeTeamFlagUrl {
    if (homeTeamAbbreviation != null) {
      return 'https://www.internationaltouch.org/static/images/flag-${homeTeamAbbreviation}x2.png';
    }
    return null;
  }

  String? get awayTeamFlagUrl {
    if (awayTeamAbbreviation != null) {
      return 'https://www.internationaltouch.org/static/images/flag-${awayTeamAbbreviation}x2.png';
    }
    return null;
  }
}
