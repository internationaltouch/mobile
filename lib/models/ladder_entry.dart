class LadderEntry {
  final String teamId;
  final String teamName;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final double points;
  final int goalDifference;
  final int goalsFor;
  final int goalsAgainst;
  final double? percentage;
  final int? poolId; // Pool ID for pool-based ladder entries

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
    this.percentage,
    this.poolId,
  });

  factory LadderEntry.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numeric values that might be strings
    int parseIntSafely(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    // Helper function to safely parse double values that might be strings
    double parseDoubleSafely(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    // Map API structure to our internal structure
    final scoreFor = parseIntSafely(json['score_for']);
    final scoreAgainst = parseIntSafely(json['score_against']);

    return LadderEntry(
      teamId: json['team']?.toString() ?? json['teamId']?.toString() ?? '',
      teamName: json['team_name'] ??
          json['teamName'] ??
          '', // Will be filled in by LadderStage
      played: parseIntSafely(json['played']),
      wins: parseIntSafely(
          json['win'] ?? json['wins']), // API uses 'win', fallback to 'wins'
      draws: parseIntSafely(json['draw'] ??
          json['draws']), // API uses 'draw', fallback to 'draws'
      losses: parseIntSafely(json['loss'] ??
          json['losses']), // API uses 'loss', fallback to 'losses'
      points: parseDoubleSafely(json['points']),
      goalDifference: scoreFor - scoreAgainst,
      goalsFor: scoreFor,
      goalsAgainst: scoreAgainst,
      percentage: parseDoubleSafely(json['percentage']),
      poolId: json['pool_id'] as int?,
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
      'percentage': percentage,
      'poolId': poolId,
    };
  }

  String get goalDifferenceText {
    if (goalDifference > 0) {
      return '+$goalDifference';
    }
    return '$goalDifference';
  }
}
