class LadderEntry {
  final String teamId;
  final String teamName;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int points;
  final int goalDifference;
  final int goalsFor;
  final int goalsAgainst;

  LadderEntry({
    required this.teamId,
    required this.teamName,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.points,
    required this.goalDifference,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  factory LadderEntry.fromJson(Map<String, dynamic> json) {
    return LadderEntry(
      teamId: json['teamId'],
      teamName: json['teamName'],
      played: json['played'],
      wins: json['wins'],
      draws: json['draws'],
      losses: json['losses'],
      points: json['points'],
      goalDifference: json['goalDifference'],
      goalsFor: json['goalsFor'],
      goalsAgainst: json['goalsAgainst'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'played': played,
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'points': points,
      'goalDifference': goalDifference,
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
    };
  }

  String get goalDifferenceText {
    if (goalDifference > 0) {
      return '+$goalDifference';
    }
    return '$goalDifference';
  }
}