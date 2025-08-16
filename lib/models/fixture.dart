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
  });

  factory Fixture.fromJson(Map<String, dynamic> json) {
    return Fixture(
      id: json['id'],
      homeTeamId: json['homeTeamId'],
      awayTeamId: json['awayTeamId'],
      homeTeamName: json['homeTeamName'],
      awayTeamName: json['awayTeamName'],
      dateTime: DateTime.parse(json['dateTime']),
      field: json['field'],
      divisionId: json['divisionId'],
      homeScore: json['homeScore'],
      awayScore: json['awayScore'],
      isCompleted: json['isCompleted'] ?? false,
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
    };
  }

  String get resultText {
    if (isCompleted && homeScore != null && awayScore != null) {
      return '$homeScore - $awayScore';
    }
    return '';
  }
}