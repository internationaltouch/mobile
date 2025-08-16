class Fixture {
  final String id;
  final String homeTeamId;
  final String awayTeamId;
  final String homeTeamName;
  final String awayTeamName;
  final DateTime dateTime;
  final String field;
  final String divisionId;
  final int? homeScore;
  final int? awayScore;
  final bool isCompleted;
  final String? round; // Add round information from API
  final bool? isBye; // Add bye information from API

  Fixture({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.dateTime,
    required this.field,
    required this.divisionId,
    this.homeScore,
    this.awayScore,
    this.isCompleted = false,
    this.round,
    this.isBye,
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

    return Fixture(
      id: json['id']?.toString() ?? '',
      homeTeamId: json['homeTeamId']?.toString() ?? json['home_team']?.toString() ?? '',
      awayTeamId: json['awayTeamId']?.toString() ?? json['away_team']?.toString() ?? '',
      homeTeamName: json['homeTeamName'] ?? '',
      awayTeamName: json['awayTeamName'] ?? '',
      dateTime: parsedDateTime,
      field: json['field'] ?? json['play_at']?['title'] ?? '',
      divisionId: json['divisionId'] ?? '',
      homeScore: json['homeScore'] ?? json['home_team_score'],
      awayScore: json['awayScore'] ?? json['away_team_score'],
      isCompleted: json['isCompleted'] ?? (json['home_team_score'] != null && json['away_team_score'] != null),
      round: json['round'],
      isBye: json['is_bye'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homeTeamId': homeTeamId,
      'awayTeamId': awayTeamId,
      'homeTeamName': homeTeamName,
      'awayTeamName': awayTeamName,
      'dateTime': dateTime.toIso8601String(),
      'field': field,
      'divisionId': divisionId,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'isCompleted': isCompleted,
      'round': round,
      'isBye': isBye,
    };
  }

  String get resultText {
    if (isCompleted && homeScore != null && awayScore != null) {
      return '$homeScore - $awayScore';
    }
    return '';
  }
}